clc; clear; close all;
    
    a1 = 135.3;
    d1 =37.5;
    d2 = 160;
    d3 = 15;
    a2 = 137.3;
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

%create robot esmo rob equal serial link L ele houa Links ele fo2 
Rob = SerialLink(L, 'name','kuka_clone');

Rob




T = [      0.3194   -0.9207   0.2241    150.7;
           0.9266    0.353    0.1294    87;
          -0.1983   0.1664   0.9659    274.3;
           0         0        0         1];




I_kine = Rob.ikine(T,'q0',[0 pi/2 0 0 0 0],'m',[150.692 87.002 274.253 70.9 13.0 -7.9])*180/pi
F_kine = Rob.fkine(I_kine);

%Rob.plot
