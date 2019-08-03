clear
tic
%format long
elem=64; %cantidad de antenas
z=1;  %/individuos
esp=10;  %es el espacio asicnado para las antenas   mxn
puntos=250;     %resolucion para el af
rsl=esp/.125;  %resolucion de la malla 
%%%%%%%%%%%%%%%%%%%%%matriz de posiciones%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in=zeros(rsl,rsl,z);%round(rand(80,80))
amp=zeros(rsl,rsl,z);

for  b=1:z
    s=0;
    while s<(elem) %aqui se define el numero de antenas
     ubx=round ((rand()*(rsl-9))+5);
     uby=round ((rand()*(rsl-9))+5);
     rango=sum(sum(in(ubx-4:ubx+4,uby-4:uby+4,b)));
        if rango<1 %considera solo una anten  para el espacio asicgnado
        ampli= (rand()*10)-5;  %;
        in(ubx,uby,b)=1;
        amp(ubx,uby,b)=ampli;
        s=sum(sum(in(:,:,b)));
        end
    end
end

%%%%%%%%%%%%%%%%%%%Graficas %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pi=3.14159;
puntos=499;  
linea=linspace(-90,90,puntos);   

tabla=zeros(rsl,rsl);
for a=1:rsl  % tabla de distancias para maya
tabla(a,:)=0.125:.125:esp;
end
 posiciones_x=zeros(1,elem);
 posiciones_y=zeros(1,elem);
 amplitudes=zeros(1,elem);
 posiciones_x1=in.*tabla;
 posiciones_y1=in.*tabla'; 
cont=0;
 for a=1:rsl^2
     if  in(a)==1
         cont=cont+1;
         posiciones_x(cont)= posiciones_x1(a);
         posiciones_y(cont)= posiciones_y1(a);
         amplitudes(cont)= amp(a);
     end
 end

puntos_teta=499;     
puntos_phi=499;
rango_teta=pi; 
%rango_phi=pi;  
phi=linspace(-pi,pi,puntos_phi);  %genera valores para phi y teta
teta=linspace(-pi/2,rango_teta/2,puntos_teta); 

part_real=0;
part_imag=0;
u=zeros(puntos);
v=zeros(puntos);
w=zeros(puntos);
for k=1:puntos_teta
  u(k,1:puntos_teta)=sin(teta)*cos(phi(k));
  v(k,1:puntos_teta)=sin(teta)*sin(phi(k));
  w(k,1:puntos_teta)=cos(teta);
end

for num_elemento=1:elem  %obten AF
  r=(posiciones_x(num_elemento))*u+(posiciones_y(num_elemento))*v;
  fasetotal=2*pi*(r);
  part_real=part_real+amplitudes(num_elemento)*cos(fasetotal);
  part_imag=part_imag+amplitudes(num_elemento)*sin(fasetotal);  
end

af=abs(part_real+1i*part_imag);       
xc=zeros(1,puntos);
  for sd=1:puntos
     xc(1,sd)=mean(af(:,sd));
   end
   xv=xc/max(xc);
   figure()
   plot(linea,xv)
   
figure()
mesh((af).*u,(af).*v,(af).*w)                    %grafica AF 
title('AF')
xlabel('eje x')
ylabel('eje y')
zlabel('eje z')
figure()

mesh(180*teta/pi,180*phi/pi,20*log10(af/max(max(af))))
xlabel('Elevacion \theta')
ylabel('Azimutal \phi')
zlabel('AF(dB)')
zlim([-80 0])
xlim([-90 90])
ylim([-180 180])
%---fin de GRAFICAS I

%OBTEN SLL (nivel del lobulo lateral)
AF22=af;

for b=1:ceil(puntos_phi/2)
AF2=af(b,:);
max(AF2(195:ceil(puntos_teta/2)));
muestra_max_teta=find(ans==AF2(1:ceil(puntos_teta/2))); %#ok<NOANS>
muestramax=muestra_max_teta(1);
muestramax2=muestramax;                     

if(muestramax>1 && muestramax<ceil(puntos_teta/2)) 
AFdescenso_izq=AF2(muestramax-1);          
else
AFdescenso_izq=0; 
end
           
while(AF2(muestramax)>AFdescenso_izq || muestramax==1)
    if(muestramax==1)                         
    AF2(muestramax)=0;                 
     muestramax=ceil(puntos_teta/2);           
    end                                 
       
    AF2(muestramax)=0;                    
    muestramax=muestramax-1; 
    if(muestramax>1 && muestramax<ceil(puntos_teta/2))
    AFdescenso_izq=AF2(muestramax-1);
    end
    
end

if(muestramax2<ceil(puntos_teta/2))                   
muestramax2=muestramax2+1;                      
else
muestramax2=1;
end

if(muestramax2>1 && muestramax2<ceil(puntos_teta/2))
AFdescenso_der=AF2(muestramax2+1);         
else
AFdescenso_der=0;
end

while(AF2(muestramax2)>AFdescenso_der || muestramax2==ceil(puntos_teta/2))    
    if(muestramax2==ceil(puntos_teta/2))               
     AF2(muestramax2)=0;                                              
    break;
    end
    
    AF2(muestramax2)=0;                     
    muestramax2=muestramax2+1;
    if(muestramax2>1 && muestramax2<ceil(puntos_teta/2))
    AFdescenso_der=AF2(muestramax2+1);
    end
end
SLL(b)=max(AF2(1:ceil(puntos_teta/2)));
 if(SLL(b)==0)
   SLL(b)=max(af(b,1:180));
 end
AF22(b,:)=AF2;
end

SLL=max(SLL);
af_norm=af/max(max(af));         %#ok<NASGU> %Normalizacion
SLL_norm=SLL/max(max(af));
SLL_norm_db=20*log10(SLL_norm) %#ok<NOPRT,NASGU>

%%%%%%%%%%%%%%%%% Diseño de antena%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tabla=zeros(rsl,rsl);
for a=1:rsl  % tabla de distancias para maya
tabla(a,:)=0.125:.125:esp;
end
[m,n]=size(in);
 posiciones_x=in.*tabla;
 posiciones_y=in.*tabla'; 
IMAG = sqrt(-1);
ph = 0:.02:2*pi;
figure();
hold on;
   for i=1:n*m % grafica la posicion de las antenas en la apertura
       if in(i)==1
      plot(posiciones_x(i),posiciones_y(i),'k. ');
      plot(posiciones_x(i)+IMAG*posiciones_y(i)+.25*exp(IMAG*ph),'g:');      
       end     
  end
%%---fin de GRAFICAS I





