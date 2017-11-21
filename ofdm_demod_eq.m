function [ output ] = ofdm_demod_eq(input,CP_length,P,N_s,channelresp,badfreq,nb_added,N_q)

   
    packet_fft = reshape(input,length(input)/P,P);
    packet_fft(1:CP_length,:) = []; % remove cycle prefix
    packetNoEQ = fft(packet_fft); % demodulate the signal components
    
    packetEQ = packetNoEQ./channelresp; % Account for channel by simply performing elementwise
                                        % division with the estimated channel response
    
    packetEQ([1,(N_s+2):end],:) = []; % remove DC component and conjugated copies
    
    for i = 1:length(badfreq) % Remove the rows of the packet that correspond 
                              % to the frequencies that were 'omitted' via the bitloading
        row_i = badfreq(i)-i+1;
        packetEQ(row_i,:) = []; 
        
    end
    
    output = packetEQ(:); % put all the frames after one another in a vector
    output=output(1:(end-nb_added/N_q)); % remove the zeroes that were added 
                                        % to comply with the N_q and N_valid declared in milestone2b.m

end

