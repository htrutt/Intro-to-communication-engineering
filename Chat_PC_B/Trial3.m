%% bits to Symbols
clc; clear all; close all

% headBits = [0 1 0 1 0 1 0 1];
% trainingLen = 60;
% trainingBits = randsrc(1,trainingLen,[0 1]);
fs = 12e3;                                          % sampling frequency [Hz]
rb = 600;                                           % bit rate [bit/sec]
infoLen = 432;

% Len = length(headBits) + trainingLen + infoLen;
% number of bits to transmit
% Constellation or bit to symbol mapping
s = [(1 + 1i) (1 - 1i) (-1 + 1i) (-1 - 1i)]/sqrt(2); % Constellation 1 - QPSK/4-QAM
                                                    % s = exp(1i*((0:3)*pi/2 + pi/4)); % Constellation 1 - same constellation generated as PSK
scatterplot(s); grid on;                            % Constellation visualization
M = length(s);                                      % Number of symbols in the constellation
m = log2(M);                                        % Number of bits per symbol
fd = rb/m;                                          % Symbol rate
fsfd = fs/fd;                                       % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)
rng('shuffle')
infoBits = randsrc(1,infoLen,[0 1]);
% Information bits
dataBits = [ones(1,18), infoBits];
syncBits = ones(1,18);
b_buffer = buffer(dataBits, m)';                           % Group bits into bits per symbol
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
audiowrite('trial.wav',carrier,fs)
%% Signal through AWGN
% snr=100;                                             % Signal-to-noise ratio
% carrier_noise=awgn(Icarrier+1j*Qcarrier,snr);       % Through Gussain white noise channel
% N = length(carrier_noise);
% fvec = (fs/N)*(-floor(N/2):1:ceil(N/2)-1);
% P_noise = fftshift(fft(carrier_noise,N));           % Fourier transform
% figure;
% plot(fvec,20*log10(abs(P_noise)));

[trial, carrier_noise] = signalRecording(5, fs);
% envelope = abs(hilbert(carrier_noise));
% figure;
% plot(envelope); % used for detect where voice signal begins
%% Remove carrier
% Demodulation
% Icarrier_remove=sqrt(2)*real(carrier_noise).*cos(2*pi*f_carrier*t);
% Qcarrier_remove=sqrt(2)*imag(carrier_noise).*sin(2*pi*f_carrier*t);
t=0:1/fs:(5-1/fs);
Icarrier_remove=sqrt(2)*carrier_noise'.*cos(2*pi*f_carrier*t);
Qcarrier_remove=sqrt(2)*carrier_noise'.*sin(2*pi*f_carrier*t);
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

%% Symbol Synchronization

% some little fluctuation need to be removed before the real data signal
mf_samp = mf_samp(real(mf_samp)~=0);
syncSymbol = x(1:length(syncBits)/2);
% [acor,lag] = xcorr(mf_samp,syncSymbol);
% [~,I] = max(abs(acor));
% timeDiff = lag(I);
%% Decision making (Sample at Ts)
mf_downsample = downsample(mf_samp, fsfd);          % Downsampling the signal after matched filter
mf_downsample = mf_downsample(1:end-1);
% mf_downsample = mf_samp(timeDiff:fsfd:timeDiff+fsfd*(length(dataBits)/2-1));
scatterplot(mf_downsample); grid on;                % Plot the constellation of the signal after downsampling

[psd.p,psd.f]=pwelch(mf_downsample);                
figure;
plot(psd.f,20*log10(psd.p));                        % Plot the power spectral density

sumArg = 0;
conjSync = conj(syncSymbol);
for k =1:length(conjSync)
    arg = angle(mf_downsample(k)*conjSync(k));
    sumArg = sumArg + arg;
end
phihat = sumArg/length(conjSync);
mf_downsample = mf_downsample * exp(-1j*phihat);
scatterplot(mf_downsample); grid on; 
% threshold=0;                                      % Decide the threshold of to make decision
% realpart=real(mf_downsample);
% imagpart=imag(mf_downsample);
% % Decision making progress
% for i=1:length(mf_downsample)
%     if realpart(i)>=threshold
%         Ifinal(i)=1;
%     else
%         Ifinal(i)=-1;
%     end
%     if imagpart(i)>=threshold
%         Qfinal(i)=1;
%     else
%         Qfinal(i)=-1;
%     end
% end
Ifinal=zeros(1,length(mf_downsample));
Qfinal=zeros(1,length(mf_downsample));
    for i=1:length(mf_downsample)
        D1=norm(s(1)-mf_downsample(i));%Calculate euclidean distance to each
        D2=norm(s(2)-mf_downsample(i));%point of our constellation
        D3=norm(s(3)-mf_downsample(i));
        D4=norm(s(4)-mf_downsample(i));
        D=[D1 D2 D3 D4]; %Put all the distance in one vector
        [~, I]=min(D);   %Search for the index of the smallest value
        Ifinal(i)=sqrt(2)*real(s(I)); %And use this index to determine which symbol was send
        Qfinal(i)=sqrt(2)*imag(s(I));
    end
%% Symbols to bits
final=[Ifinal(1:end)',Qfinal(1:end)'];
finalbits=zeros(length(mf_downsample),2);
for i=1:length(final)
    if final(i,1)==1 && final(i,2)==1
        finalbits(i,1)=0;
        finalbits(i,2)=0;
    elseif final(i,1)==1 && final(i,2)==-1
        finalbits(i,1)=0;
        finalbits(i,2)=1;
    elseif final(i,1)==-1 && final(i,2)==1
        finalbits(i,1)=1;
        finalbits(i,2)=0;
    else
        finalbits(i,1)=1;
        finalbits(i,2)=1;
    end
end
finalbits=finalbits';
Xhatt=reshape(finalbits,1,length(final)*2);
%% Frame detection
syncBits = ones(1,9);
corr = conv(Xhatt,fliplr(syncBits));
[tmp, idx] = max(corr);
delay_hat = idx - length(syncBits);
Xhat = Xhatt(1+delay_hat:length(dataBits)+delay_hat);
%% Calculating the error rate
diff=dataBits-Xhat;
error=find(diff~=0);
errorrate=length(error)/length(Xhat);
