clc; clear; close all;
a1 = 133.35;
d1 =37.5;
d2 = 160;
d3 = 14.84;
a2 = 141.07;
endeff = 0;
width=50;
%%
%My robot
% Link([theta, d, a, alpha])
L(1) = Link([0     a1       d1       pi/2]);            
L(2) = Link([pi/2     width    d2      -pi]);           
L(3) = Link([0     width    d3     -pi/2]);       
L(4) = Link([0     a2       0       pi/2]);            
L(5) = Link([0     0        0       -pi/2]);           
L(6) = Link([0     endeff  0       0]);   
%%
%Youtube
% Link([theta, d, a, alpha])
%L(1) = Link([0     a1       d1       -pi/2]);            
%L(2) = Link([-pi/2 -width    d2      0]);           
%L(3) = Link([pi    width   -d3     pi/2]);       
%L(4) = Link([0     a2       0       -pi/2]);            
%L(5) = Link([pi     0        0       pi/2]);           
%L(6) = Link([0     -endeff  0       pi]);           

Rob = SerialLink(L, 'name', 'RRRRR');
q=[0 pi/2 0 0 0 0];
%q = [30*pi/180 90*pi/180 45*pi/180 60*pi/180 20*pi/180 90*pi/180]; %theta 2 keda da el zero bta3ha
Rob.plot(q, 'workspace', [-400 400 -400 400 -1 500]);
T = Rob.fkine(q); disp(T);
% Sliders
Rob.teach;