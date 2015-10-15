function [ mf_phase, phihat, errorIndicate ] = phaseSync( syncSymbol, mf_downsample, timeDiff)
%% Phase synchronization function. Allow you to find the phase offset of your signal and shift them back
%syncSymbol = synchronization symbols used 
%mf_sample = symbols after downsampling
%timeDiff = indicate where our syncSymbols begin
%mf_phase = symbols after phase synchronization
%phihat = phase offset
%errorIndicate = if the length of our symbol is less than the total length
%of our information and sync symbol, indicate that there is an error
%happenning before this part

sumArg = 0;
conjSync = conj(syncSymbol);

if(timeDiff < 0)
    timeDiff = 0;       % avoiding crashing down
end 

for k =1:length(conjSync)
    arg = angle(mf_downsample(k+timeDiff)*conjSync(k)); % conjugate the derived symbols with our known syncSymbol
    sumArg = sumArg + arg;
end
phihat = sumArg/length(conjSync);                       % add them up and make an average to find the phase shift
mf_phase = mf_downsample * exp(-1j*phihat);             % shift the symbols back    
if length(mf_phase)<length(syncSymbol)+timeDiff+216
    errorIndicate = 1;                                  
else
    mf_phase = mf_phase(timeDiff+length(syncSymbol)+1:timeDiff+length(syncSymbol)+216);
    errorIndicate = 0;                                  % take out the information part of the symbols we get
end


