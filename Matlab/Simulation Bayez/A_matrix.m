syms th d alpha a 

A = trotz(th)*transl(0,0,d)*transl(a,0,0)*trotx(alpha) 
%% link1 
syms th1 L1
A1 = subs(A,{a,alpha,d,th},{0,pi/2,L1,th1})

%% link2 
syms th2 L2 

A2 = subs(A,{a,alpha,d,th},{L2,pi/2,0,th2})

%% link3 
syms d3  

A3 = subs(A,{a,alpha,d,th},{0,0,d3,0})
%% Totall transformation matrix 
T13 = simplify(A1*A2*A3)


