function [ N, audioData ] = signalRecording(tout, fs)
% Record the voice signal
recObj = audiorecorder(12e3,8,1);              % Set record object
recordblocking(recObj,tout);
audioData = getaudiodata(recObj);
N = length(audioData);
P = fftshift(fft(audioData,N));                 % Fourier transform
fvec = (fs/N)*(-floor(N/2):1:ceil(N/2)-1);
figure;
plot(fvec,20*log10(abs(P)));

end

