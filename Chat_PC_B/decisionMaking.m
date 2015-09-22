function [ Ifinal, Qfinal, mf_downsample ] = decisionMaking( mf_samp, fsfd, threshold )
% Downsample the signal and make decision according to the specified
% threshold to transfer the signal to symbols
mf_downsample = downsample(mf_samp, fsfd);          % Downsampling the signal after matched filter
% scatterplot(mf_downsample); grid on;                % Plot the constellation of the signal after downsampling
% [psd.p,psd.f]=pwelch(mf_downsample);                
% figure;
% plot(psd.f,20*log10(psd.p));                        % Plot the power spectral density
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

end

