function [Xhat, psd, const, eyed] = receiver(tout,fc)

%% Loading all the necessary parameters for the receiver
run('parameters.m');
load('syncSymbol.mat')                      % Synchronization bits
load('infoBits.mat')
%markerBits= repmat(barkerBits,1,2);         % Marker bits using for signal detection
marker_modulated=generate_modulated_signal(fc,barkerBits,rb, RRC_puls);
%% Signal detection using barker sequence and signal recording 
tic
signal_modulated = signalRecording(rb, fs ,marker_modulated);
timeElapsed = toc;
if timeElapsed < tout
    
    %% Down conversion from carrier frequency fc to baseband
    carrier_remove = passband2baseband(signal_modulated, fc, fs);
    
    %% Match filtering our signal 
    mf_signal = matchedFilter( RRC_puls,carrier_remove, fsrs);

    %% Symbol/sample synchronization using our synhronization bits
    [mf_downsample, tsamp] = symbolSync2( syncSymbol, fsrs, mf_signal );
    
    %% Downsampling the signal after matched filter     
    [acor,lag] = xcorr(mf_downsample,syncSymbol);
    
    [~,I] = max(abs(acor));
    
    timeDiff = lag(I)
    %% Applying phase synchronization to our signal 
    [mf_phase, phihat] = phaseSync2( syncSymbol, mf_downsample, timeDiff );
    
    %% Decision making for our estimated symbols using minimum distance decoder
    [ Ifinal, Qfinal ] = decisionMaking( mf_phase );
    
    %% Converting symbols to bits
    Xhat = symbols2bits( Ifinal, Qfinal);
    
    %% Use our synchronization bits to do frame synchronization
    
    bitsRestore = frameSync( Xhat, syncBits );
 
    %% received information bits
    Xhat = bitsRestore(length(syncBits)+1:end); 
    
    %% PSD plot
    [pvalue,fvalue] = pwelch(carrier_remove,[],[],length(carrier_remove),fs); % received signal
    pvalue = 10*log10( pvalue/max(pvalue));                                   % normalising our plot
    fvalue = fvalue-fc*2;                                                     % make it symmetric around axix y
    psd = struct('p',pvalue,'f',fvalue);
    
    %% Constellation plot 
    const = mf_phase(1:250);  % signal after phase synchronisation and before downsampling
    
    % Eyediagram plot 
    signal_end = ceil(480/rb*12000);      % make an approxiamtion
    eyed = struct('r',mf_signal(tsamp:signal_end)*exp(-1j*phihat),'fsfd',fsrs);
    
    % Used for testing without UI
%     diff=infoBits-Xhat;
%     error=find(diff~=0);
%     errorrate=length(error)/length(Xhat)
%     scatterplot(mf_phase(1:250));   % discard the zeros in the end (make an approximation)
%     eyediagram(eyed.r,eyed.fsfd);
%     figure;
%     plot(fvalue,pvalue);
%     axis([-250 250 -inf inf]);
else
    Xhat = [];
    psd = struct('p',[],'f',[]);
    const = [];
    eyed = struct('r',[],'fsfd',[]);
end
end
