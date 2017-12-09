%% Set parameters
QAM_length = 1000;
N_q = 4;
dev = rand + rand*1i;
stepsize = 1;
alpha = 1e-4;
no_iterations = 1000;
% Hoe groter stepsize voor eenzelfde dev beter
% Maar voor een grotere stepsize mag de dev niet te groot worden want dan
% niet convergeren.
%% Set X_k
bits = randi([0, 1], (QAM_length)*N_q, 1);
X_k = qam_mod(bits,N_q,false);

%% Set H_k
H_k = 0.5 + 0.5i;

%% Set Y_k
Y_k = H_k*X_k;

%% Init W_k
W_k = 1/conj(H_k)+dev;
legnd = [];
figure();
for stepsize = 0.1:0.5:2.1
    %% Filter param comp
    W_k = 1/conj(H_k)+dev;
    to_plot = zeros(no_iterations,1);
    for j = 1:no_iterations
        hehe = repmat(conj(W_k)*Y_k(j),2^N_q,1);
        error_k = min(unique(X_k) - hehe);
        W_k = W_k + stepsize/(alpha+conj(Y_k(j))*Y_k(j))*Y_k(j)*conj(error_k);
        to_plot(j) = abs(conj(W_k)-1/H_k);
    end
     %% Plot
    t = linspace(0,no_iterations,no_iterations)';
    plot(t,to_plot)
    legnd = [legnd 'stepsize = '+string(stepsize)]; hold on
end
title('Error vs no_iterations')
legend(legnd);
xlabel('no_iterations'); ylabel('error');
