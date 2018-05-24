
function Plotter(p)
close all

%Playback speed:
% playback = p.animationSpeed;

%Name the whole window and define the mouse callback function
f = figure;
set(f,'WindowButtonMotionFcn','','WindowButtonDownFcn',@ClickDown,'WindowButtonUpFcn',@ClickUp,'KeyPressFc',@KeyPress);

figData.xtarget = [];
figData.ytarget = [];
figData.Fx = [];
figData.Fy = [];
figData.xend = [];
figData.yend = [];
figData.fig = f;
figData.tarControl = true;

%%%%%%%% Sarkaç animasyonu %%%%%%%
figData.simArea = subplot(1,1,1); 
axis equal
hold on

%Link 1 nesnesini oluþturma:
width1 = p.l1*0.05;
xdat1 = 0.5*width1*[-1 1 1 -1];
ydat1 = p.l1*[0 0 1 1];
link1 = patch(xdat1,ydat1, [0 0 0 0],'r');

%Link 2 nesnesini oluþturma:
width2 = p.l2*0.05;
xdat2 = 0.5*width2*[-1 1 1 -1];
ydat2 = p.l2*[0 0 1 1];
link2 = patch(xdat2,ydat2, [0 0 0 0],'b');
axis([-3.5 3.5 -3.6 3.6]);

%Birleþim yerindeki noktalar:
h1 = plot(0,0,'.k','MarkerSize',40); 
h2 = plot(0,0,'.k','MarkerSize',40); 

%zamanlayýcýnýn gösterimi:
timer = text(-3.2,-3.2,'0.00','FontSize',28);

%Ekrandaki tork ölçer
tmeter1 = text(0.6,-3.2,'0.00','FontSize',22,'Color', 'r');
tmeter2 = text(2.2,-3.2,'0.00','FontSize',22,'Color', 'b');

%Hedef.
targetPt = plot(p.xtarget,p.ytarget,'xr','MarkerSize',30);

hold off

%Kullanýþlý görüntülemek için tüm pencereyi büyük yapma:
set(f, 'units', 'inches', 'position', [5 5 10 9])
set(f,'Color',[1,1,1]);

% Ekseni çevirmek
ax = get(f,'Children');
set(ax,'Visible','off');


z1 = p.init;
told = 0;

set(f,'UserData',figData);

tic %saati baþlat
while (ishandle(f))
    figData = get(f,'UserData');
    %%%% Birleþtirme %%%%
    tnew = toc;
    dt = tnew - told;
    
    %Eski hýz ve pozisyon
    xold = [z1(1),z1(3)];
    vold = [z1(2),z1(4)];
   
  
    [zdot1, T1, T2] = FullDyn(tnew,z1,p);
    vinter1 = [zdot1(1),zdot1(3)];
    ainter = [zdot1(2),zdot1(4)];
    
    vinter2 = vold + ainter*dt; %Eski RHS çaðrýsýna dayalý güncelleme hýzý
    
    %Pozisyonu güncelleme
    xnew = xold + vinter2*dt;
    vnew = (xnew-xold)/dt;
    
    z2 = [xnew(1) vnew(1) xnew(2) vnew(2)];

    z1 = z2;
    told = tnew;
    %%%%%%%%%%%%%%%%%%%%
    
    %Yeni fare týklamasý yerleri varsa, bunlarý yeni olarak ayarla
    %Hedef.
    if ~isempty(figData.xtarget)
    p.xtarget = figData.xtarget;
    end
    
    if ~isempty(figData.ytarget)
    p.ytarget = figData.ytarget;
    end
    set(targetPt,'xData',p.xtarget); %Hedef noktayý grafik olarak deðiþtirme
    set(targetPt,'yData',p.ytarget);
    
    %Bir tuþa bastýðýmýzda, farenin þeyleri çekeceði güç moduna geçer
    ra_e = ForwardKin(p.l1,p.l2,z1(1),z1(3));
    figData.xend = ra_e(1);
    figData.yend = ra_e(2);
    set(f,'UserData',figData);
    
    if ~isempty(figData.Fx)
    p.Fx = figData.Fx;
    end
    if ~isempty(figData.Fy)
    p.Fy = figData.Fy;
    end
    
    tstar = told; %Zaman ayýr (tüm yinelemeler sýrasýnda kullanýlýr.)
    
    %On screen timer.
    set(timer,'string',strcat(num2str(tstar,3),'s'))
    zstar = z1;; %Bu andaki verileri anýnda enterpole yapar.
    
    %Nesnelerin köþe noktalarýný deðiþtirmek için döndürme matrisleri
    %çýkýþ durum vektörlerinden theta 1 ve theta 2 kullanacak
    rot1 = [cos(zstar(1)), -sin(zstar(1)); sin(zstar(1)),cos(zstar(1))]*[xdat1;ydat1];
    set(link1,'xData',rot1(1,:))
    set(link1,'yData',rot1(2,:))
    
    rot2 = [cos(zstar(3)+zstar(1)), -sin(zstar(3)+zstar(1)); sin(zstar(3)+zstar(1)),cos(zstar(3)+zstar(1))]*[xdat2;ydat2];
    
    set(link2,'xData',rot2(1,:)+(rot1(1,3)+rot1(1,4))/2) %Ýlk baðlantýnýn uzak kenarýnýn orta noktasýný, baðlantý 2'deki tüm noktalara eklemek istiyoruz.
    set(link2,'yData',rot2(2,:)+(rot1(2,3)+rot1(2,4))/2)
    
    %Menteþenin nokta konumunu deðiþtirme
    set(h2,'xData',(rot1(1,3)+rot1(1,4))/2)
    set(h2,'yData',(rot1(2,3)+rot1(2,4))/2)
    
    %Sdaha sonraki zamanlar için ekranda torku gösterme
    set(tmeter1,'string',strcat(num2str(T1,2),' Nm'));
    set(tmeter2,'string',strcat(num2str(T2,2),' Nm'));
    
    drawnow;
end
end

%%%% Mouse ve klavye için baþlangýç çaðrýsý %%%%%

% Týklama gerçekleþtiði zaman fare hareketini algýlamayý devre dýþý býrakma
function ClickUp(varargin)
    figData = get(varargin{1},'UserData');
    set(figData.fig,'WindowButtonMotionFcn','');
    figData.Fx = 0;
    figData.Fy = 0;
    set(varargin{1},'UserData',figData);
end

% Týklama oluþtuðunda fare hareketini algýlamasýný geri çagýrma sa
function ClickDown(varargin)
    figData = get(varargin{1},'UserData');
    figData.Fx = 0;
    figData.Fy = 0;

    set(figData.fig,'WindowButtonMotionFcn',@MousePos);
    set(varargin{1},'UserData',figData);
end


function KeyPress(hObject, eventdata, handles)

figData = get(hObject,'UserData');

figData.tarControl = ~figData.tarControl;

    if figData.tarControl
       disp('Mouse will change the target point of the end effector.')
    else
       disp('Mouse will apply a force on end effector.') 
    end
set(hObject,'UserData',figData);
end

% 	Fare konumunu kontrol eder ve geri bildirir.
function MousePos(varargin)
    figData = get(varargin{1},'UserData');

    mousePos = get(figData.simArea,'CurrentPoint');
    if figData.tarControl
        figData.xtarget = mousePos(1,1);
        figData.ytarget = mousePos(1,2);
    else
        figData.Fx = 10*(mousePos(1,1)-figData.xend);
        figData.Fy = 10*(mousePos(1,2)-figData.yend);
    end
     set(varargin{1},'UserData',figData);
end