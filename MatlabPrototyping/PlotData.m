% After arduino has been setup, run PlotData.m to start data acquisition
% Use CTRL+C to terminate script
% Run CloseSerial.m script to close the arduino serial connection
% Once arduino is initially setup, will continuously perform data
% acquisition

% Real-time plot of data from a single channel is displayed along with the
% FFT of this signal

% The time and voltage signals are saved to data.mat for future analysis

function [] = PlotData()

    close all;
    
    % Serial object used to close the arduino serial connection
    global arduino;
    % A = time, B = voltage
    global A;
    global B;
  
    % Save the serial port name in comPort variable.
    comPort = '/dev/cu.usbmodem1411';
    if(~exist('serialFlag','var'))
    [arduino,serialFlag] = setupSerial(comPort);
    end

    % Create clean up object to execute when program terminates
    cleanupObj = onCleanup(@() cleanup());
    
    % Initialize loop and timestamp
    t = 1;
    t0 = datevec(now);
    i = 1;
    A = nan(50000,1);
    B = zeros(50000,1);
    k = 1;
    
    while t>0
       % Read data from arduino
       mode = 'y'; % channel 1
       j = 0;
       
       % Buffer 1000 samples  
       while j<1000
           y = readVal(arduino,mode);
           
           % Get timestamp
           t1 = datevec(now);
           x = etime(t1,t0);
           
           % Save to vector
           A(i,1) = x;
           B(i,1) = str2double(y);
           i = i + 1; 
           j = j + 1;
       end
       
       % Buffered Timestamp
       t1 = datevec(now);
       x = etime(t1,t0);
       disp(x);
           
       % Plot Data
       subplot(2,1,1);
       plot(A,B);
       xlim([x-3 x]);
       ylim([0 1]);
       drawnow limitrate;
       
       % FFT
       subplot(2,1,2);
       v = B(k:i-1,1);  %load the vector with voltage readings  
       t2 = A(k:i-1,1);                                           % Convert To �seconds� From �milliseconds�
       L = length(t2);
       Ts = mean(diff(t2));                                     % Sampling Interval (sec)
       Fs = 1/Ts;                                              % Sampling Frequency
       Fn = Fs/2;
       vc = v - mean(v);                                       % Subtract Mean (�0 Hz�) Component
       FTv = fft(vc)/L;                                        % Fourier Transform
       Fv = linspace(0, 1, fix(L/2)+1)*Fn;                     % Frequency Vector (Hz)
       Fv = Fv.';
       Iv = 1:length(Fv);                                      % Index Vector
       C = abs(FTv(Iv))*2;
       k = i-1;
       plot(Fv, C);
       grid;
       xlabel('Frequency (Hz)');
       ylabel('Amplitude (V?)');
       xlim([0 100]);
       ylim([0 0.005]);
       drawnow;
    end
end

function[obj,flag] = setupSerial(comPort)
    % It accept as the entry value, the index of the serial port
    % Arduino is connected to, and as output values it returns the serial
    % element obj and a flag value used to check if when the script is compiled
    % the serial element exists yet.
    flag = 1;
    % Initialize Serial object
    obj = serial(comPort);
    set(obj,'Timeout',600);
    set(obj,'DataBits',8);
    set(obj,'StopBits',1);
    set(obj,'BaudRate',9600);
    set(obj,'Parity','none');
    fopen(obj);
    a = 'b';
    while (a~='a')
    a=fread(obj,1,'uchar');
    end
    if (a=='a')
    disp('Serial read');
    end
    fprintf(obj,'%c','a');
    mbox = msgbox('Serial Communication setup'); uiwait(mbox);
    fscanf(obj,'%u');
end

function [output] = readVal(s,command)
    % Serial send read request to Arduino
    fprintf(s,command);
    % Read value returned via Serial communication
    output = fgetl(s);
end

function cleanup()
    global arduino;
    global A;
    global B;
    save('serialObj.mat', 'arduino');
    save('data.mat', 'A', 'B');
    disp('goodbye');
end
    

