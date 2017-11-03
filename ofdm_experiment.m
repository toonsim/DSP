%% Set parameters
N_q = 6; % #QAM Constellations
Bitstream_length = N_q * 1000;
P = 100; % #Frames
SNR = 20;
Cycle_prefix_length = 4;

%% Generate bitstream
BIT_Stream = randi([0, 1], Bitstream_length, 1);

%% QAM modulation
QAM_Stream = qam_mod(BIT_Stream,N_q,false);
No_rows = size(QAM_Stream,1)/P; % Necessary for OFDM Receiving

%% OFDM modulation
OFDM_mod = ofdm_mod(QAM_Stream,Cycle_prefix_length,P);

%% Pass trough channel
OFDM_noise = awgn(OFDM_mod,SNR);

%% OFDM receiving
OFDM_rec = ofdm_demod(OFDM_noise,P,No_rows,Cycle_prefix_length);

%% QAM demodulation and BER calculation
BIT_output = qam_demod(OFDM_rec,N_q);
BER = ber(BIT_Stream, BIT_output)

%% Results
% N_q omhoog, BER omlaag
% SNR omhoog, BER omlaag
% MAAR let op hoe hoger N_q hoe hoger de SNR moet zijn voor een goed
% resultaat!! Zie grafiek op pc Tristan
