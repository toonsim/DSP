%% Generate impuls sound
fs = 16000;
nbsecs = 1;
impuls = [1; zeros(fs*nbsecs - 1,1)];
%% initialize parameters
[simin,nbsecs,fs]=initparams(impuls,fs);
%% run simulink recplay
sim('recplay');
%% create output
out=simout.signals.values;
%% get relevant output
[~,startest] = max(out);
startest = startest - 10;
outrel = out(startest:end);
%% set impulse response length estimate
dim_h = 100;
%% plot response in time domain
figure('Name','Time Domain  1st method');
plot(outrel);
title('Impulse Response in Time Domain');
xlabel('Samples');
ylabel('Signal');
xlim([0,dim_h]);
hold on;

%% plot magnitude of freq response
fresp = fft(outrel(1:(dim_h+1)));
Mfresp = abs(fresp(1:floor(end/2),1)); %real signal -> only positive freq is enough

figure('Name','Frequency Domain 1st method');
freqrange = linspace(0,fs/2,size(Mfresp,1));
semilogy(freqrange, Mfresp);
title('Impulse Response in Frequency Domain');
xlabel('Frequency');
ylabel('Magnitude');


