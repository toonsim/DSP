function [ output, H_est] = ofdm_demod_ch_est(Rx,dim_h,trainingsequence,CP_length,P,N_s,badfreq,nb_added,N_q)

    
    packet_fft = reshape(Rx,length(Rx)/P,P);
    packet_fft(1:CP_length,:) = []; % remove cycle prefix
    packetNoEQ = fft(packet_fft); % demodulate the signal components
    
    packetNoEQ([1,(N_s+2):end],:) = []; % remove DC component and conjugated copies
    
    for i = 1:length(badfreq) % Remove the rows of the packet that correspond 
                              % to the frequencies that were 'omitted' via the bitloading
        row_i = badfreq(i)-i+1;
        packetNoEQ(row_i,:) = []; 
        
    end
    output = packetNoEQ(:); % put all the frames after one another in a vector
    output=output(1:(end-nb_added/N_q)); % remove the zeroes that were added 
                                    % to comply with the N_q and N_valid declared in milestone2b.m
    c = trainingsequence(dim_h:end,1);
    r = trainingsequence(dim_h:-1:1,1);
    
    
    X = toeplitz(c,r);
    save ofdm X output
    H_est = X\output(dim_h:end);
    
    
    

    
end

