function [ signal_modulated ] = signalRecording(rb, fs ,marker_modulated)
%% Function to detect and record our message
% Rs = symbol rate
% fs = sampling frequency
% marker_modulated = barker sequence modulated and used for signal
% detection
cor=0;
threshold = 10;  
recObj = audiorecorder(fs,8,1);              % Set record object

while max(cor)<threshold
   %% Record for a small amoun of time as long as the correlation doesn't overpass our threshold
   recordblocking(recObj,15/rb);            % We record for 2 barker sequences
   signal_modulated = getaudiodata(recObj); % Get audio data from the record object
   cor=xcorr(signal_modulated, marker_modulated); %Corrolate this data with our modulated barker sequence
end
   %% Preamble as been detected so we record for a longer time in order to get our message
recordblocking(recObj,600/rb);
signal_modulated = getaudiodata(recObj);
signal_modulated=signal_modulated';
end

