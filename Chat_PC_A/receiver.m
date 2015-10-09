function [Xhat, psd, const, eyed] = receiver(tout,fc)

%% Loading all the necessary parameters for the receiver
run('./parameters');
load('syncSymbol.mat')                      % Synchronization bits
markerBits= repmat(barkerBits,1,2);         % Marker bits using for signal detection
marker_modulated=generate_modulated_signal(fc,markerBits,rb, RRC_puls);

tic
%% Signal detection using barker sequence and signal recording 
signal_modulated = signalRecording(rs, fs ,marker_modulated);


timeElapsed = toc;
if timeElapsed < tout
    
    %% Down conversion from carrier frequency fc to baseband
    [Icarrier_remove, Qcarrier_remove] = passband2baseband(signal_modulated, fc, fs);
    
    %% Match filtering our signal 
    mf_signal = matchedFilter( RRC_puls, Icarrier_remove, Qcarrier_remove, fsrs);
    
    %% Symbol/sample synchronization using our synhronization bits
    mf_sync = symbolSync( syncSymbol, fsrs, mf_signal );
    
    %% Downsampling the signal after matched filter
    mf_downsample = downsample(mf_sync, fsrs);        
    
    %% Applying phase synchronization to our signal 
    mf_phase = phaseSync( syncSymbol, mf_downsample );
    
    %% Decision making for our estimated symbols using minimum distance decoder
    [ Ifinal, Qfinal ] = decisionMaking( mf_phase );
    
    %% Converting symbols to bits
    Xhat = symbols2bits( Ifinal, Qfinal, mf_phase);
    
    %% Use our synchronization bits to do frame synchronization
    bitsRestore = frameSync( Xhat, syncBits );
    %TODO : check the frame sync
 
    %% received information bits
    Xhat = bitsRestore(length(syncBits)+1:end); 
    
    %% PSD plot
    [pvalue,fvalue] = pwelch(Icarrier_remove+Qcarrier_remove,[],[],2048,fs); % received signal
    pvalue = 10*log10( pvalue/max(pvalue));                                  % normalising our plot
    psd = struct('p',pvalue,'f',fvalue);
    
    %% Constellation plot 
    const = mf_phase(length(syncSymbol)+1:length(syncSymbol)+216);  % signal after phase synchronisation and before downsampling
    
    % Eyediagram plot 
    eyed = struct('r',mf_sync(34*fsrs:216*fsrs),'fsfd',fsrs);
    
else
    Xhat = [];
    psd = struct('p',[],'f',[]);
    const = [];
    eyed = struct('r',[],'fsfd',[]);
end
end
