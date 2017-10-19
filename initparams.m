function [ simin, nbsecs, fs] = initparams( toplay, fs )
    nbsamps = length(toplay);
    simin = [zeros(2*fs,2);toplay toplay; zeros(1*fs,2)]; % add 2 seconds before and 1 sec after
    simin = simin/max(abs(simin)); % scale to values between -1 and +1
    nbsecs = 2 + nbsamps/fs + 1; % 2 secs intro + toplay + 1 sec outro
end

