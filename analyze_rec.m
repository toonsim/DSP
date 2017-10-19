%% set parameters
fs = 16000;
sig = -ones(fs*2,1) + 2*rand([fs*2,1]); 
dftsize = 513;
nbintervals = floor(size(simin,1)/dftsize);
%% initialize parameters
[simin,nbsecs,fs]=initparams(sig,fs);
%% run simulink recplay
sim('recplay');
%% create and play output
out=simout.signals.values;
soundsc(out, fs);
%% plot spectograms
figure('Name','Spectrogram');

subplot(2,1,1);
[~,~,~,PSDin] = spectrogram(simin(:,1),window,[],dftsize,fs);

window = floor(size(simin(:,1),1)/nbintervals);

spectrogram(simin(:,1),window,[],dftsize,fs,'yaxis');

subplot(2,1,2);
[~,~,~,PSDout] = spectrogram(out,window,[],dftsize,fs);
spectrogram(out,window,[],dftsize,fs,'yaxis');
%% plot PSDs
PSDinavg = mean(PSDin, 2);
PSDoutavg = mean(PSDout, 2);
freqrange = linspace(0,fs/2,size(PSDinavg,1));
figure('Name','PSD');
subplot(2,1,1);semilogy(freqrange, PSDinavg);title('PSD Sent Signal');xlabel('Frequency [Hz]');ylabel('Power [dB]')
subplot(2,1,2);semilogy(freqrange, PSDoutavg);title('PSD Received Signal');xlabel('Frequency [Hz]');ylabel('Power [dB]')