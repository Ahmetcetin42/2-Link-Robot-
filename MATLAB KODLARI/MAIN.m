
% Kullanýcýnýn týkladýðý noktayý taip eden 2 linkli robot.

clc; close all;

clear all;

rederive = false;
%%%%%%%% Sistem Parametreleri %%%%%%%%

%Baþlangýç Koþullarý:
p.init = [pi/4    0.0    pi/4  0.0]';

p.g = 9.81;
p.m1 = 1; %link 1 kütlesi.
p.m2 = 1; %link 2 kütlesi.
p.l1 = 1; %Link 1'in toplam uzunðu.
p.l2 = 1; %Link 2'nin toplam uzunluðu.
p.d1 = p.l1/2; %Link 1'in kütle merkezi ile baðlantý noktasý arasýndaki mesafe.
p.d2 = p.l2/2; %Link 2'in kütle merkezi ile baðlantý noktasý arasýndaki mesafe
p.I1 = 1/12*p.m1*p.l1^2; %Link 1 baðlantý noktasýndaki atalet momenti
p.I2 = 1/12*p.m2*p.l2^2; %Link 2 baðlantý noktasýndaki atalet momenti

endZ = ForwardKin(p.l1,p.l2,p.init(1),p.init(3));
x0 = endZ(1); %Görüntü içerisindeki baþlangýç pozisyonu.
y0 = endZ(2);
p.Fx = 0;
p.Fy = 0;

%%%%%%%% Denetleyici Parametreleri %%%%%%%%

%Denetleyici kazançlarý
p.Kp = 10;
p.Kd = 8;

%Tek Hedef:
p.xtarget = x0; 
p.ytarget = y0;

%%%%%%%% deriveleri çalýþtýr %%%%%%%%

if rederive
%Kazanç matrisini henüz bulmadýysa, sonra türetmenin olmadýðýný varsayýyoruz. 
        deriverRelativeAngles;
        disp('Göreceli açýlardan üretilen hareket ve kontrol parametreleri denklemleri');
end

%%%%%%%% Birleþtirme %%%%%%%%

Plotter(p) 

