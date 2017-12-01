function [ output, H_est ] = ofdm_demod_ch_est_training(Rx, trainingblock, N, L_t,L_d,CP_length,nb_data_packets,nb_added,N_q )
    H_est = zeros(N,nb_data_packets);
    output = zeros(nb_data_packets*(N/2-1)*L_d,1);
    
    for k = 0:(nb_data_packets-1)
        tp_start = k*(L_t+L_d)*(N+CP_length)+1;
        tp_length = L_t*(N+CP_length);
        dp_length = L_d*(N+CP_length);
        tp_range = (tp_start):(tp_start+tp_length-1);
        dp_range = (tp_start + tp_length ):(tp_start + tp_length + dp_length-1);
        
        output_range = (k*(N/2-1)*L_d+1):((k+1)*(N/2-1)*L_d);
        

        Rx_trainingpacket = reshape(Rx(tp_range),N+CP_length,L_t);
        Rx_trainingpacket = fft(Rx_trainingpacket((CP_length+1):end,:));
        datapacket = reshape(Rx(dp_range),N+CP_length,L_d);
        datapacket = fft(datapacket((CP_length+1):end,:));

        trainblockframe = [0;trainingblock;0;flipud(conj(trainingblock))];
        Tx_trainblockpacket = repmat(trainblockframe,L_t);
        
        for i = 1:N
             H_est(i,k+1) = Rx_trainingpacket(i,:)/Tx_trainblockpacket(i,:);
        end
        
        datapacket([1,(N/2+1):end],:) = []; % remove DC component and conjugated copies

        datapacket = datapacket./H_est(2:(N/2),k+1);
        output(output_range) = datapacket(:);
        
    end
    
    output=output(1:(end-nb_added/N_q));
end

