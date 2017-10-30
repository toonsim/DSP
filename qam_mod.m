function [ H ] = qam_mod(input, N_q, plotTrue)
    %QAM_MOD Summary of this function goes here
    %   Detailed explanation goes here
    M = 2^N_q;
    if (plotTrue)
        figure('Name', 'QAM-mod');
    end
    H = qammod(input,M,'InputType', 'bit',...
        'PlotConstellation', plotTrue);
    
end

