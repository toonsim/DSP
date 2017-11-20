%% Set parameters
N_q = 6;
SigToNoise= 0; %dB

%% Generate bit sequence
input = randi([0, 1], 1e3*N_q, 1);

%% Generate QAM symbol sequence
H = qam_mod(input,N_q,true);

%% Add Gaussian white noise
H_noise = awgn(H,SigToNoise,'measured');

%% Demodulate QAM sequence
output = qam_demod(H_noise,N_q);
figure('Name','Output error');
stem(output-input);
errorprob = ber(input, output);

%% Plot BER vs SNR
sig2noise = (20:-1:-20)';
figure('Name','Dependency BER of SNR');
plot(sig2noise,arrayfun(@(x) ber(input,qam_demod(awgn(qam_mod(input,N_q,false),x,'measured'),N_q)), sig2noise));
xlabel('SNR [dB]');ylabel('BER');

%% Plot BER vs N_q
N_qs = (1:6)';
figure('Name','Dependency BER of N_q');
plot(N_qs,arrayfun(@(x) ber(input,qam_demod(awgn(qam_mod(input,x,false),SigToNoise,'measured'),x)), N_qs));
xlabel('N_q [bits]');ylabel('BER');

%% Plot BER vs N_q/SNR
sig2noise = linspace(0,29,30)';
figure('Name', 'Dependency BER of N_q and SNR');
leg = [];
nbit = 1;
for N_qi = 3:6
    bers = zeros(length(sig2noise),1);
    for i = 1:nbit
        bers = bers + 1/nbit*arrayfun(@(x) ber(input,qam_demod(awgn(qam_mod(input,N_qi,false),x,'measured'),N_qi)), sig2noise);
    end
    semilogy(sig2noise,bers,'o-');
    hold on;
    leg = [leg 'Nq = '+string(N_qi)];
end
legend(leg);
xlabel('SNR [dB]');ylabel('BER');
