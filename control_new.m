clear all; 
close all;

% Busca los dispositivos de adquisicion disponibles
d = daq.getDevices;
% Crea una sesion nueva
session = daq.createSession(d(1).Vendor.ID);
% agrega los canales 0 y 1 de entrada analogica
[ch0, ch1] = addAnalogInputChannel(session,d(1).ID,[0 1],'Voltage');
% toma el canal dac0 como salida
session.addAnalogOutputChannel(d(1).ID,0,'Voltage');

% la frecuencia de operacion va a quedar determinada por la carga del
% sistema operativo y el hardware, por lo que una buena medida es ver
% cuanto le toma hacer las mediciones y sacar la salida de control.
delays = zeros(100,1);
for k = 1:100;
    a = tic();
    [d,t_s] = session.inputSingleScan; % demora aproximadamente 10ms
    session.outputSingleScan(1.2);
    delays(k) = toc(a);
end
f_operation = 0.5/max(delays);% Frecuencia a la que va a operar el sistema. 
                     % Debe determinarse en funcion de los retardos de
                     % lectura y escritura de la placa de adquisicion.
                     % Tomamos la mitad de dicha frecuencia para ser
                     % conservadores.

t_evaluation = 120;  % Tiempo de Adquisión [seg]

y = zeros(ceil(f_operation*t_evaluation)+2,1); % salida y referencia medida
r = y;
u = y; % señal de control a generar
t = y; % vector de tiempo 

k = 2; % variable que indexa los vectores de entrada / salida

% Mido el tiempo en el cual empiezo el ensayo
t_start = tic;

while (toc(t_start)< t_evaluation)
    t_sample = tic; % el instante real en que comienza la muestra
    [d,t_s] = session.inputSingleScan; % demora aproximadamente 10ms
    y(k) = d(1,1);
    r(k) = d(1,2);
    t(k) = toc(t_start);
    u(k) = 2*y(k)-1*y(k-1); % ecuacion de recurrencia
    if(u(k)>9)
        u(k) = 9;
    else
        if(u(k) < -9)
            u(k) = -9;
        end
    end
    session.outputSingleScan(u(k));
    k = k+1;
    while(toc(t_sample)<1/f_operation) 
        % espera a que pase el tiempo de muestreo. Idealmente, deberia
        % entrar al menos en una oportunidad por cada muestreo que ocurre
    end

end

%% corregimos el tamaño de los vectores con los datos efectivamente 
%  obtenidos o generados
y = y(2:k-1);
r = r(2:k-1);
t = t(2:k-1);
u = u(2:k-1);

figure;
subplot(3, 1, 1);
plot(t,y)
subplot(3, 1, 2);
plot(t,r)
subplot(3, 1, 3);
plot(t,u)