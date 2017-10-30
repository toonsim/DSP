%% Set parameters
dim_h = 100; % estimated length of impulse response
fs = 16000;

%% Create input vector x
delaysamples = dim_h*4;
siglength = 2+delaysamples/fs;

impulse = [1;zeros(delaysamples/2-1,1)]; %impulse for synchronization
sine = sin(880*pi*linspace(0,fs*delaysamples/2,delaysamples/2)');%sine for easy checking synchronization
noise_input = -ones(fs*2,1) + 2*rand([fs*2,1]);% white noise as signal

x = [impulse;sine;noise_input]; 

%% initialize parameters %% run simulink recplay %% create output
[simin,nbsecs,fs]=initparams(x,fs);
sim('recplay');
out=simout.signals.values;

%% find first start estimate
threshold = 1*max(abs(out(4:(2*fs))));
startest = 2*fs+find(abs(out(2*fs:end))>threshold,1);

%% optimize synchronization
start = Synchronize(x, out, startest,1000,delaysamples);

%% generate synchronized output signal & delayed output signal
outsync = out(start:(start+fs*siglength));
delay = 10;
noise_output = out((start+delaysamples):(start+siglength*fs));
IR1 = out((start-delay):(start-delay+dim_h));
y = out((start+dim_h+delay):(start+fs*siglength+delay),1);

%% plot synchronized in and output
samples = linspace(0,siglength,size(outsync, 1)-dim_h)';
figure('Name','Time Domain Result');
plot(samples,x(1:(end-dim_h+1)));hold on;
plot(samples,outsync(1:(end-dim_h)));
xlim([0,10/200]);

%% plot spectograms of input and output noise
figure('Name','Spectrogram');
dftsize = 513;
nbintervals = floor(size(noise_input,1)/dftsize); % approximately
windoww = floor(size(noise_input,1)/(nbintervals/2));


subplot(2,1,1);
[~,~,~,PSDin] = spectrogram(noise_input,windoww,[],dftsize,fs);
spectrogram(noise_input,windoww,[],dftsize,fs,'yaxis');

subplot(2,1,2);
[~,~,~,PSDout] = spectrogram(noise_output,windoww,[],dftsize,fs);
spectrogram(noise_output,windoww,[],dftsize,fs,'yaxis');

%% plot PSDs plot PSD input and output noise
PSDinavg = mean(PSDin, 2);
PSDoutavg = mean(PSDout, 2);
freqrange = linspace(0,fs/2,size(PSDinavg,1));
figure('Name','PSD');
subplot(2,1,1);semilogy(freqrange, PSDinavg);title('PSD Sent Signal');xlabel('Frequency [Hz]');ylabel('Power [dB]')
subplot(2,1,2);semilogy(freqrange, PSDoutavg);title('PSD Received Signal');xlabel('Frequency [Hz]');ylabel('Power [dB]')

%% plot response in time domain (1st method)
figure('Name','Time Domain  1st method');
plot(IR1);
title('Impulse Response in Time Domain');
xlabel('Samples');
ylabel('Signal');
xlim([0,dim_h]);
hold on;

%% plot magnitude of freq response (1st method)
fresp = fft(IR1);
Mfresp = abs(fresp(1:floor(length(fresp)/2),1)); %real signal -> only positive freq is enough

figure('Name','Frequency Domain 1st method');
freqrange = linspace(0,fs/2,size(Mfresp,1));
semilogy(freqrange, Mfresp);
title('Impulse Response in Frequency Domain');
xlabel('Frequency');
ylabel('Magnitude');


%% Create toeplitz matrix
c = x(dim_h:end,1);
r = x(dim_h:-1:1,1);
X = toeplitz(c,r);

%% Least squares' estimate of impulse response h
h = X\y;

%% Plot of time domain impulse response (2nd method)
figure('Name','Time Domain 2nd method');
plot(h);
title('Impulse Response in Time Domain');
xlabel('Samples');
ylabel('Signal');

%% Plot magnitude frequency response (2nd method)
fresp = fft(h);
Mfresp = abs(fresp(1:floor(length(fresp)/2),1));
figure('Name','Frequency Domain 2nd Method');

freqrange = linspace(0,fs/2,size(Mfresp,1));
semilogy(freqrange, Mfresp);
title('Impulse Response in Frequency Domain');
xlabel('Frequency');
ylabel('Magnitude');