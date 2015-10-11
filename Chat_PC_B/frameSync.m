function [ pack ] = frameSync( Xhat, syncBits )

[acor,lag] = xcorr(Xhat,syncBits);
[~,I] = max(abs(acor));
delay = lag(I);
pack = Xhat(delay+1:delay+480);

end

