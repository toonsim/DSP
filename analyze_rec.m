%% set parameters
fs = 16000;
sig = -ones(fs*2,1) + 2*rand([fs*2,1]); 
dftsize = 513;
%% initialize parameters
[simin,nbsecs,fs]=initparams(sig,fs);
%% run simulink recplay
sim('recplay');
%% create and play output
out=simout.signals.values;
soundsc(out, fs);
%% plot spectograms
figure('Name','Spectrogram');
nbintervals = floor(size(simin,1)/dftsize); %isn't corect because of overlap -> approximation
windoww = floor(size(simin(:,1),1)/nbintervals);

subplot(2,1,1);
[~,~,~,PSDin] = spectrogram(simin(:,1),windoww,[],dftsize,fs);
spectrogram(simin(:,1),windoww,[],dftsize,fs,'yaxis');

subplot(2,1,2);
[~,~,~,PSDout] = spectrogram(out,windoww,[],dftsize,fs);
spectrogram(out,windoww,[],dftsize,fs,'yaxis');
%% plot PSDs
PSDinavg = mean(PSDin, 2);
PSDoutavg = mean(PSDout, 2);
freqrange = linspace(0,fs/2,size(PSDinavg,1));
figure('Name','PSD');
subplot(2,1,1);semilogy(freqrange, PSDinavg);title('PSD Sent Signal');xlabel('Frequency [Hz]');ylabel('Power [dB]')
subplot(2,1,2);semilogy(freqrange, PSDoutavg);title('PSD Received Signal');xlabel('Frequency [Hz]');ylabel('Power [dB]')