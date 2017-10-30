function [ output ] = qam_demod( Hin, N_q )
    %QAM_DEMOD Summary of this function goes here
    %   Detailed explanation goes here
    M = 2^N_q;
    output = qamdemod(Hin,M,'OutputType', 'bit');
    
end

