function [ signal_out ] = baseband2passband( signal_in, fc )
%% This function Multiply the signal with our carrier frequency
% We use an IQ modulator 
Fs=12e3;
t=0:1/Fs:(size(signal_in,2)-1)/Fs; %we want our carrier signal to be as long as the signal_in

y1=sqrt(2)*cos(2*pi*fc*t); %carrier signal I : cos(2*pi*Fc*t)
y2=sqrt(2)*sin(2*pi*fc*t); %carrier signal Q : sin(2*pi*Fc*t)

s1=real(signal_in).*y1; % multiply the real part with cos
s2=imag(signal_in).*y2;  %multiply the imaginary part with sin

signal_out=s1+j*s2; %the output signal is the addition of the tzo signal

end

