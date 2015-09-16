function transmitter(packet,fc)

symbols = mapBits2Symbols(packet);
figure();scatterplot(symbols);

signal = pulseShape(symbols);

baseband2passband(signal, fc);

end