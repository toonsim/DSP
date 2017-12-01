function [ output, H_est] = ofdm_demod_ch_est(Rx,dim_h,trainingsequence,CP_length,P,N_s,badfreq,nb_added,N_q,No_trainingblocks)
    N = N_s*2+2;
    trainblock = trainingsequence(1:N_s);
    trainblock_length = N_s;
    packet_fft = reshape(Rx,length(Rx)/P,P);
    packet_fft(1:CP_length,:) = []; % remove cycle prefix
    packet = fft(packet_fft);
    packetNoEQ = fft(packet_fft); % demodulate the signal components
    
    packetNoEQ([1,(N_s+2):end],:) = []; % remove DC component and conjugated copies
    
    for i = 1:length(badfreq) % Remove the rows of the packet that correspond 
                              % to the frequencies that were 'omitted' via the bitloading
        row_i = badfreq(i)-i+1;
        packetNoEQ(row_i,:) = []; 
        
    end
    
    output = packetNoEQ(:); % put all the frames after one another in a vector
    output = output(1:(end-nb_added/N_q)); % remove the zeroes that were added 
   
    H_est = zeros(trainblock_length,1);
    for k = 0:(No_trainingblocks-1)
        range = k*trainblock_length+1:((k+1)*trainblock_length);
        H_est = H_est + 1/trainblock_length*output(range)./trainingsequence(range);
    end
    
    trainblockframe = [0;trainblock;0;flipud(conj(trainblock))];
    trainblockpacket = repmat(trainblockframe,P);
    
%     H_est = zeros(N,1);
%     for i = 1:N
%         H_est(i) = packet(i,:)/trainblockpacket(i,:);
%     end
    
    
     output = output(1:trainblock_length);
     output = output./H_est;%(2:(N/2));
     output = output(:);

    
    
end

