%% ================================ INITIALIZATION ================================
clear; 
clc;   

%% ======================= ROBOT DEFINITION (D-H PARAMETERS) ======================
d1 = 37.5;     
d2 = 160;      
d3 = 14.84;    
a1 = 133.35;   
a2 = 141.07;   
endeff = 0;    

% --- Create Robot Links using the Robotics Toolbox ---
L(1) = Link([0     d1       a1       pi/2]);
L(2) = Link([0     0        d2      -pi]);
L(3) = Link([0     0        d3      -pi/2]);
L(4) = Link([0     a2       0        pi/2]);
L(5) = Link([0     0        0       -pi/2]);
L(6) = Link([0     endeff   0        0]);

% --- Assemble the Robot ---
kuka_R6 = SerialLink(L);
kuka_R6.name = 'KUKA R6';

%% ======================= DEFINE TRAJECTORY WAYPOINTS ===========================
point(1, :) = [178.570  0       308.190];
point(2, :) = [167.090  0       308.190];
point(3, :) = [167.090  0       236.667];
point(4, :) = [167.090  83.545  236.667];
point(5, :) = [144.704  83.545  236.667];
point(6, :) = [144.704  83.545  422.940];
point(7, :) = [144.704  47.592  422.940];
point(8, :) = [82.431   47.592  422.940];

%% ======================= CHECK ROBOT WORKSPACE =================================
% Calculate maximum reach
max_reach = abs(d1) + abs(a1) + abs(d2) + abs(d3) + abs(a2);
fprintf('=== ROBOT WORKSPACE ANALYSIS ===\n');
fprintf('Maximum theoretical reach: %.2f mm\n\n', max_reach);

% Check each waypoint
fprintf('Waypoint Reachability Check:\n');
fprintf('%-8s %-12s %-12s %-12s %-12s %-10s\n', 'Point', 'X', 'Y', 'Z', 'Distance', 'Status');
fprintf('%s\n', repmat('-', 1, 75));

for i = 1:size(point, 1)
    dist = sqrt(point(i,1)^2 + point(i,2)^2 + point(i,3)^2);
    status = 'OK';
    if dist > max_reach * 0.95  % Use 95% as safety margin
        status = 'RISKY';
    end
    if dist > max_reach
        status = 'UNREACHABLE';
    end
    fprintf('%-8d %-12.2f %-12.2f %-12.2f %-12.2f %-10s\n', ...
            i, point(i,1), point(i,2), point(i,3), dist, status);
end
fprintf('\n');

%% ======================= TRAJECTORY GENERATION =======================
% CRITICAL FIX: samples MUST be an integer, not 0.1!
samples = 10;  % Number of interpolation points between waypoints

total_points = (samples * (length(point) - 1)) + 1;
x = zeros(total_points, 1);
y = zeros(total_points, 1);
z = zeros(total_points, 1);

%% ======================= INTERPOLATE THE PATH =======================
% Interpolate X-coordinates
for trans = 1:length(point)-1
    x_segment = linspace(point(trans,1), point(trans+1,1), samples+1);
    start_index = (trans-1)*samples + 1;
    end_index = start_index + samples;
    x(start_index:end_index) = x_segment;
end

% Interpolate Y-coordinates
for trans = 1:length(point)-1
    y_segment = linspace(point(trans,2), point(trans+1,2), samples+1);
    start_index = (trans-1)*samples + 1;
    end_index = start_index + samples;
    y(start_index:end_index) = y_segment;
end

% Interpolate Z-coordinates
for trans = 1:length(point)-1
    z_segment = linspace(point(trans,3), point(trans+1,3), samples+1);
    start_index = (trans-1)*samples + 1;
    end_index = start_index + samples;
    z(start_index:end_index) = z_segment;
end

fprintf('Generated %d interpolated trajectory points\n\n', length(x));

%% =============== CREATE HOMOGENEOUS TRANSFORMATION MATRICES ===============
T = zeros(4, 4, length(x));

% Define end-effector orientation (tool pointing down)
orientation_matrix = [1,  0,  0;
                      0, -1,  0;
                      0,  0, -1];

for loop = 1:length(x)
    T(1:3, 1:3, loop) = orientation_matrix;
    T(4, 4, loop) = 1;
    T(1, 4, loop) = x(loop);
    T(2, 4, loop) = y(loop);
    T(3, 4, loop) = z(loop);
end

%% ======================= CALCULATE INVERSE KINEMATICS =======================
fprintf('=== INVERSE KINEMATICS SOLVING ===\n');

q1 = zeros(length(x), 6);

% Multiple initial guesses to try
initial_guesses = [
    0       pi/4    -pi/2   0       pi/4    0;
    0       pi/3    -pi/3   0       0       0;
    pi/6    pi/4    -pi/4   0       pi/6    0;
    0       0       -pi/4   0       pi/4    0;
    0       pi/2    -pi/2   0       0       0;
];

% Solve for first point with multiple attempts
solved = false;
for attempt = 1:size(initial_guesses, 1)
    q0 = initial_guesses(attempt, :);
    
    fprintf('Attempt %d: Trying initial guess [%.2f, %.2f, %.2f, %.2f, %.2f, %.2f] deg\n', ...
            attempt, rad2deg(q0));
    
    % Try with relaxed constraints (position only)
    q_result = kuka_R6.ikine(T(:,:,1), q0, ...
                             'mask', [1 1 1 0 0 0], ...
                             'ilimit', 2000, ...
                             'tol', 1e-3);
    
    if ~isempty(q_result)
        q1(1,:) = q_result;
        fprintf('✓ SUCCESS! Found solution for first pose\n');
        fprintf('  Joint angles: [%.2f, %.2f, %.2f, %.2f, %.2f, %.2f] deg\n\n', ...
                rad2deg(q1(1,:)));
        solved = true;
        break;
    else
        fprintf('  Failed to converge\n');
    end
end

if ~solved
    error(['Unable to solve inverse kinematics for the first waypoint!\n' ...
           'Possible reasons:\n' ...
           '  1. Target position is outside robot workspace\n' ...
           '  2. Orientation constraint is too strict\n' ...
           '  3. Robot is in singular configuration\n\n' ...
           'Suggestions:\n' ...
           '  - Reduce the distance of waypoints from origin\n' ...
           '  - Try different orientations\n' ...
           '  - Use mask [1 1 1 0 0 0] for position-only IK']);
end

% Solve remaining trajectory points
fprintf('Solving complete trajectory...\n');
success_count = 1;
fail_count = 0;

for loop = 2:length(x)
    % Use previous solution as initial guess
    q_result = kuka_R6.ikine(T(:,:,loop), q1(loop-1,:), ...
                             'mask', [1 1 1 0 0 0], ...
                             'ilimit', 2000, ...
                             'tol', 1e-3);
    
    if ~isempty(q_result)
        q1(loop, :) = q_result;
        success_count = success_count + 1;
    else
        % If failed, keep previous joint angles
        q1(loop, :) = q1(loop-1, :);
        fail_count = fail_count + 1;
        if fail_count == 1
            fprintf('  Warning: Some points failed to converge\n');
        end
    end
    
    % Progress indicator every 10%
    if mod(loop, max(1, floor(length(x)/10))) == 0
        fprintf('  Progress: %d/%d points solved\n', loop, length(x));
    end
end

fprintf('\n=== SOLUTION SUMMARY ===\n');
fprintf('Total points: %d\n', length(x));
fprintf('Successfully solved: %d (%.1f%%)\n', success_count, 100*success_count/length(x));
fprintf('Failed (using previous): %d (%.1f%%)\n\n', fail_count, 100*fail_count/length(x));

%% ======================= VERIFY FORWARD KINEMATICS =======================
fprintf('Verifying solution accuracy...\n');
max_error = 0;
for loop = 1:length(x)
    T_actual = kuka_R6.fkine(q1(loop,:));
    pos_error = norm([T_actual(1,4) - x(loop); 
                      T_actual(2,4) - y(loop); 
                      T_actual(3,4) - z(loop)]);
    max_error = max(max_error, pos_error);
end
fprintf('Maximum position error: %.4f mm\n\n', max_error);

%% ======================= PLOT AND ANIMATE THE ROBOT =======================
fprintf('Creating animation...\n');

kuka_R6.plotopt = {'tilesize', 200, 'workspace', [-500 500 -500 500 0 600]};

% Create figure
fig = figure('Name', 'KUKA R6 Trajectory', 'Position', [100 100 1200 800]);

% Animate robot
kuka_R6.plot(q1, 'trail', 'r-');

hold on;

% Plot desired trajectory
plot3(x, y, z, 'b--', 'LineWidth', 2.5);

% Plot waypoints
plot3(point(:,1), point(:,2), point(:,3), 'go', 'MarkerSize', 12, ...
      'MarkerFaceColor', 'g', 'LineWidth', 2);

% Add waypoint labels
for i = 1:size(point, 1)
    text(point(i,1), point(i,2), point(i,3)+20, sprintf('P%d', i), ...
         'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
end

legend('Actual path', 'Desired trajectory', 'Waypoints', 'Location', 'best');
title('KUKA R6 Robot Trajectory Following');
grid on;
view(45, 30);

fprintf('✓ Animation complete!\n');