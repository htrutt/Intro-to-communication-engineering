function [ y, t] = rc_pulse( beta, Ts, Fs )
%% This function generates a raised cosine pulse
%beta : roll-off factor
%Ts : Nyquist period or symbol time
%Fs : sample frequency

t=-3*Ts:1/Fs:3*Ts; %time duration of our pulse
y = sinc(t/Ts)*(cos((pi*beta*t)/Ts)/(1-(4*beta.^2*t.^2)/Ts)); %raised cosine pulse

%plot(t,y)
end

