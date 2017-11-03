function [ errorprob ] = ber( input, output )
    %BER Summary of this function goes here
    %   Detailed explanation goes here
    
    % Correct but there is a matlab function for this
    %errorprob = sum(abs(input-output))/length(input);
    
    No_errors = biterr(input,output);
    errorprob = No_errors/length(input);
end

