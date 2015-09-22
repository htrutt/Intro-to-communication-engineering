%% bits to Symbols
clc; clear all; close all

fs = 12e3;                                          % sampling frequency [Hz]
rb = 600;                                           % bit rate [bit/sec]
N = 432;                                            % number of bits to transmit
% Constellation or bit to symbol mapping
s = [(1 + 1i) (1 - 1i) (-1 -1i) (-1 + 1i)]/sqrt(2); % Constellation 1 - QPSK/4-QAM
                                                    % s = exp(1i*((0:3)*pi/2 + pi/4)); % Constellation 1 - same constellation generated as PSK
scatterplot(s); grid on;                            % Constellation visualization
M = length(s);                                      % Number of symbols in the constellation
m = log2(M);                                        % Number of bits per symbol
fd = rb/m;                                          % Symbol rate
fsfd = fs/fd;                                       % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)
rng('shuffle')
b = randsrc(1,N,[0 1]);                             % Information bits
b_buffer = buffer(b, m)';                           % Group bits into bits per symbol
sym_idx = bi2de(b_buffer, 'left-msb')'+1;           % Bits to symbol index
x = s(sym_idx);                                     % Look up symbols using the indices  
x_upsample = upsample(x, fsfd);                     % Space the symbols fsfd apart, to enable pulse shaping using conv.
x_upsample(end-fsfd+2:end) = [];
%% RRC pulse
span = 6;
beta = 0.4;
RC_puls = rtrcpuls(beta,1/fd,fs,span);         % Root raised cosine pulse shaping filter
pulse_tr_RC = conv(RC_puls,x_upsample);
pulse_tr_RC_samp = pulse_tr_RC(fsfd*6:end-fsfd*5);  % Discard the last fsfd*(span-1) data
N = length(pulse_tr_RC_samp);
P = fftshift(fft(pulse_tr_RC_samp,N));              % Fourier transform
fvec = (fs/N)*(-floor(N/2):1:ceil(N/2)-1);
figure; plot(fvec,20*log10(abs(P)));
%% Carrier
f_carrier=2000;                                     % Carrier frequency
t=0:1/fs:(length(pulse_tr_RC_samp)-1)/fs;
% Modulation
Icarrier = sqrt(2)*(real(pulse_tr_RC_samp)).*cos(2*pi*f_carrier*t);     
Qcarrier = sqrt(2)*(imag(pulse_tr_RC_samp)).*sin(2*pi*f_carrier*t);
carrier=Icarrier+Qcarrier;
N = length(carrier);
P = fftshift(fft(carrier,N));                       % Fourier transform
fvec = (fs/N)*(-floor(N/2):1:ceil(N/2)-1);
figure;
plot(fvec,20*log10(abs(P)));
sound(carrier,fs);                                  % Play the transmitted signal
%% Signal through AWGN
snr=20;                                             % Signal-to-noise ratio
carrier_noise=awgn(Icarrier+1j*Qcarrier,snr);       % Through Gussain white noise channel
N = length(carrier_noise);
fvec = (fs/N)*(-floor(N/2):1:ceil(N/2)-1);
P_noise = fftshift(fft(carrier_noise,N));           % Fourier transform
figure;
plot(fvec,20*log10(abs(P_noise)));
%% Remove carrier
% Demodulation
Icarrier_remove=sqrt(2)*real(carrier_noise).*cos(2*pi*f_carrier*t);
Qcarrier_remove=sqrt(2)*imag(carrier_noise).*sin(2*pi*f_carrier*t);
carrier_remove=Icarrier_remove+Qcarrier_remove;
N = length(carrier_remove);
P = fftshift(fft(carrier_remove,N));                % Fourier tranform
fvec = (fs/N)*(-floor(N/2):1:ceil(N/2)-1);
figure;
plot(fvec,20*log10(abs(P)));
%% Matched filter
MF_puls=fliplr(RC_puls);                            % Matched filter is a time-reversed pulse shaping filter 
figure;
plot(MF_puls);
mf=conv(MF_puls,Icarrier_remove+1j*Qcarrier_remove);% Make the signal through the matched filter
mf_samp = mf(fsfd*6:end-fsfd*5);
eyed.fsfd=fsfd;
eyed.r=mf_samp;
eyediagram(eyed.r, eyed.fsfd);                      % Plot the eye diagram
N = length(mf_samp);
P_mf = fftshift(fft(mf_samp,N));                    % Fourier transform
fvec = (fs/N)*(-floor(N/2):1:ceil(N/2)-1);
figure;
plot(fvec,20*log10(abs(P_mf)));
%% Decision making (Sample at Ts)
mf_downsample = downsample(mf_samp, fsfd);          % Downsampling the signal after matched filter
scatterplot(mf_downsample); grid on;                % Plot the constellation of the signal after downsampling
[psd.p,psd.f]=pwelch(mf_downsample);                
figure;
plot(psd.f,20*log10(psd.p));                        % Plot the power spectral density
threshold=0.2;                                      % Decide the threshold of to make decision
realpart=real(mf_downsample);
imagpart=imag(mf_downsample);
% Decision making progress
for i=1:length(mf_downsample)
    if realpart(i)>=threshold
        Ifinal(i)=1;
    else
        Ifinal(i)=-1;
    end
    if imagpart(i)>=threshold
        Qfinal(i)=1;
    else
        Qfinal(i)=-1;
    end
end
%% Symbols to bits
final=[Ifinal(1:end-1)',Qfinal(1:end-1)'];
for i=1:length(final)
    if final(i,1)==1 && final(i,2)==1
        finalbits(i,1)=0;
        finalbits(i,2)=0;
    elseif final(i,1)==1 && final(i,2)==-1
        finalbits(i,1)=0;
        finalbits(i,2)=1;
    elseif final(i,1)==-1 && final(i,2)==-1
        finalbits(i,1)=1;
        finalbits(i,2)=0;
    else
        finalbits(i,1)=1;
        finalbits(i,2)=1;
    end
end
finalbits=finalbits';
Xhat=reshape(finalbits,1,length(final)*2);
%% Calculating the error rate
diff=b-Xhat;
error=find(diff~=0);
errorrate=length(error)/length(final);
