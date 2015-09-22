function [pack, psd, const, eyed] = receiver(tout,fc)

fs = 12e3;                                  % sampling frequency [Hz]
W = 200;                                    % bit rate [bit/sec]
Beta = 0.3;
Rs = 2*W/(Beta+1);
fsfd = ceil(fs/Rs);                         % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)

span = 6;
threshold = 0.2;                            % Used for decision making

Ts = 1/Rs;
if N<=1000
    pack=[]; psd = []; const=[]; eyed = [];
else
    [Icarrier_remove, Qcarrier_remove] = passband2baseband(signal_modulated, fc, fs);
    RC_puls = rtrcpuls(Beta,Ts,fs,span);
    mf_samp = matchedFilter( RC_puls, Icarrier_remove, Qcarrier_remove, fsfd, fs );
    [ Ifinal, Qfinal, mf_downsample ] = decisionMaking( mf_samp, fsfd, threshold );
    pack = symbols2bits( Ifinal, Qfinal );
    psd = pwelch(mf_downsample);
    const = mf_downsample;
    eyed = [mf_samp, fsfd];
end

end