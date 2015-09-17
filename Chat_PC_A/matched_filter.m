function [ output_args ] = matched_filter( signal_in )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

Fsample=12e3; %12kHz --> 2 times the max freauency;
B=200; % Maximal bandwith of 200Hz

%% Raised cosine shape
beta=0.3;
Rs=floor(2*B/(1+beta)); %Symbol rate that we can achieve according to the BW available
Ts=1/Rs;
[y, t] = rc_pulse(beta,Ts,Fsample); %generate the raised cosine pulse

signal_out=conv(y,signal_in);
figure();plot(signal_out);

end

