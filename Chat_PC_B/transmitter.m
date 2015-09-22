function transmitter(packet,fc)
% Parameters below like "rb","fd" can be caculated by the fomular BW =
% (1+alpha)/(2*tau) as well. 
fs = 12e3;                                  % sampling frequency [Hz]
W = 200;                                    % bit rate [bit/sec]
Beta = 0.3;
Rs = 2*W/(Beta+1);
Ts = 1/Rs;
fsfd = ceil(fs/Rs);                         % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)

m = 2;
span = 6;

RRC_puls = rtrcpuls(Beta,Ts,fs,span);
x_upsample = bits2symbols(packet, fsfd, m);
pulse_tr_RRC_samp = pulseShaping(RRC_puls, x_upsample, fsfd, fs);
signal_modulated = baseband2passband(pulse_tr_RRC_samp ,fc, fs);
sound(signal_modulated,fs);                  % Play the transmitted signal

end