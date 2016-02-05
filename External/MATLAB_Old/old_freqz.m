function [hh,ff] = old_freqz(b,a,n,dum,Fs)
%FREQZ Z-transform digital filter frequency response.
%   When N is an integer, [H,W] = FREQZ(B,A,N) returns the N-point frequency
%   vector W in radians and the N-point complex frequency response vector H
%   of the filter B/A:
%                               -1                -nb 
%        jw  B(z)   b(1) + b(2)z + .... + b(nb+1)z
%     H(e) = ---- = ----------------------------
%                               -1                -na
%            A(z)    1   + a(2)z + .... + a(na+1)z
%   given numerator and denominator coefficients in vectors B and A. The
%   frequency response is evaluated at N points equally spaced around the
%   upper half of the unit circle. If N isn't specified, it defaults to 512.
%
%   [H,W] = FREQZ(B,A,N,'whole') uses N points around the whole unit circle.
%
%   H = FREQZ(B,A,W) returns the frequency response at frequencies 
%   designated in vector W, in radians (normally between 0 and pi).
%
%   [H,F] = FREQZ(B,A,N,Fs) and [H,F] = FREQZ(B,A,N,'whole',Fs) given a 
%   sampling freq Fs in Hz return a frequency vector F in Hz.
%   
%   H = FREQZ(B,A,F,Fs) given sampling frequency Fs in Hz returns the 
%   complex frequency response at the frequencies designated in vector F,
%   also in Hz.
%
%   FREQZ(B,A,...) with no output arguments plots the magnitude and
%   unwrapped phase of B/A in the current figure window.
%
%   See also FILTER, FFT, INVFREQZ, FREQS and GRPDELAY.

% 	Author(s): J.N. Little, 6-26-86, 6-7-88, 9-12-88
%   	   T. Krauss, 2-17-93, add default plots and n vector
%   	   T. Krauss, 4-2-93, add sampling rate
%   Copyright (c) 1988-98 by The MathWorks, Inc.
%   $Revision: 1.23 $  $Date: 1997/12/02 18:36:55 $

error(nargchk(1,5,nargin))
if nargin == 1,
    a = 1;  n = 512;  whole = 'no';  samprateflag = 'no';
elseif nargin == 2,
    n = 512;  whole = 'no';  samprateflag = 'no';
elseif nargin == 3,
    whole = 'no';  samprateflag = 'no';
elseif nargin == 4,
    if isstr(dum),
        whole = 'yes';  samprateflag = 'no';
    else
        whole = 'no';  samprateflag = 'yes';  Fs = dum;
    end
elseif nargin == 5,
    whole = 'yes';  samprateflag = 'yes';
end
a = a(:).';
b = b(:).';
na = length(a);
nb = length(b);
nn = length(n);
if (nn == 1)
    if strcmp(whole,'yes'),
        s = 1;
    else
        s = 2;
    end
    w = (0:n-1)'*2*pi/n/s;
    if s*n < na | s*n < nb
        nfft = lcm(n,max(na,nb));
        h=(fft([b zeros(1,s*nfft-nb)])./fft([a zeros(1,s*nfft-na)])).';
        h = h(1+(0:n-1)*nfft/n);
    else
        h = (fft([b zeros(1,s*n-nb)]) ./ fft([a zeros(1,s*n-na)])).';
        h = h(1:n);
    end
else
%   Frequency vector specified.  Use Horner's method of polynomial
%   evaluation at the frequency points and divide the numerator
%   by the denominator.
%
%   Note: we use positive i here because of the relationship
%            polyval(a,exp(i*w)) = fft(a).*exp(i*w*(length(a)-1))
%               ( assuming w = 2*pi*(0:length(a)-1)/length(a) )
%
    a = [a zeros(1,nb-na)];  % Make sure a and b have the same length
    b = [b zeros(1,na-nb)];
    if strcmp(samprateflag,'no'),
        w = n;
        s = exp(i*w);
    else
        w = 2*pi*n/Fs;
        s = exp(i*w);
    end
    h = polyval(b,s) ./ polyval(a,s);
end

if strcmp(samprateflag,'yes'),
    f = w*Fs/2/pi;
else
    f = w;
end

if nargout == 0,   % default plots - magnitude and phase
    if 0,   % do the same thing for all filters
%    if (length(a) == 1) & ( all(abs(b(nb:-1:1)-b)<sqrt(eps)) ...
%         | all(abs(b(nb:-1:1)+b)<sqrt(eps)) ),
%         linear phase FIR case - just plot magnitude
        if strcmp(samprateflag,'no'),
            plot(f/pi,abs(h));
            xlabel('Normalized frequency (Nyquist == 1)')
        else
            plot(f,abs(h));
            xlabel('Frequency (Hertz)')
        end
        set(gca,'xgrid','on','ygrid','on');
        ylabel('Magnitude Response')
    else
    % plot magnitude and phase
        newplot;
        if strcmp(samprateflag,'no'),
            subplot(211)
            plot(f/pi,20*log10(abs(h)));
            set(gca,'xgrid','on','ygrid','on');
            xlabel('Normalized frequency (Nyquist == 1)')
            ylabel('Magnitude Response (dB)')
            ax = gca;
            subplot(212)
            plot(f/pi,unwrap(angle(h))*180/pi);
            set(gca,'xgrid','on','ygrid','on');
            xlabel('Normalized frequency (Nyquist == 1)')
            ylabel('Phase (degrees)')
            subplot(111)
            axes(ax)
        else
            subplot(211)
            plot(f,20*log10(abs(h)));
            set(gca,'xgrid','on','ygrid','on');
            xlabel('Frequency (Hertz)')
            ylabel('Magnitude Response (dB)')
            ax = gca;
            subplot(212)
            plot(f,unwrap(angle(h))*180/pi);
            set(gca,'xgrid','on','ygrid','on');
            xlabel('Frequency (Hertz)')
            ylabel('Phase (degrees)')
            subplot(111)
            axes(ax)
        end
    end
elseif nargout == 1,
    hh = h;
else
    hh = h;
    ff = f;
end
