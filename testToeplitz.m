%% testvector in
x = round(sin(pi/4*(1:20)'));
x = (1:20)';
IR_length = 4;
%% Create toeplitz matrix
c = x(IR_length:end,1);
r = x(IR_length:-1:1,1);
X = toeplitz(c,r)
%% a priori impulse response
h = [0.1 0.10 0.35 0.5]'; %weighted average
%% outvector based on impulse response & input
y = X*h;
%% estimated h vector based on outvector
h_est = X\y;

y_est = X*h_est;
