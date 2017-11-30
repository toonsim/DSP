function [ output ] = qam_demod( Hin, N_q )
    %QAM_DEMOD Summary of this function goes here
    %   Detailed explanation goes here
    M = 2^N_q;
    scale = sqrt((2/3)*(2^N_q-1));
    Hin_scaled = Hin*scale;
    output = qamdemod(Hin_scaled,M,'OutputType', 'bit');
    
end

