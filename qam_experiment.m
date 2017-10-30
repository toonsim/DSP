%% Set parameters
N_q = 6;
SigToNoise= 0; %dB

%% Generate bit sequence
input = randi([0, 1], 10*N_q, 1);

%% Generate QAM symbol sequence
H = qam_mod(input,N_q,true);

%% Add Gaussian white noise
H_noise = awgn(H,SigToNoise);

%% Demodulate QAM sequence
output = qam_demod(H_noise,N_q);
figure('Name','Output error');
stem(output-input);
errorprob = ber(input, output);

%% Plot BER vs SNR
sig2noise = (10:-1:-10)';
figure('Name','Dependency BER of SNR');
plot(sig2noise,arrayfun(@(x) ber(input,qam_demod(awgn(qam_mod(input,N_q,false),x),N_q)), sig2noise));
xlabel('SNR [dB]');ylabel('BER');

%% Plot BER vs N_q
N_qs = (1:6)';
figure('Name','Dependency BER of N_q');
plot(N_qs,arrayfun(@(x) ber(input,qam_demod(awgn(qam_mod(input,x,false),SigToNoise),x)), N_qs));
xlabel('N_q [bits]');ylabel('BER');


