% Exercise session 4: DMT-OFDM transmission scheme
%% Set parameters
N_q = 6; % Number of bits per QAM symbol
N_s = 100; % Number of symbols sent -> number of rows per frame
N_c = 2*N+2; % Number of carrier frequencies of the ofdm (including DC + 4000Hz)
CP_length = dim_h*2; %length of the cycle prefix
SNRdB = 0; % Signal to Noise ratio in dB 

%% Load impulse Response
load('IRest.mat');
dim_h = length(h);

%% Bitloading
threshold = 0.3; % threshold for which frequencies to be left out

%% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%% ON OFF bit loading
if (threshold > 0)
     
     H = abs(fft(h,N_c));
     H = H(1:N_s);
     
     bad_carriers = find(H < threshold);
     
     N_bad = length(bad_carriers);
     N_valid = N_s-N_bad;
else
    N_valid = N_s;
    bad_carriers = [];
end

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

%% QAM modulation
qamStream = qam_mod(bitStream_correct_size,N_q,false);

%% OFDM modulation
ofdmStream = ofdm_mod(qamStream,CP_length,P,N_valid,bad_carriers);

%% Convolution with transferfunction
rxOfdmStream = fftfilt(h,ofdmStream);

%% Channel
rxOfdmStream_noise = awgn(rxOfdmStream,SNRdB, 'measured');

%% OFDM demodulation
rxQamStream = ofdm_demod_eq(rxOfdmStream_noise,CP_length,P,N_s,fft(h, N_c),bad_carriers,nb_added,N_q);

%% QAM demodulation
rxBitStream = qam_demod(rxQamStream,N_q);

%% Compute BER
 berTransmission = ber(bitStream,rxBitStream);

%% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

%% Plot images
figure('Name','Image');
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title('Received image'); drawnow;

%% Plot error
figure('Name','Error');
image(abs(imageData-imageRx));axis image; title('Difference between received and original image'); drawnow;
