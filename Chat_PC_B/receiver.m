function [Xhat, psd, const, eyed] = receiver(tout,fc)

%% Loading all the necessary parameters for the receiver
run('parameters.m');
load('syncSymbol.mat')                      % Synchronization bits
syncLength = length(syncSymbol);

% markerBits= repmat(barkerBits,1,2);         % Marker bits using for signal detection
marker_modulated=generate_modulated_signal(fc,barkerBits,rb, RRC_puls);

tic
%% Signal detection using barker sequence and signal recording 
signal_modulated = signalRecording(rb, fs ,marker_modulated);


timeElapsed = toc;
if timeElapsed < tout
    
    %% Down conversion from carrier frequency fc to baseband
    carrier_remove = passband2baseband(signal_modulated, fc, fs);
    
    %% Match filtering our signal 
    mf_signal = matchedFilter( RRC_puls,carrier_remove, fsrs);
    
    %% Symbol/sample synchronization using our synhronization bits
    mf_sync = symbolSync( syncSymbol, fsrs, mf_signal );
    
    %% Downsampling the signal after matched filter
    mf_downsample = downsample(mf_sync, fsrs);        
    
    %% Applying phase synchronization to our signal 
    mf_phase = phaseSync( syncSymbol, mf_downsample(1:syncLength+216) );
    
    %% Decision making for our estimated symbols using minimum distance decoder
    [ Ifinal, Qfinal ] = decisionMaking( mf_phase(syncLength+1:end) );
    
    %% Converting symbols to bits
    Xhat = symbols2bits( Ifinal, Qfinal);
    
    %% Use our synchronization bits to do frame synchronization
%     bitsRestore = frameSync( Xhat, syncBits );
    %TODO : check the frame sync
 
    %% received information bits
%     Xhat = bitsConverted(length(syncBits)+1:length(syncBits)+432); 
    
    %% PSD plot
    [pvalue,fvalue] = pwelch(carrier_remove,[],[],length(carrier_remove),fs,'centered'); % received signal
    pvalue = 10*log10( pvalue/max(pvalue));                                  % normalising our plot
    psd = struct('p',pvalue,'f',fvalue);
    
    %% Constellation plot 
    const = mf_phase;  % signal after phase synchronisation and before downsampling
    
    % Eyediagram plot 
    eyed = struct('r',mf_sync(syncLength*fsrs+1:216*fsrs),'fsfd',fsrs);
    
else
    Xhat = [];
    psd = struct('p',[],'f',[]);
    const = [];
    eyed = struct('r',[],'fsfd',[]);
end
end
