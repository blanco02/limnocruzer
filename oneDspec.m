%% 1D spatial spectrum

addpath('wtc');

d=loadLSdata('langmuir.csv');

xx = min(d.dist):0.1:max(d.dist);

yy = interp1(d.dist,d.data(:,7),xx,'linear');

plot(xx,yy);
ylabel('Chlorophyll (RFU)');
xlabel('Distance (m)');
wt([xx yy]);


%% fft?
xx = xx(1340:end);
yy = yy(1340:end);
yy = detrend(yy);
Fs = 10;
L = length(yy);
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(yy,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

% Plot single-sided amplitude spectrum.
semilogy(f,2*abs(Y(1:NFFT/2+1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
