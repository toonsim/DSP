function [ start] = Synchronize(in, out, startest, NB_iter,testlength)
    %% correct NB_iter if odd
    NB_iter = 2*floor(NB_iter/2);
    
    %% iterate to find best offset from startest
    diff_vector = zeros(NB_iter+1,1);
    for i = 0:NB_iter
        outi = out((startest-i):(startest-i+testlength-1),1);
        diff_vector(i+1) = norm(outi - in(1:testlength),2);
    end
    
    [~,offset] = min(diff_vector);
    offset = offset-1;
    start = startest-offset;
end

