function [ H ] = qam_mod(input, N_q, plotTrue)
   
    scale = sqrt((2/3)*(2^N_q-1)); % Average energy over all symbols is one, independent on constellation size
    H = qammod(input,2^N_q,'InputType', 'bit', ...
        'PlotConstellation', plotTrue)/scale;
    
end

