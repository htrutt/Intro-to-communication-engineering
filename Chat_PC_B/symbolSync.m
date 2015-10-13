function [ mf_sync ] = symbolSync( syncSymbol, fsrs, signal )
%% Symbol synchronization function. Allow you to find the right sampling time to use for your signal
%syncSymbol = synchronization symbols used 
%fsrs = oversampling factor 
%signal = signal to apply symbol synchronization

sum = zeros(1,length(signal));
for tsamp=1:floor(length(signal)/3)
    for k=1:length(syncSymbol)
        sum(tsamp)=sum(tsamp)+signal((k-1)*fsrs+tsamp)*conj(syncSymbol(k));
    end
end
[~,tsamp]=max(abs(sum));
mf_sync = signal(tsamp:end);


end

