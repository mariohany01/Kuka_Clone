%% KUKA Robot Clone - Forward and Inverse Kinematics
% Clean workspace
clc; clear; close all;

%% DH Parameters (in mm)
a1 = 135.3;
d1 = 37.5;
d2 = 160;
d3 = 15;
a2 = 137.3;
endeff = 0;
width = 50;

%% Robot Definition using DH Convention
% Link([theta, d, a, alpha])
L(1) = Link([0,    a1,    d1,     pi/2],  'standard');
L(2) = Link([pi/2, width, d2,    -pi],    'standard');
L(3) = Link([0,    width, d3,    -pi/2],  'standard');
L(4) = Link([0,    a2,    0,      pi/2],  'standard');
L(5) = Link([0,    0,     0,     -pi/2],  'standard');
L(6) = Link([0,    endeff, 0,     0],     'standard');

% Create serial link robot
Rob = SerialLink(L, 'name', 'kuka_clone');

%% Target Transformation Matrix
T = [0.3194  -0.9207   0.2241   150.7;
     0.9266   0.353    0.1294   87.0;
    -0.1983   0.1664   0.9659   274.3;
     0        0        0        1];

%% Inverse Kinematics
% Initial guess for joint angles
q0 = [0, pi/2, 0, 0, 0, 0];

% Target position and orientation mask
% [x, y, z, roll, pitch, yaw]
mask = [150.692, 87.002, 274.253, 70.9, 13.0, -7.9];

% Solve IK (convert result to degrees)
q_solution = Rob.ikine(T, 'q0', q0, 'm', mask);
q_deg = rad2deg(q_solution);

fprintf('\n=== Inverse Kinematics Solution ===\n');
fprintf('Joint 1: %.2f°\n', q_deg(1));
fprintf('Joint 2: %.2f°\n', q_deg(2));
fprintf('Joint 3: %.2f°\n', q_deg(3));
fprintf('Joint 4: %.2f°\n', q_deg(4));
fprintf('Joint 5: %.2f°\n', q_deg(5));
fprintf('Joint 6: %.2f°\n', q_deg(6));

%% Forward Kinematics Verification
T_fk = Rob.fkine(q_solution);
T_fk_matrix = T_fk.T;  % Extract transformation matrix from SE3 object

fprintf('\n=== Forward Kinematics Verification ===\n');
disp('Computed transformation matrix:');
disp(T_fk_matrix);

fprintf('\nPosition Error:\n');
fprintf('ΔX: %.4f mm\n', T(1,4) - T_fk_matrix(1,4));
fprintf('ΔY: %.4f mm\n', T(2,4) - T_fk_matrix(2,4));
fprintf('ΔZ: %.4f mm\n', T(3,4) - T_fk_matrix(3,4));

%% Visualization (uncomment to plot)

 Rob.plot(q_solution,'workspace', [-400 400 -400 400 -1 500]);
% Rob.teach();