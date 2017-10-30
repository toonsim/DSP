function [ Xin, Yout ] = generate_square_wave(period, nbsec, fs )
    %GENERATE_SQUARE_WAVE Summary of this function goes here
    %   Detailed explanation goes here
    nbsec = floor(nbsec*fs)/fs; % make sure nb of samples is integer
    Xin = linspace(0,nbsec, nbsec*fs)';
    sqwv = @(X) arrayfun(@(x)  -1 ...
                                + 2*double(rem(x,period) < period/2) ...
                               + 0*double((rem(floor(x/period),2) == 0) ...
                                        &&(rem(x,period) > period/2)), X);
    Yout = sqwv(Xin);
end

