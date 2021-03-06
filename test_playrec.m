%% set fs
fs = 16000;
%% generate sinewave
siglength = 2; % 2 seconds
x = linspace(0,siglength,fs*siglength)';
sinewave = sin(2*pi*440*x);
%% initialize parameters
[simin,nbsecs,fs]=initparams(sinewave,fs);
%% run simulink recplay
sim('recplay');
%% create and play output
out=simout.signals.values;
soundsc(out, fs);
%% Optional: plot signals
time = linspace(0,5,5*fs)';
subplot(2,1,1);plot(time, simin);
subplot(2,1,2);plot(time, out(129:end,1));


