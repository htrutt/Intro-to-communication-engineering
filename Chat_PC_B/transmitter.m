function transmitter(packet,fc)
% Parameters below like "rb","fd" can be caculated by the fomular BW =
% (1+alpha)/(2*tau) as well. 
fs = 12e3;                                   % sampling frequency [Hz]
rb = 600;                                    % bit rate [bit/sec]
M = 4;                                       % Number of symbols in the constellation (QPSK, M=4)
m = log2(M);                                 % Number of bits per symbol
fd = rb/m;                                   % Symbol rate
fsfd = fs/fd;                                % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)

RC_puls = rtrcpuls(0.4,1/fd,fs,6);
x_upsample = bits2symbols(packet, fsfd, m);
pulse_tr_RC_samp = pulseShaping(RC_puls, x_upsample, fsfd, fs);
signal_modulated = baseband2passband(pulse_tr_RC_samp ,fc, fs);
sound(signal_modulated,fs);                  % Play the transmitted signal

end