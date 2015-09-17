function [ signal_a1, signal_b2 ] = passband2baseband( signal_in, fc )
%Bring the signal back in baseband
%   Detailed explanation goes here
Fs=12e3;
t=0:1/Fs:(size(signal_in,2)-1)/Fs;
y1=sqrt(2)*cos(2*pi*fc*t); %carrier signal I : cos(2*pi*Fc*t)
y2=sqrt(2)*sin(2*pi*fc*t); %carrier signal Q : sin(2*pi*Fc*t)


signal_a1=signal_in.*y1;
signal_b2=signal_in.*y2;

end

