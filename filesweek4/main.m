% Exercise session 4: DMT-OFDM transmission scheme
%% parameters
load('IRest.mat');
dim_h = length(h);
N_q = 4;
N = 100; % aantal carrier frequenties

cycle_prefix_length = dim_h*2;

sig_to_noise = 30;
%% Convert BMP image to bitstream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%% ON OFF bit loading

 H = abs(fft(h,(N+1)*2));
 H = H(1:(N+1));
 H = H(2:(end-1));
 
 threshold = 0.35;
 badfreq = find(H<threshold);
 nbbadfreq = length(badfreq);
 
 nb_val_rows = N-nbbadfreq;


%% Make bitstream correct length
v = rem(length(bitStream)/N_q,nb_val_rows);
nb_added = (nb_val_rows-v)*N_q;
if ( v ~= 0)
    bitStream_adapted = [bitStream; zeros(nb_added,1)];
end
P = length(bitStream_adapted)/N_q/nb_val_rows;

%% QAM modulation
qamStream = qam_mod(bitStream_adapted,N_q,false);

%% OFDM modulation
ofdmStream = ofdm_mod(qamStream,cycle_prefix_length,N,P,nb_val_rows,badfreq);

%% Convolute with transferfunction
%h = [1;zeros(49,1)];
rxOfdmStream = fftfilt(h,ofdmStream);
%rxOfdmStream = stream_with_noise;

%% Channel
rxOfdmStream_noise = awgn(rxOfdmStream,sig_to_noise, 'measured');


%% OFDM demodulation

fresp = fft(h,N*2+2);
rxQamStream = ofdm_demod_eq(rxOfdmStream_noise,P,N,cycle_prefix_length,fresp,badfreq,nb_added,N_q);

%% QAM demodulation
rxBitStream = qam_demod(rxQamStream,N_q);

%% Compute BER
 berTransmission = ber(bitStream,rxBitStream);

%% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);

%% Plot images
figure('Name','Image');
subplot(2,1,1); colormap(colorMap); image(imageData); axis image; title('Original image'); drawnow;
subplot(2,1,2); colormap(colorMap); image(imageRx); axis image; title(['Received image']); drawnow;

%% Plot error
figure('Name','Error');
image(abs(imageData-imageRx));axis image; title('Difference between received and original image'); drawnow;
