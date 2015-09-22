function [ pulse_tr_RRC_samp ] = pulseShaping( RRC_puls, x_upsample, fsfd, fs )
% Make the transmitted signal gp through a pulse shaping filter to limit
% its bandwidth
pulse_tr_RRC = conv(RRC_puls,x_upsample);
pulse_tr_RRC_samp = pulse_tr_RRC(fsfd*6:end-fsfd*5);  % Discard the last fsfd*(span-1) data
N = length(pulse_tr_RRC_samp);
P = fftshift(fft(pulse_tr_RRC_samp,N));              % Fourier transform
fvec = (fs/N)*(-floor(N/2):1:ceil(N/2)-1);
figure; plot(fvec,20*log10(abs(P)));

end

