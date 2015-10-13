function [ mf_downsample, tsamp ] = symbolSync2( syncSymbol, fsrs, signal )
%% Symbol synchronization function. Allow you to find the right sampling time to use for your signal
%syncSymbol = synchronization symbols used 
%fsrs = oversampling factor 
%signal = signal to apply symbol synchronization
corr = zeros(1,fsrs);
for k=1:fsrs
    mf_down = downsample(signal,fsrs,k-1);
    corr(k) = max(abs(xcorr(mf_down,syncSymbol)));
end
[~,tsamp] = max(corr);
mf_downsample = downsample(signal,fsrs,tsamp-1);


end
