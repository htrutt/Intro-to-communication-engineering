function [ y, t] = rc_pulse( beta, Ts, Fs )
%% This function generates a raised cosine pulse
%beta : roll-off factor
%Ts : Nyquist period or symbol time
%Fs : sample frequency

t=-4*Ts:1/Fs:4*Ts; %time duration of our pulse
y = sin(pi/Ts*t).*cos(pi/Ts*beta*t)./(pi/Ts*t.*(1-4*beta^2/Ts^2*t.^2));

%plot(t,y) %Plot the raised cosine in time domain

%PLot the raised cosine in freq domain
%N=length(y);
%f=Fs/N*(-floor(N/2):1:ceil(N/2)-1);
%y_freq=fft(y);
%figure();plot(f,20*log10(abs(fftshift(y_freq))))


end

