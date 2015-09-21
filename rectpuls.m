function [ y,t ] = rectpuls( tau,fs,span )
t_positive = eps:(1/fs):span*tau;  % Replace 0 with eps (smallest +ve number MATLAB can produce) to prevent NANs
t = [-fliplr(t_positive(2:end)) t_positive];
y = rectangularPulse(-tau/2,tau/2,t);


end

