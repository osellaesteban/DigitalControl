clc; clear all; close all;

%La siguientes sentencias encuentra si hay un objeto de placa en ejecución
%y lo detiene
if (~isempty(daqfind))
    stop(daqfind)
end

N=1500;    %N cantidad de ciclos en el bucle FOR para hacer el control 
T=0.0182;   %T Período de muestreo para el sistema

%Creación de un objeto de entrada analógica.
ai0 = analoginput('dtol', 0); % Crea el objeto de ENTRADA analógica

%Las siguientes instrucciones crean y configuran las salidas digitales
% DTdio = digitalio('dtol',0);
% Rlines = addline (DTdio, 0:7, 'in');
% Wlines = addline (DTdio, 8:15, 'out');

% Agregado de canales para la entrada/salida analógica creadas
ai0.InputType = 'SingleEnded';
addchannel(ai0,[0 1]); % Con el segundo parámetro se selecciona la entrada del hardware a utilizar
% Entrada Analógica 0 es la consigna
%Entrada Analógica 1 es el sensor 

%Configurando la captura de la entrada analógica
set(ai0, 'BufferingMode', 'Auto')

% Configuración para disparar el trigger
% software trigger
set(ai0, 'TriggerType', 'Immediate'); % (Inmediate, Manual, Software)
set(ai0,'LoggingMode','Disk&Memory')

%Se crea un objeto de salida analogica de la placa.
ao0 = analogoutput('dtol', 0);
addchhanel (ao0, 0); %selecciono la salida 0

%Se crean vectores utilizados en el ciclo FOR con todos ceros para no
%ocupar punteros dinámicos de memoria 
error=zeros(1,N);
salida=zeros(1,N);
consigna=zeros(1,N);
pos_actual=zeros(1,N);

%Se crea y digitaliza el controlador diseñado
%COLOCAR ACÁ EL CONTROL EN EL PLANO S CREADO, SU TRANSFORMACION AL PLANO DIGITAL
%UTILIZAR T (período de muestreo) DEFINIDO AL PRINCIPIO DE LA PRESENTE RUTINA

s=tf('s');
%gc=...
%gcz=c2d(gc,T,'tustin') %Se trasnforma el compensador diseñado al plano Z
%[nn,dd,ts]=tfdata(gcz,'v'); %Obtiene los coeficientes de gcz 
% ...
% ...
% ...
% ...

%Comienza el ciclo de control
t=0:T:(N-1)*T;
tiempo_inicial=tic;
for i=3:N
tiempo_muestreo=tic;
entradas=getsample(ai0); %(columna 1 es consigna, columna 2 info sensor)

consigna(i)=entradas(1);
pos_actual(i)=entradas(2);
error(i)= consigna(i)-pos_actual(i);   

%COLOCAR ACÁ LA ECUACIÓN DE RECURRENCIA PARA EL COMPENSADOR DISEÑADO
% ...  salida(i)=..........
% ...  Utilizar los coeficientes de Gcz obtenido con tfdata en linea 48
% ...


%Los siguientes IF le ponen un máximo y mínimo a la salida para estar
%acorde a la placa conversora y las alimentaciones de todo el sistema
%(motor, sensor, etapa de potencia, etc)

if salida(i)>8     
    salida(i)=8;
end
if salida(i)<-8
    salida(i)=-8;
end


wait(ai0,1)
%SE carga la salida en una variable y se pasa a la salida analogica.
voltage = salida(i);
putsample(aout0,voltage);
wait(ao, 0.1)

periodo_muestreo(i)=toc(tiempo_muestreo);
tiempoReal(i)=toc(tiempo_inicial); 
end

%Cuando termino el ciclo de Control coloco un cero en la entrada de
%la etapa de potencia
voltage = 0;
putsample(aout0,voltage);
%Grafica de los valores de consigna y salida del sistema
plot(tiempoReal(3:N),consigna(3:N),tiempoReal(3:N),pos_actual(3:N),'r');

