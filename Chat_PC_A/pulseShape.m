function [ signal ] = pulseShape( symbols )
% 
%
%
%

%% Parameters
Fsample = 12e3; %12kHz --> 2 times the max freauency;
B = 200; % Maximal bandwith of 200Hz

%% Raised cosine shape
beta = 0.3;
Rs = floor(2*B/(1+beta)); %Symbol rate that we can achieve according to the BW available
Ts = 1/Rs;

Fsrs = ceil(Fsample/Rs); % Number of sample in one symbol
symbols_up=upsample(symbols,Fsrs); %Upsample our symbols 

[y, t] = rc_pulse(beta,Ts,Fsample); %generate the raised cosine pulse

signal=conv(y,symbols_up); %convoluate the symbols with our pulse to have the sampled transmitted signal
figure();plot(real(signal))

end

