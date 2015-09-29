function [pack, psd, const, eyed] = receiver(tout,fc)

load('seq_modulated_4000');
load('seq2_modulated_4000');

fs = 12e3;                                  % sampling frequency [Hz]
W = 200;                                    % bit rate [bit/sec]
Beta = 0.3;
Rs = 2*W/(Beta+1);
Ts = 1/Rs;
fsfd = ceil(fs/Rs);                         % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)

span = 6;
cor=0;
threshold = 2;


 while max(cor)<threshold
    [~, signal_modulated] = signalRecording(10*Ts, fs);
    cor=xcorr(signal_modulated, seq_modulated_4000);
 end
%     [~,cor_index] = max(cor);
%     figure();
%     plot(cor);
    [~, signal_modulated] = signalRecording(266*Ts, fs);
    signal_modulated = signal_modulated./abs(max(signal_modulated));
    cor=xcorr(signal_modulated, seq2_modulated_4000);
    figure;plot(cor);
    [Icarrier_remove, Qcarrier_remove] = passband2baseband(signal_modulated, fc, fs);
    RC_puls = rtrcpuls(Beta,Ts,fs,span);
    mf_samp = matchedFilter( RC_puls, Icarrier_remove, Qcarrier_remove, fsfd, fs );
    [ Ifinal, Qfinal, mf_downsample ] = decisionMaking( mf_samp, fsfd );
    pack = symbols2bits( Ifinal, Qfinal );
    psd = pwelch(mf_downsample);
    const = mf_downsample;
    eyed = [mf_samp, fsfd];


end
