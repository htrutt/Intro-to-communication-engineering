function [ x_upsample ] = bits2symbols( packets, fsfd, m )
% Transfer the data bits to symbols and upsample them to get the
% transmitted signal
% Constellation or bit to symbol mapping
s = [(1 + 1i) (1 - 1i) (-1 + 1i) (-1 - 1i)]/sqrt(2);% Constellation 1 - QPSK/4-QAM
                                                    % s = exp(1i*((0:3)*pi/2 + pi/4)); % Constellation 1 - same constellation generated as PSK
scatterplot(s); grid on;                            % Constellation visualization
packets_buffer = buffer(packets, m)';               % Group bits into bits per symbol
sym_idx = bi2de(packets_buffer, 'left-msb')'+1;     % Bits to symbol index
x = s(sym_idx);                                     % Look up symbols using the indices  
x_upsample = upsample(x, fsfd);                     % Space the symbols fsfd apart, to enable pulse shaping using conv.
x_upsample(end-fsfd+2:end) = [];

end

