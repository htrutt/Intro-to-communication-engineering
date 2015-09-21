function [pack, psd, const, eyed] = receiver(tout,fc)

fs = 12e3;                                   % sampling frequency [Hz]
rb = 600;                                    % bit rate [bit/sec]
M = 4;                                       % Number of symbols in the constellation (QPSK, M=4)
m = log2(M);                                 % Number of bits per symbol
fd = rb/m;                                   % Symbol rate
fsfd = fs/fd;                                % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)
threshold = 0.2;                             % Used for decision making

[N, signal_modulated] = signalRecording(tout, fs);
if N<=1000
    pack=[]; psd = []; const=[]; eyed = [];
else
    [Icarrier_remove, Qcarrier_remove] = passband2baseband(signal_modulated, fc, fs);
    RC_puls = rtrcpuls(0.4,1/fd,fs,6);
    mf_samp = matchedFilter( RC_puls, Icarrier_remove, Qcarrier_remove, fsfd, fs );
    [ Ifinal, Qfinal, mf_downsample ] = decisionMaking( mf_samp, fsfd, threshold );
    pack = symbols2bits( Ifinal, Qfinal );
    psd = pwelch(mf_downsample);
    const = mf_downsample;
    eyed = [mf_samp, fsfd];
end

end