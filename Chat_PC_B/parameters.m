%% Parameter file loading all the shared parameters between the receiver and the 
% transmitter

fs = 12e3;                                   % sampling frequency [Hz]
rb = 500;                                    % bit rate [bit/sec]
M = 4;                                       % Number of symbols in the constellation (QPSK, M=4)
m = log2(M);                                 % Number of bits per symbol
rs = rb/m;                                   % Symbol rate
fsrs = fs/rs;                                % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity)
beta = 0.3;                                  % Roll-off factor used for our RRC pulse
span = 6;                                    % Span used to generate our RRC pulse

barkerBits = [0 0 0 0 0 1 1 0 0 1 0 1 0];    % Barker sequence used for signal detection

load('syncBits.mat')                         % 48 bits synchonization bits

RRC_puls = rtrcpuls(beta,1/rs,fs,span);           % Pulse shaping function