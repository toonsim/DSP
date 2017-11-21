function [ ofdm_output ] = ofdm_mod( QAM_Stream, CP_length, P, N_valid, bad_carriers)

    packet_init = reshape(QAM_Stream,N_valid,P); % divide QAM_Stream in 
                                               % P frames of length N_valid
    
    % ON-OFF - bitloading
    for i = 1:length(bad_carriers) % add rows of zeros at bad carrier frequencies
        row_i = bad_carriers(i);
        packet_init = [packet_init(1:(row_i-1),:);...
                       zeros(1,P);...
                       packet_init((row_i):end,:)];
    end % the frame length is now N
    
    
    packet = [zeros(1,P); packet_init; zeros(1,P); flipud(conj(packet_init))]; 
    save ofdm packet;
    framelength = size(packet,1); % is now 2N+2
    
    % make sure no information is sent at the DC frequency since this 
    % would be useless in sound transmission and also make sure that the
    % signal to be sent is real -> real part packet = even & imaginary part =
    % odd -> hence [X_i 0 X_i^(*)] 
  
    ofdmNoPref = ifft(packet,framelength); % performing the IEDFT is equivalent to modulating at 2N+2 carrier frequencies
                                           % (up to scalar N, which is omitted because 
                                           % signal will be scaled to unit magnitude anyway)
    
    ofdmPref = [ofdmNoPref((framelength+1 - CP_length):framelength,:); ofdmNoPref];
    ofdm_output = ofdmPref(:);
    
end

