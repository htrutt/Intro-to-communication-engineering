function [ mf_phase, phihat ] = phaseSync2( syncSymbol, mf_downsample, timeDiff)
sumArg = 0;
conjSync = conj(syncSymbol);

if(timeDiff < 0)
    timeDiff = 0;
end 

for k =1:length(conjSync)
    arg = angle(mf_downsample(k+timeDiff)*conjSync(k));
    sumArg = sumArg + arg;
end
phihat = sumArg/length(conjSync);
mf_phase = mf_downsample * exp(-1j*phihat);


end


