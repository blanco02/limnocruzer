function [scales, powers] = gSpectrum(dates, data, toPlot)
%GSPECTRUM Calulate the power spectra for the supplied data
%   Detailed explanation goes here

Ts = 1000/mean(diff(dates));              % Samples per km

powers = abs(fft(data)).^2;              % Vector of power coefficients

N = length(data);                        % Create a vector of digital
tt = (-N/2+.5:N/2-.5)/N;                 % frequencies

scales = tt.*Ts;                         % Scales = Frequencies in cycles 
                                         % per year

if(nargin < 3); return; end;

if(strcmpi(toPlot,'plot'))               % Plot the power spectrum
    figure
    plot(scales,fftshift(powers))
    title('Power Spectrum')
    xlabel('Frequency (cycles/km)')
    ylabel('Power')
end
end

