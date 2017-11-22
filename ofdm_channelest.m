%% load impulse response
load IRest
dim_h = length(h);
%% Set parameters
N = 200; % DFT size = N_c
N_q = 5; % No of bits in 1 QAM Symbol
P = 100;
CP_length = dim_h*2;
SNRdB = inf;

%% Generate training block
bitstream = randi([0, 1], (N/2-1)*N_q, 1);
trainblock = qam_mod(bitstream,N_q,false);

%% generate ofdm time domain signal
trainblocksequence = repmat(trainblock,P,1);
Tx = ofdm_mod(trainblocksequence,CP_length,P,N/2-1,[]);

%% Convolution with transferfunction
Rx = fftfilt(h,Tx);

%% Channel
rxOfdmStream_noise = awgn(Rx,SNRdB, 'measured');

%% OFDM demodulation
[rxQamStream, H_est] = ofdm_demod_ch_est(rxOfdmStream_noise,dim_h, trainblocksequence,CP_length,P,N/2-1,[],0,N_q);








