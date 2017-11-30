%% load impulse response
load h_est
dim_h = length(h);

%% Set parameters
N = 1024/4; % DFT size = N_c
N_q = 4; % No of bits in 1 QAM Symbol
No_Trainingblocks = 100;
CP_length = dim_h*2;
SNRdB = inf;
fs = 16000;
x = linspace(0,fs,fs)';
pulse = sin(440*x*2*pi);

%% Generate training block
bitstream = randi([0, 1], (N/2-1)*N_q, 1);
trainblock = qam_mod(bitstream,N_q,false);

%% Generate relevant QAM_signal
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%% Make input bitstream correct length
% The length of the bitstream should be a multiple of N_q*N_valid
nb_QAM_symbols = length(bitStream)/N_q;
N_valid = N/2-1;
remainder = rem(nb_QAM_symbols,N_valid);

if (remainder ~= 0)
    nb_added = (N_valid-remainder)*N_q;
    bitStream_correct_size = [bitStream; zeros(nb_added,1)];
else
    nb_added = 0;
    bitStream_correct_size = bitStream;
end

P = length(bitStream_correct_size)/N_q/N_valid; % number of frames(columns) per packet

%% generate ofdm time domain signal
trainblocksequence = repmat(trainblock,No_Trainingblocks,1);
Tx = ofdm_mod(trainblocksequence,CP_length,No_Trainingblocks,N/2-1,[]);

%% Initparams
[simin,nbsecs,fs] = initparams(Tx,fs,pulse);

%% run simulink recplay
sim('recplay');

%% create output and align
out=simout.signals.values;
Rx_before = alignIO(out,pulse,fs);
Rx = Rx_before(1:length(Tx));

%% Convolution with transferfunction`
%Rx = fftfilt(h,Tx);
%Rx = Tx;

%% Channel
%rxOfdmStream_noise = awgn(Rx,SNRdB, 'measured');

%% OFDM demodulation
[rxQamStream, H_est] = ofdm_demod_ch_est(Rx,dim_h, trainblocksequence,CP_length,No_Trainingblocks,N/2-1,[],0,N_q,No_Trainingblocks);
figure();
plot(abs(fft(h,N))); hold on
ylim([0,1]);
Htot = [0;H_est(1:((N/2)-1));0;conj(H_est(((N/2)-1):-1:1))];
plot(abs(Htot));
h_estimated = ifft(Htot);
figure();
plot(h); hold on
plot(h_estimated);
%figure();
%plot(abs(rxQamStream),'Linewidth', 4); hold on; plot(abs(trainblocksequence),'LineWidth',2);xlim([0,100]);

%% QAM Demod

rxBitstream = qam_demod(rxQamStream,N_q);


%% BER

biterrrat = ber(bitstream,rxBitstream);

%% plot synchronized in and output

figure('Name','Time Domain Result');
load align;
plot(simin(:,1));hold on;
plot(out(-(delay+2*fs):end));
xlim([1,5*fs]);



