  function transmitter(packet,fc)
% packet: information bits to be tranmistted
% fc: carrier frequency
% Parameters below like "rb","rs" can be caculated by the fomular BW =
% (1+alpha)/(2*tau) as well. 
% In the situation below the BW = (1+0.4)/(2*1/rs) = 210;

%% Loading all the needed parameters
run('parameters.m');                           % Loads all the parameters necessary
markerBits = repmat(barkerBits, 1, 1);        % Duplicate barkerbits to 10 times for preamble

%% Add preamble to our message
packet = packet';
dataBits = [markerBits, syncBits, packet];     % 1 Barker seq + 1 rand seq + message

%% Converting message bits to symbol and upsampling 
x_upsample = bits2symbols(dataBits, fsrs, m);   % Bits to symbols

%% Pulse shapping our symbols using our RRC pulse
pulse_tr_RC_samp = pulseShaping(RRC_puls, x_upsample, fsrs); % Pulse shaping

%% Modulate our signal around our carrier frequency fc
signal_modulated = baseband2passband(pulse_tr_RC_samp ,fc, fs); % Modulation

%% Play the signal as a sound
sound(signal_modulated,fs);                  % Play the transmitted signal
audiowrite('trial.wav',signal_modulated,fs);
end
