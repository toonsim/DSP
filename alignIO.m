function [ out_aligned ] = alignIO( out,pulse,fs )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %out = out(fs:end-fs-length(Tx));
    [corr,lag] = xcorr(pulse,out);
    [~,i] = max(abs(corr));
    delay = lag(i)+20;
    save align 'delay'
    out_aligned_silence = out(-delay:end);
    out_aligned = out_aligned_silence((length(pulse)+fs):end);
end

