
% Kullan�c�n�n t�klad��� noktay� taip eden 2 linkli robot.

clc; close all;

clear all;

rederive = false;
%%%%%%%% Sistem Parametreleri %%%%%%%%

%Ba�lang�� Ko�ullar�:
p.init = [pi/4    0.0    pi/4  0.0]';

p.g = 9.81;
p.m1 = 1; %link 1 k�tlesi.
p.m2 = 1; %link 2 k�tlesi.
p.l1 = 1; %Link 1'in toplam uzun�u.
p.l2 = 1; %Link 2'nin toplam uzunlu�u.
p.d1 = p.l1/2; %Link 1'in k�tle merkezi ile ba�lant� noktas� aras�ndaki mesafe.
p.d2 = p.l2/2; %Link 2'in k�tle merkezi ile ba�lant� noktas� aras�ndaki mesafe
p.I1 = 1/12*p.m1*p.l1^2; %Link 1 ba�lant� noktas�ndaki atalet momenti
p.I2 = 1/12*p.m2*p.l2^2; %Link 2 ba�lant� noktas�ndaki atalet momenti

endZ = ForwardKin(p.l1,p.l2,p.init(1),p.init(3));
x0 = endZ(1); %G�r�nt� i�erisindeki ba�lang�� pozisyonu.
y0 = endZ(2);
p.Fx = 0;
p.Fy = 0;

%%%%%%%% Denetleyici Parametreleri %%%%%%%%

%Denetleyici kazan�lar�
p.Kp = 10;
p.Kd = 8;

%Tek Hedef:
p.xtarget = x0; 
p.ytarget = y0;

%%%%%%%% deriveleri �al��t�r %%%%%%%%

if rederive
%Kazan� matrisini hen�z bulmad�ysa, sonra t�retmenin olmad���n� varsay�yoruz. 
        deriverRelativeAngles;
        disp('G�receli a��lardan �retilen hareket ve kontrol parametreleri denklemleri');
end

%%%%%%%% Birle�tirme %%%%%%%%

Plotter(p) 

