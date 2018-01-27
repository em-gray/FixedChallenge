Fs = 200;             % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 1500;             % Length of signal (what would this be?)
t = (0:L-1)*T;        % Time vector

plot(1000*t(1:50),X(1:50));
title('Raw Signal')
xlabel('t (milliseconds)')
ylabel('X(t)')

i = 0

while i>=0
    vectory[i] = str2double(y)
    
    vectorx[i] = x
    
FFT = fft(vectory, vectorx)
       
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

