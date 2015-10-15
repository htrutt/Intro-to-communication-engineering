function [Xhat, psd, const, eyed] = receiver(tout,fc)

%% Loading all the necessary parameters for the receiver
run('parameters.m');
load('syncSymbol.mat')                      % Synchronization bits
load('infoBits.mat')

marker_modulated=generate_modulated_signal(fc, barkerBits, m , fsrs, RRC_puls, fs);
%% Signal detection using barker sequence and signal recording 
tic
signal_modulated = signalRecording2(rb, fs ,marker_modulated);
timeElapsed = toc;
if timeElapsed < tout
    
    %% Down conversion from carrier frequency fc to baseband
    carrier_remove = passband2baseband(signal_modulated, fc, fs);
    
    %% Match filtering our signal 
    mf_signal = matchedFilter( RRC_puls,carrier_remove, fsrs);

    %% Symbol/sample synchronization using our synhronization bits and downsampling
    [mf_downsample, tsamp] = symbolSync( syncSymbol, fsrs, mf_signal );
    
    %% Using correlation to find where our syncSymbol begins     
    [acor,lag] = xcorr(mf_downsample,syncSymbol);
    [~,I] = max(acor);
    timeDiff = lag(I);
    %% Applying phase synchronization to our signal 
    [mf_phase, phihat, errorIndicate] = phaseSync( syncSymbol, mf_downsample, timeDiff );
    
    if errorIndicate == 0
    %% Decision making for our estimated symbols using minimum distance decoder
        [ Ifinal, Qfinal ] = decisionMaking( mf_phase );
    
    %% Converting symbols to bits and get our infomation bits
        Xhat = symbols2bits( Ifinal, Qfinal);
    else
        Xhat = [];
        error='Index exceeded'
    end
    
    %% PSD plot
    [pvalue,fvalue] = pwelch(carrier_remove,[],[],length(carrier_remove),fs); % received signal
    pvalue = 10*log10( pvalue/max(pvalue));                                   % normalising our plot
    fvalue = fvalue-fc*2;                                                     % make it symmetric around axix y
    psd = struct('p',pvalue,'f',fvalue);
    toc
    %% Constellation plot 
    const = mf_phase;  % signal after phase synchronisation and before downsampling
    
    %% Eyediagram plot 
    signal_end = ceil(480/rb*fs);      % make an approxiamtion to take out the useful part
    eyed = struct('r',mf_signal(tsamp:signal_end)*exp(-1j*phihat),'fsfd',fsrs);
    
    %% Used for testing without UI
    diff=infoBits-Xhat;
    error=find(diff~=0);
    errorrate=length(error)/length(Xhat)
    scatterplot(mf_phase);
    eyediagram(eyed.r,eyed.fsfd);
    figure;
    plot(fvalue,pvalue);
    axis([-250 250 -inf inf]);
else
    Xhat = [];
    psd = struct('p',[],'f',[]);
    const = [];
    eyed = struct('r',[],'fsfd',[]);
end
end
