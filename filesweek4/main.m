% Exercise session 4: DMT-OFDM transmission scheme
%% parameters
load('IRest.mat');
dim_h = length(h);
N_q = 4;
cycle_prefix_length = dim_h*2;
P = 1000;
gcd_nb = gcd(length(bitStream),length(qamStream));
P = P - rem(gcd_nb,P);
sig_to_noise = 0;
%% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%% QAM modulation
qamStream = qam_mod(bitStream,N_q,false);

%% OFDM modulation
ofdmStream = ofdm_mod(qamStream,cycle_prefix_length,P);

%% Channel
stream_with_noise = awgn(ofdmStream,sig_to_noise);

%% Convolute with transferfunction
%h = [1;zeros(49,1)];
rxOfdmStream = fftfilt(h,stream_with_noise);
%rxOfdmStream = stream_with_noise;


%% OFDM demodulation
no_rows = size(qamStream,1)/P; % Necessary for OFDM Receiving
fresp = fft(h,no_rows*2+2);
rxQamStream = ofdm_demod_eq(rxOfdmStream,P,no_rows,cycle_prefix_length,fresp);

%% QAM demodulation
rxBitStream = qam_demod(rxQamStream,N_q);

%% Compute BER
% berTransmission = ber(bitStream,rxBitStream);

%% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

%% Plot images
figure('Name','Image');
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

%% Plot error
figure('Name','Error');
image(abs(imageData-imageRx));axis image; title('Difference between received and original image'); drawnow;
