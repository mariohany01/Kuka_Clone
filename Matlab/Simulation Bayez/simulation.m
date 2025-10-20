d1 = 2
d3 = 2
d4 = 2
a2 = 2


% create link using this code
% L = link([Th d a alpha])

L(1) = Link([0 d1 0 pi/2])
L(1).qlim = [-pi/2 pi/2]

L(2) = Link([0 0 a2 0])
L(2).qlim = [-pi/2 pi/2]

L(3) = Link([0 -d3 0 pi/2])
L(3).qlim = [-pi/2 pi/2]

L(4) = Link([0 d4 0 -pi/2])
L(4).qlim = [-pi/2 pi/2]

L(5) = Link([0 0 0 pi/2])
L(5).qlim = [-pi/2 pi/2]

L(6) = Link([0 0 0 0])
L(6).qlim = [-pi/2 pi/2]


Rob = SerialLink(L,'name','R')
Rob.plot([0 0 0 0 0 0],'workspace',[-5 5 -5 5 -5 5])
Rob.teach

	%% Compute the forward kinematic of the initial pose
	th1 = 0;
	th2 = 0;
	th3 = 0;
 
	Ti = Rob.fkine([th1 th2 th3])
    
    %% Simulate the path

for th = 0:0.1:pi/2
     Rob.plot([0 th 0],'workspace',[-4 4 -4 4 -4 4])
     pause(0.1)
end



