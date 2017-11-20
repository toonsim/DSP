function [ errorprob ] = ber( input, output )
    %BER Summary of this function goes here
    %   Detailed explanation goes here
    
    errorprob = biterr(input,output)/length(input);
end

