clear all; 
close all;
fm=2000;   % Frecuencia de muestreo (60-50000 Hz)
tiempo=20;  %Tiempo de Adquisión
iter = 5;
%La siguientes sentencias encuentra si hay un objeto de placa en ejecución
%y lo detiene
d = daq.getDevices;
session = daq.createSession(d(1).Vendor.ID);

[ch0, ch1] = addAnalogInputChannel(session,d(1).ID,[0 1],'Voltage');

session.Rate = fm;
session.DurationInSeconds = tiempo;

for k = 1:iter
    [d,t] = session.startForeground;
    test(k).values = d;
    test(k).time = t;
end
