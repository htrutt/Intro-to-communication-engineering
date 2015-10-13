function [ mf_samp ] = matchedFilter( RRC_puls, carrier_remove, fsrs)
%% Make the transmitted baseband signal go through a matched filter
% RRC_puls = root raised cosine used for the matched filtering
% ICarrier_remove = In-phase signal in baseband 
% Qcarrier_remove = Quadrature signal in baseband
% fsfd = oversampling factor 

MF_puls=fliplr(RRC_puls);                            % Matched filter is a time-reversed pulse shaping filter 
mf=conv(MF_puls,carrier_remove);% Make the signal through the matched filter
mf_samp = mf(fsrs*6:end-fsrs*5);

% eyed.fsfd=fsfd;
% eyed.r=mf_samp;
% eyediagram(eyed.r, eyed.fsfd);                      % Plot the eye diagram
% figure;
% plot(real(mf_samp));
% N = length(mf_samp);
% P_mf = fftshift(fft(mf_samp,N));                    % Fourier transform
% fvec = (fs/N)*(-floor(N/2):1:ceil(N/2)-1);
% figure;
% plot(fvec,20*log10(abs(P_mf)));
end

