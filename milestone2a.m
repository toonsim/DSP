%% Generate bit sequence
N_q = 6;
input = randi([0, 1], factorial(N_q)*10, 1);


%% Plot BER vs N_q/SNR
figure('Name', 'Dependency BER of N_q and SNR');

SNRdB = linspace(0,29,30)';
legnd = [];
nb_it = 4; % number of iterations to get average from

for N_qi = 3:6
    
    bers = zeros(length(SNRdB),1);
    
    for i = 1:nb_it
        
        bers = bers + 1/nb_it*arrayfun(@(x) ber(input,qam_demod(awgn(qam_mod(input,N_qi,false),x,'measured'),N_qi)), SNRdB);
    end
    
    semilogy(SNRdB,bers,'o-');hold on;
    legnd = [legnd 'N_q = '+string(N_qi)]; %#ok<AGROW>
end

title('Dependency BER of N_q and SNR');
legend(legnd);
xlabel('SNR [dB]');ylabel('BER');