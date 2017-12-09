%% Initialize parameters
QAM_length = 1000;
N_q = 4;

%% Generate X_k
bitStream = randi([0,1],QAM_length*N_q,1);
X_k = qam_mod(bitStream,N_q,false);

%% Generate H_k
H_k = [1+1i;1];

%% Generate Y_k
Y_k = H_k(1)*X_k;

%% LMS parameters
dev = 1e-2;
alpha = 1e-3;
W_k = 1./conj(H_k) + dev;
W

