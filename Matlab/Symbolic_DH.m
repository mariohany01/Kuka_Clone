% --- SETUP ---
clc;         % Clear command window
clear;       % Clear workspace variables
close all;   % Close all figures

% --- SYMBOLIC ANALYSIS ---
fprintf('--- Symbolic Forward Kinematics ---\n\n');

% Define symbolic variables for joints and parameters
syms theta1 theta2 theta3 theta4 theta5 theta6 % Joint variables
syms a1_s a2_s d1_s d2_s d3_s endeff_s width_s  % Link parameters

L_sym(1) = Link([theta1          a1_s      d1_s       pi/2]);            % R
L_sym(2) = Link([theta2+pi/2     width_s   d2_s       -pi]);            % R
L_sym(3) = Link([theta3          width_s   d3_s       -pi/2]);       % Ghayar L3 le d3
L_sym(4) = Link([theta4          a2_s      0          pi/2]);            % R
L_sym(5) = Link([theta5          0         0          -pi/2]);            % R
L_sym(6) = Link([theta6          endeff_s  0           0]);            % R

% Create the symbolic robot model
Rob_sym = SerialLink(L_sym, 'name', 'Symbolic RRRRRR');

% Define the symbolic joint variable vector
q_sym = [theta1 theta2 theta3 theta4 theta5 theta6];

% Calculate the symbolic forward kinematics transformation matrix
T_sym = Rob_sym.fkine(q_sym);

% Extract the 4x4 matrix from the symbolic SE3 object before displaying
disp('Not Simple Symbolic Transformation Matrix (T):');
T_matrix_sym = T_sym.T

% Display the simplified symbolic transformation matrix
disp('Symbolic Transformation Matrix (T):');
disp(simplify(T_matrix_sym));


a1 = 133.35;
d1 =37.5;
d2 = 160;
d3 = 14.84;
a2 = 141.07;
endeff = 0;
width=50;

% Link([theta, d, a, alpha])
%El le3b fel alpha ele ablaha bykhaly d ele ba3daha makanha yetghayar
L(1) = Link([0     a1     d1        pi/2]);            % R
L(2) = Link([pi/2     width      d2       -pi]);            % R
L(3) = Link([0      width     d3       -pi/2]);       % Ghayar L3 le d3
L(4) = Link([0      a2     0     pi/2]);            % R
L(5) = Link([0      0      0    -pi/2]);            % R
L(6) = Link([0       endeff    0     0]);            % R

Rob = SerialLink(L, 'name', 'RRRRR');
q=[0 pi/2 0 0 0 0];
%q = [30*pi/180 -45*pi/180 0.2 60*pi/180 20*pi/180 90*pi/180];
Rob.plot(q, 'workspace', [-400 400 -400 400 -1 500]);
T = Rob.fkine(q); disp(T);
% Sliders
Rob.teach;