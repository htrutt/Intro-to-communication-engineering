function [ signal_modulated ] = signalRecording2(rb, fs ,marker_modulated)
%% Function to detect and record our message
% Rs = symbol rate
% fs = sampling frequency
% marker_modulated = barker sequence modulated and used for signal
% detection
cor=0;
threshold = 20;  
recObj = audiorecorder(fs,8,1);              % Set record object
flag = 1;
record(recObj);         % We record for 1 barker sequences
while max(cor)<threshold
   %% Record for a small amount of time as long as the correlation doesn't overpass our threshold
   pause(0.2);
   signal_modulated = getaudiodata(recObj); % Get audio data from the record object
   if flag==1
       cor=xcorr(signal_modulated, marker_modulated);
       flag = 0;
       n = length(signal_modulated);
   else
   signal_xcorr = signal_modulated(n+1:end);
   n = length(signal_modulated);
   cor=xcorr(signal_xcorr, marker_modulated); %Corrolate this data with our modulated barker sequence
   end
end
%% Preamble as been detected so we record for a longer time in order to get our message
pause(500/rb);
stop(recObj);
signal = getaudiodata(recObj);
signal_modulated = signal(end-fs:end)';
end

