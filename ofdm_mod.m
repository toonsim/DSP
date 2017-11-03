function [ ofdm_output ] = ofdm_mod( QAM_Stream, Cycle_prefix_length, P )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    N = size(QAM_Stream,1)/P; % #Complex numbers in one frame
    in_matrix = reshape(QAM_Stream,N,P);
    conj_matrix = flipud(conj(in_matrix));
    o_matrix = [zeros(1,P); in_matrix; zeros(1,P)];
    QAM_matrix = [o_matrix; conj_matrix];
    IFFT_matrix = ifft(QAM_matrix);
    Prefix_matrix = [IFFT_matrix((size(IFFT_matrix,1)+1-Cycle_prefix_length):(size(IFFT_matrix,1)),:); IFFT_matrix];
    ofdm_output = Prefix_matrix(:);
    
end

