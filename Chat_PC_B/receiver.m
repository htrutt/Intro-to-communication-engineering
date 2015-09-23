function [pack, psd, const, eyed] = receiver(tout,fc)

fs = 12e3;                                  % sampling frequency [Hz]
W = 200;                                    % bit rate [bit/sec]
Beta = 0.3;
Rs = 2*W/(Beta+1);
Ts = 1/Rs;
fsfd = ceil(fs/Rs);                         % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)

span = 6;

[N, signal_modulated] = signalRecording(6, fs);
if N<=1000
    pack=[]; psd = []; const=[]; eyed = [];
else
    [Icarrier_remove, Qcarrier_remove] = passband2baseband(signal_modulated, fc, fs);
    RC_puls = rtrcpuls(Beta,Ts,fs,span);
    mf_samp = matchedFilter( RC_puls, Icarrier_remove, Qcarrier_remove, fsfd, fs );
    [ Ifinal, Qfinal, mf_downsample ] = decisionMaking( mf_samp, fsfd );
    pack = symbols2bits( Ifinal, Qfinal );
    psd = pwelch(mf_downsample);
    const = mf_downsample;
    eyed = [mf_samp, fsfd];
end

end
