function [ Ifinal, Qfinal, mf_downsample ] = decisionMaking( mf_samp, fsfd )
% Downsample the signal and make decision according to the specified
% threshold to transfer the signal to symbols
mf_downsample = downsample(mf_samp, fsfd);          % Downsampling the signal after matched filter
% scatterplot(mf_downsample); grid on;                % Plot the constellation of the signal after downsampling
% [psd.p,psd.f]=pwelch(mf_downsample);                
% figure;
% plot(psd.f,20*log10(psd.p));                        % Plot the power spectral density

s = [(1 + 1i) (1 - 1i) (-1 + 1i) (-1 - 1i)]/sqrt(2);% Constellation 1 - QPSK/4-QAM
% Decision making progress
Ifinal=zeros(1,length(mf_downsample));
Qfinal=zeros(1,length(mf_downsample));
    for i=1:length(mf_downsample)
        D1=norm(s(1)-mf_downsample(i));%Calculate euclidean distance to each
        D2=norm(s(2)-mf_downsample(i));%point of our constellation
        D3=norm(s(3)-mf_downsample(i));
        D4=norm(s(4)-mf_downsample(i));
        D=[D1 D2 D3 D4]; %Put all the distance in one vector
        [~, I]=min(D);   %Search for the index of the smallest value
        Ifinal(i)=real(s(I)); %And use this index to determine which symbol was send
        Qfinal(i)=imag(s(I));
    end

end

