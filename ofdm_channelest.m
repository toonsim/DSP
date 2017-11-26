%% load impulse response
load IRest
dim_h = length(h);
%% Set parameters
N = 200; % DFT size = N_c
N_q = 5; % No of bits in 1 QAM Symbol
No_Trainingblocks = 100;
CP_length = dim_h*2;
SNRdB = inf;

%% Generate training block
bitstream = randi([0, 1], (N/2-1)*N_q, 1);
trainblock = qam_mod(bitstream,N_q,false);

%% Generate relevant QAM_signal
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%% Make input bitstream correct length
% The length of the bitstream should be a multiple of N_q*N_valid
nb_QAM_symbols = length(bitStream)/N_q;
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

%% Convolution with transferfunction
Rx = fftfilt(h,Tx);
%Rx = Tx;

%% Channel
rxOfdmStream_noise = awgn(Rx,SNRdB, 'measured');

%% OFDM demodulation
[rxQamStream, H_est] = ofdm_demod_ch_est(rxOfdmStream_noise,dim_h, trainblocksequence,CP_length,P,N/2-1,[],0,N_q,No_Trainingblocks);

plot(abs(H_est));ylim([0,1]);
Htot = [0;H_est(1:((N/2)-1));0;conj(H_est(((N/2)-1):-1:1))];
h_estimated = ifft(Htot);
figure();
plot(abs(rxQamStream),'Linewidth', 4); hold on; plot(abs(trainblocksequence),'LineWidth',2);xlim([0,100]);






