function [ output, H_est] = ofdm_demod_lms(Rx, trainingblock, N, L_t,L_d,CP_length,nb_added,N_q,bad_carriers,QAM_valid)
    H_est = zeros(N,L_d+1);
    output = zeros((N/2-1-length(bad_carriers))*L_d,1);
    
    tp_length = (L_t*(N+CP_length));
   
    Rx_trainingpacket = reshape(Rx(1:tp_length),N+CP_length,L_t);
    Rx_trainingpacket = fft(Rx_trainingpacket((CP_length+1):end,:));
    
    trainblockframe = [0;trainingblock;0;flipud(conj(trainingblock))];
    Tx_trainblockpacket = repmat(trainblockframe,L_t);
    
    for k = 1:N
        H_est(k,1) = Rx_trainingpacket(k,:)/Tx_trainblockpacket(k,:);
    end

    datapacket = reshape(Rx((tp_length+1):end),N+CP_length,L_d);
    datapacket = fft(datapacket((CP_length+1):end,:));
    datapacket([1,(N/2+1):end],:) = []; % remove DC and conjugates
    datapacket(bad_carriers,:) = []; % remove bad carriers
    stepsize = 0.1;
    
    W_i = 1./conj(H_est(1+setdiff(1:(N/2-1),bad_carriers),1))+rand(N/2-1,1)+rand(N/2-1,1)*1i;
    alpha = 1e-4;
   
    error_k = zeros(N/2-1-length(bad_carriers),1);
    
    for i = 1:L_d
        
        frame_i = datapacket(:,i);
        for k = 1:(N/2-1-length(bad_carriers))
            [error_k(k),index] = min(QAM_valid - conj(W_i(k))*frame_i(k));
            datapacket(k,i) = QAM_valid(index);
        end
        W_i = W_i + (stepsize./(alpha + conj(frame_i).*frame_i)).*frame_i.*conj(error_k);
        output_range = ((i-1)*(N/2-1-length(bad_carriers))+1):(i*(N/2-1-length(bad_carriers)));
        output(output_range) = datapacket(:,i);
        H_est(1+setdiff(1:(N/2-1),bad_carriers),i+1) = 1./conj(W_i);
        H_est(N/2+2:end,i+1) = conj(flipud(H_est(2:N/2,i+1)));
    end
    
    
    output = output(1:(end-nb_added/N_q));
end

