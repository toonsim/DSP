%% load impulse response
load h_est
dim_h = length(h);

%% Set parameters
N = 1024/2; % DFT size = N_c
N_q = 4; % No of bits in 1 QAM Symbol
L_t = 5; % No of frames per training packet
L_d = 5; % No of frames per data packet
CP_length = dim_h*2; % length of the cyclic prefix of the ofdm stream
fs = 16000; % sampling frequency

%% Generate training block
trainingBitStream = randi([0, 1], (N/2-1)*N_q, 1);
training_block = qam_mod(trainingBitStream,N_q,false);

%% Generate data bit stream
[bitStream, imageData, colorMap, imageSize, bitsPerPixel] = imagetobitstream('image.bmp');

%% ON-OFF Bitloading

if (BWusage < 100)
   
    % First dummy transmission to eliminate bad frequency tones
    L_tinit = 80;
    dummy_Tx = ofdm_mod(repmat(training_block,L_tinit,1),CP_length, L_tinit,N/2-1,[]);
    x = linspace(0,fs/2,fs/2)';
    A = linspace(0,1,fs/2)';
    f = linspace(1,440,fs/2)';
    pulse = [1;zeros(fs/2-1,1);A.*sin(2*pi*f.*x);sin(2*pi*440*x)];
    [simin,nbsecs,fs] = initparams(dummy_Tx,fs,pulse);
    sim('recplay');
    dummy_out=simout.signals.values;
    dummy_Rx_before = alignIO(dummy_out,pulse,fs);
    dummy_Rx = dummy_Rx_before(1:length(dummy_Tx)); 
    [dummy_Tx,dummy_H] = ofdm_demod_dummy(dummy_Rx,repmat(training_block,L_tinit,1),CP_length,L_tinit,N/2-1); 
    dummy_bitstream = qam_demod(dummy_Tx,N_q);
    dummy_ber = ber(trainingBitStream,dummy_bitstream);

    H = dummy_H(1:(N/2-1));
    N_bad = floor((1-BWusage/100)*(N/2-1));
    [Hsort,Ni] = sort(H);
    bad_carriers = sort(Ni(1:N_bad));
    N_valid = N/2-1-N_bad;
else
    N_valid = N/2-1;
    bad_carriers = [];
    N_bad = 0;
end



%% Make input bitstream correct length
% The length of the bitstream should be a multiple of N_q*N_valid
nb_data_QAM_symbols = length(bitStream)/N_q;

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

%% Generate training ofdm stream
training_ofdm = ofdm_mod(repmat(training_block,L_t,1),CP_length,L_t,N/2-1,[]);

%% Generate QAM Stream
qamStream = qam_mod(bitStream_correct_size,N_q,false);

%% Generate OFDM Stream
Tx = ofdm_mod_training(qamStream,training_ofdm,L_t,L_d,nb_data_packets,N,CP_length,bad_carriers);

%% Initparams
x = linspace(0,fs/2,fs/2)';
A = linspace(0,1,fs/2)';
f = linspace(1,440,fs/2)';
pulse = [1;zeros(fs/2-1,1);A.*sin(2*pi*f.*x);sin(2*pi*440*x)];
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

%% OFDM demodulation
[rxQamStream,H_est] = ofdm_demod_ch_est_training(Rx,training_block,N,L_t,L_d,CP_length,nb_data_packets,nb_added,N_q,bad_carriers);


%% QAM demodulation
rxBitStream = qam_demod(rxQamStream,N_q);

%% Compute BER
berTransmission = ber(bitStream,rxBitStream);

%% Construct image from bitstream
imageRx = bitstreamtoimage(rxBitStream, imageSize, bitsPerPixel);



