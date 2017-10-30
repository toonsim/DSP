%% Set parameters
dim_h = 50; % estimated length of impulse response
fs = 16000;
%% Create input vector x
delaysamples = dim_h*4;
siglength = 2+delaysamples/fs;

impulse = [1;zeros(delaysamples/2-1,1)]; %impulse for synchronization
sine = sin(880*pi*linspace(0,fs*delaysamples/2,delaysamples/2)');%sine for easy checking synchronization
sig = -ones(fs*2,1) + 2*rand([fs*2,1]);% white noise as signal

x = [impulse;sine;sig]; 
%% Create toeplitz matrix
c = x(dim_h:end,1);
r = x(dim_h:-1:1,1);
X = toeplitz(c,r);
%% initialize parameters
[simin,nbsecs,fs]=initparams(x,fs);
%% run simulink recplay
sim('recplay');
%% create output
out=simout.signals.values;
%% find first start estimate
threshold = 0.4;
startest = 2*fs+find(abs(out(2*fs:end))>threshold,1);
%% optimize synchronization
start = Synchronize(x, out, startest,10,fs/4);
%% generate synchronized output signal & delayed output signal
outsync = out(start:(start+fs*siglength));
delay = 1;
y = out((start+dim_h+delay):(start+fs*siglength+delay),1);
%% plot synchronized in and output
samples = linspace(0,siglength,size(outsync, 1)-dim_h)';
figure('Name','Time Domain Result');
plot(samples,x(1:(end-dim_h+1)));hold on;
plot(samples,outsync(1:(end-dim_h)));
xlim([0,10/200]);
%% Least squares' estimate of impulse response h
h = X\y;
%% plot delayed output
figure();
plot(x);hold on;plot([zeros(dim_h+delay,1);y])
xlim([0,1600]);
figure();
plot([zeros(dim_h+delay,1);X*h]);hold on;plot(y);
xlim([0,1600]);
%% save the impulse response in IRest.mat
save IRest h;
%% Plot of time domain impulse response
figure('Name','Time Domain 2nd method');
plot(h);
title('Impulse Response in Time Domain');
xlabel('Samples');
ylabel('Signal');
%% Plot magnitude frequency response
fresp = fft(h);
Mfresp = abs(fresp(1:floor(end/2),1));
figure('Name','Frequency Domain 2nd Method');

freqrange = linspace(0,fs/2,size(Mfresp,1));
semilogy(freqrange, Mfresp);
title('Impulse Response in Frequency Domain');
xlabel('Frequency');
ylabel('Magnitude');

