function [ out_aligned ] = alignIO( out,pulse,fs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    [corr,lag] = xcorr(pulse,out);
    [~,i] = max(abs(corr));
    delay = lag(i);
    save align 'delay'
    out_aligned_silence = out(-delay+1:end);
    out_aligned = out_aligned_silence(length(pulse)+fs-20:end);
end

