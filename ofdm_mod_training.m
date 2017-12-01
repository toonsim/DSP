function [ ofdm_output ] = ofdm_mod_training( QAM_data, OFDM_training, L_t, L_d, nb_data_packets, N,CP_length)
    ofdm_output = zeros(nb_data_packets*(N+CP_length)*(L_d+L_t),1);
    for k = 0:(nb_data_packets-1)
        qam_range = (k*L_d*(N/2-1)+1):((k+1)*L_d*(N/2-1));
        ofdm_range = (k*(L_d+L_t)*(N+CP_length)+1):((k+1)*(L_d+L_t)*(N+CP_length));
        ofdm_output(ofdm_range) = [OFDM_training;ofdm_mod(QAM_data(qam_range),CP_length,L_d,N/2-1,[])];
    end
end

