%% Set parameters
est_IR_length = 401;
%% Create input vector
fs = 16000;
siglength = 2; % 2 seconds
k = linspace(0,siglength,fs*siglength)';
%x = -ones(fs*2,1) + 2*rand([fs*2,1]);
x = [1; zeros(fs*siglength - 1,1)];
%% Create toeplitz matrix
halflength = floor(est_IR_length/2);
c = x(est_IR_length:end,1);
r = x(est_IR_length:-1:1,1);
X = toeplitz(c,r);
%% initialize parameters
[simin,nbsecs,fs]=initparams(x,fs);
%% run simulink recplay
sim('recplay');
%% create output
out=simout.signals.values;
%% get relevant output
[~,startest] = max(out);
delay = 20;
y = out((startest+est_IR_length-delay):(startest+fs*siglength-delay),1);
%% plot response
samples = linspace(0,siglength*fs-startest,size(y, 1))';
subplot(2,1,2);plot(samples,y);
subplot(2,1,1);plot(samples,c);
%%
h = X\y;
stem(h);
plot((1:length(X*h))',(X*h));



