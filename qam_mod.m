function [ H ] = qam_mod(input, N_q, plotTrue)
   
    H = qammod(input,2^N_q,'InputType', 'bit', ...
        'PlotConstellation', plotTrue);
    
end

