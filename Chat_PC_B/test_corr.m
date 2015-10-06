load('seq_modulated');
fs = 12e3;
[N, signal_modulated] = signalRecording(2, fs );

cor=xcorr(signal_modulated, seq_modulated);
plot(cor);