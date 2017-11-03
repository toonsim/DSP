function [ output ] = ofdm_demod( input,P,No_rows,Cycle_prefix_length )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    in_matrix = reshape(input,size(input,1)/P,P);
    in_matrix(1:Cycle_prefix_length,:) = [];
    FFT_matrix = fft(in_matrix);
    FFT_matrix([1,(No_rows+2):(2*No_rows+2)],:) = [];
    output = FFT_matrix(:);

end

