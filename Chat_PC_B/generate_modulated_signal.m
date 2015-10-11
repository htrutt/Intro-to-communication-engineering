function [ signal_modulated ] = generate_modulated_signal( fc, sequence, rb, RC_puls )

fs = 12e3;                                   % sampling frequency [Hz]
M = 4;                                       % Number of symbols in the constellation (QPSK, M=4)
m = log2(M);                                 % Number of bits per symbol
rs = rb/m;                                   % Symbol rate
fsrs = fs/rs;                                % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)

x_upsample = bits2symbols(sequence, fsrs, m);   % Bits to symbols
pulse_tr_RC_samp = pulseShaping(RC_puls, x_upsample, fsrs, fs); % Pulse shaping
signal_modulated = baseband2passband(pulse_tr_RC_samp ,fc, fs); % Modulation


end

