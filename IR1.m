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
outrel = out(startest:end,:);
%% plot response
samples = linspace(0,nbsecs*fs-startest,size(outrel, 1))';
plot(samples,outrel);
delayest = startest - 2*fs;
% the estimated impulse response time = 400samples * fs = 0.025
%% plot magnitude of freq response
fresp = fft(outrel);
Mfresp = abs(fresp(0:(end/2),1));
freqrange = linspace(0,fs/2,size(Mfresp,1));
semilogy(freqrange, Mfresp);


