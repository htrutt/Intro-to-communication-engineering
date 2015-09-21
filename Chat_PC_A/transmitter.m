function transmitter(packet,fc)

symbols = mapBits2Symbols(packet);
xlabel('Real Axis');ylabel('Imaginary Axis');title('QPSK Constellation');
figure();scatterplot(symbols);

signal = pulseShape(symbols);

signal_out=baseband2passband(signal, fc);
figure();plot(signal_out);

[a1, b2] = passband2baseband(signal_out,fc);
figure();plot(a1+1i*b2);
matched_filter(a1)
end