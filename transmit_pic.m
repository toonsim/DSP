%% load impulse response
load h_est
dim_h = length(h);

%% Set parameters
N = 1024/4; % DFT size = N_c
N_q = 4; % No of bits in 1 QAM Symbol
L_t = 100;
L_d = 200;
CP_length = dim_h*2;
SNRdB = inf;
fs = 16000;
x = linspace(0,fs,fs)';
pulse = sin(440*x*2*pi);


%% Generate training block
bitstream = randi([0, 1], (N/2-1)*N_q, 1);
trainblock = qam_mod(bitstream,N_q,false);

%% Generate relevant bitStream
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

%% Generate QAM Stream

qamStream = qam_mod(bitStream,N_q,false);

%% Generate full QAM Stream (data and training)


