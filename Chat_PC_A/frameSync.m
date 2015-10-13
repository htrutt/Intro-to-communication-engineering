function [ pack ] = frameSync( Xhat, syncBits )

[acor,lag] = xcorr(Xhat,syncBits);
[~,I] = max(abs(acor));
delay = lag(I);

if(length(Xhat)>=480+delay)
    pack = Xhat(delay+1:delay+480);
else
    error='Index exceeded'
    pack=[];
end 

end

