function [ output, H_est] = ofdm_demod_dummy(Rx,trainingsequence,CP_length,P,N_s)
    N = N_s*2+2;
    trainblock = trainingsequence(1:N_s);
    trainblock_length = N_s;
    packet_fft = reshape(Rx,length(Rx)/P,P);
    packet_fft(1:CP_length,:) = []; % remove cycle prefix
    packet = fft(packet_fft);
    packetNoEQ = fft(packet_fft); % demodulate the signal components
    
    packetNoEQ([1,(N_s+2):end],:) = []; % remove DC component and conjugated copies
    
   
    
    output = packetNoEQ(:); % put all the frames after one another in a vector

    trainblockframe = [0;trainblock;0;flipud(conj(trainblock))];
    trainblockpacket = repmat(trainblockframe,P);
    
     H_est = zeros(N,1);
     for i = 1:N
         H_est(i) = packet(i,:)/trainblockpacket(i,:);
     end
    
    
     output = output(1:trainblock_length);
     output = output./H_est(2:(N/2));
     output = output(:);

    
    
end

