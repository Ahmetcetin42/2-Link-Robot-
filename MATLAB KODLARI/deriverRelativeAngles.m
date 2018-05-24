%Çift sarkaç dinamiði türetmek

%Sembolik parametreler
syms m1 m2 I1 I2 g l1 l2 d1 d2 th1 th2 thdot1 thdot2 thdotdot1 thdotdot2 er1 er2 eth1 eth2 T1 T2 real

%Birim vektör
i = [1 0 0]';
j = [0 1 0]';
k = [0 0 1]';

%referans çevresinde döndürme
er1 = [-sin(th1), cos(th1), 0]'; 
er2 = [-sin(th2+th1), cos(th2+th1), 0]';

eth1 = [-cos(th1),-sin(th1),0]';
eth2 = [-cos(th2+th1),-sin(th2+th1),0]';

%Önemli noktalara vektörler
ra_c1 = d1*er1; %A sabit nokta, B dirsek, c1 ve c2 COM'lar
rb_c2 = d2*er2;
rb_e = l2*er2;
ra_b = l1*er1;
ra_c2 = ra_b + rb_c2;
ra_e = ra_b + rb_e;

matlabFunction(ra_e, 'file', 'ForwardKin');

%hýzlar
Vc1 = d1*thdot1*eth1;
VB = l1*thdot1*eth1;
Vc2 = VB + d2*(thdot2+thdot1)*eth2;
Ve = VB + l2*(thdot2+thdot1)*eth2;

%ivmeler
Ac1 = d1*thdotdot1*eth1 - d1*thdot1^2*er1;
AB = l1*thdotdot1*eth1 - l1*thdot1^2*er1;
Ac2 = d2*(thdotdot2+thdotdot1)*eth2 - d2*(thdot1 + thdot2)^2*er2  + AB;

%son efektördeki kuvvet
syms Fdx Fdy real
Fd = [Fdx, Fdy, 0]';


M_B = cross(rb_c2,-m2*g*j)+T2*k     + cross(rb_e,Fd); 
Hdot2 = I2*(thdotdot2+thdotdot1)*k + cross(rb_c2, m2*Ac2);

eqn2forthdotdot2 = solve(dot(Hdot2 - M_B,k),thdotdot2);


M_A = cross(ra_c2,-m2*g*j) + cross(ra_c1,-m1*g*j) + T1*k + cross(ra_e,Fd); 
Hdot1 = I2*(thdotdot2+thdotdot1)*k + cross(ra_c2, m2*Ac2) + I1*thdotdot1*k + cross(ra_c1, m1*Ac1);

eqn1forthdotdot1 = solve(dot(Hdot1 - M_A,k),thdotdot1);


eqn2 = simplify(solve(subs(eqn2forthdotdot2, thdotdot1, eqn1forthdotdot1)-thdotdot2,thdotdot2));
eqn1 = simplify(solve(subs(eqn1forthdotdot1, thdotdot2, eqn2forthdotdot2)-thdotdot1,thdotdot1));

%Thdotdot1 ve 2 için matlab iþlevleri oluþturma
matlabFunction(eqn1, 'file', 'Thdotdot1');
matlabFunction(eqn2, 'file', 'Thdotdot2');

%Yerçekimi telafisi

T2Eq = simplify(solve((solve(eqn1,T1)-solve(eqn2,T1)),T2));

T1Eq = simplify(subs(solve(eqn1,T1),T2,T2Eq));

matlabFunction(T1Eq, 'file', 'GravityCompT1');
matlabFunction(T2Eq, 'file', 'GravityCompT2');



%Jacobian bitiþ efektör hýzýný eklem uzayýna baðladý

J = jacobian(Ve,{thdot1 thdot2});

syms Kp Kd xt yt xdott ydott real

zt = [xt yt 0 ]'; %zlenen yörünge
ztdot = [xdott ydott 0]'; %izlenen hýz

Ta = J'*(Kp*(zt - ra_e) + Kd*(ztdot - J*[thdot1 thdot2]'));

matlabFunction(Ta, 'file', 'ImpedenceControl');




