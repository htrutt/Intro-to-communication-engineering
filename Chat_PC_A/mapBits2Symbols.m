function [ symbols ] = mapBits2Symbols( bits )
% This function maps bits to their symbols according to the modulation
% used. 
% INPUT: bits (binary numbers)
% OUTPUT: symbols (complex valued symbols)

%% QPSK modulatiom
m = 2; %Number of bits per symbols
% M = 2^m; Number of symbols 

QPSK_const = [1+1i,-1+1i,1-1i,-1-1i]; 

bits_group = buffer(bits,m); % Form group of m bits
message = bi2de(bits_group'); %Convert those group of bits to their decimal value
symbols = QPSK_const(1+message); %Use this decimal value as an index of our constellation vector

end

