%% load impulse response
load h_est
dim_h = length(h);

%% Set parameters
N = 1024/4; % DFT size = N_c
N_q = 4; % No of bits in 1 QAM Symbol
L_t = 10; % No of frames per training packet
L_d = 10; % No of frames per data packet
CP_length = dim_h*2; % length of the cyclic prefix of the ofdm stream
fs = 16000; % sampling frequency

%% Generate training block
trainingBitStream = randi([0, 1], (N/2-1)*N_q, 1);
training_block = qam_mod(trainingBitStream,N_q,false);

%% Generate training ofdm stream
training_ofdm = ofdm_mod(repmat(training_block,L_t,1),CP_length,L_t,N/2-1,[]);


%% Generate data bit stream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');


%% Make input bitstream correct length
% The length of the bitstream should be a multiple of N_q*N_valid
nb_data_QAM_symbols = length(bitStream)/N_q;
N_valid = N/2-1; % number of symbols per data frame (excluding replicas)
remainder = rem(nb_data_QAM_symbols,N_valid);

if (remainder ~= 0)
    nb_added = (N_valid-remainder)*N_q;
else
    nb_added = 0;
end
bitStream_correct_size = [bitStream; zeros(nb_added,1)];

nb_data_QAM_symbols = length(bitStream_correct_size)/N_q;
nb_data_frames = nb_data_QAM_symbols/N_valid;
remainder2 = rem(nb_data_frames,L_d);

if (remainder2 ~= 0)
    nb_added = nb_added + (L_d - remainder2)*N_valid*N_q;  
end

bitStream_correct_size = [bitStream; zeros(nb_added,1)];

nb_data_QAM_symbols = length(bitStream_correct_size)/N_q;
nb_data_frames = nb_data_QAM_symbols/N_valid;  
nb_data_packets = nb_data_frames/L_d;

%% Generate QAM Stream
qamStream = qam_mod(bitStream_correct_size,N_q,false);

%% Generate OFDM Stream
Tx = ofdm_mod_training(qamStream,training_ofdm,L_t,L_d,nb_data_packets,N,CP_length);

%% Initparams
x = linspace(0,fs/2,fs/2)';
A = linspace(0,1,fs/2)';
f = linspace(1,440,fs/2)';
pulse = [1;zeros(fs/2-1,1);A.*sin(2*pi*f.*x);sin(2*pi*440*x)];
plot(A.*sin(2*pi*f.*x));
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

%% Generate Received QAM Stream
[rxQamStream,H_est] = ofdm_demod_ch_est_training(Rx,training_block,N,L_t,L_d,CP_length,nb_data_packets,nb_added,N_q);

semilogy(abs(mean(H_est,2)));hold on; plot(abs(fft(h,N)));figure();
plot(ifft(mean(H_est,2)));hold on; plot(h);

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

%% plot synchronized in and output

figure('Name','Time Domain Result');
load align;
plot(simin(:,1));hold on;
plot(out(-(delay+2*fs):end));
xlim([1.8*fs,5*fs]);



