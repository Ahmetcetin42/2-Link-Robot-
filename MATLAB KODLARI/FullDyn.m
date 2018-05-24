function [zdot, T1, T2] = FullDyn( t,z,p )

th1 = z(1);
th2 = z(3);
thdot1 = z(2);
thdot2 = z(4);


%son efektörde mevcut bozulma kuvveti
FxCurrent = p.Fx;
FyCurrent = p.Fy;

%Mevcut hedef
xCurrentTar = p.xtarget;
yCurrentTar = p.ytarget;

xdotCurrentTar = 0;
ydotCurrentTar = 0;

%Ýstenilen noktayý izlemek için tork
T = ImpedenceControl(p.Kd,p.Kp,p.l1,p.l2,th1,th2,thdot1,thdot2,xdotCurrentTar,xCurrentTar,ydotCurrentTar,yCurrentTar);

%Yer çekimi telafisi ekleme
T1 = T(1) + GravityCompT1(0,0,p.d1,p.d2,p.g,p.l1,p.l2,p.m1,p.m2,th1,th2,thdot1,thdot2);
T2 = T(2) + GravityCompT2(0,0,p.d2,p.g,p.l1,p.l2,p.m2,th1,th2,thdot1);

%Hýzlanma için otomatikleþtrilmiþ iþlev
thdotdot1 = Thdotdot1(FxCurrent,FyCurrent,p.I1,p.I2,T1,T2,p.d1,p.d2,p.g,p.l1,p.l2,p.m1,p.m2,th1,th2,thdot1,thdot2);
thdotdot2 = Thdotdot2(FxCurrent,FyCurrent,p.I1,p.I2,T1,T2,p.d1,p.d2,p.g,p.l1,p.l2,p.m1,p.m2,th1,th2,thdot1,thdot2);

%Durum vektör türevlerini birleþtirme
zdot = [thdot1
    thdotdot1
    thdot2
    thdotdot2
    ];

end

