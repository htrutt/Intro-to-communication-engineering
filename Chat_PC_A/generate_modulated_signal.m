function [ signal_modulated ] = generate_modulated_signal( fc, sequence, m, fsrs, RC_puls, fs )

x_upsample = bits2symbols(sequence, fsrs, m);   % Bits to symbols
pulse_tr_RC_samp = pulseShaping(RC_puls, x_upsample, fsrs); % Pulse shaping
signal_modulated = baseband2passband(pulse_tr_RC_samp ,fc, fs); % Modulation


end

