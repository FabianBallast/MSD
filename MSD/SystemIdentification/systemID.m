%% Read data from file. 
T = readtable('data.xlsx');

%% Retrieve columns from table.  
x_75V_LowFreq = table2array(T(:, 25));
y_75V_LowFreq = table2array(T(:, 26));
x_375V_LowFreq = table2array(T(:, 27));
y_375V_LowFreq = table2array(T(:, 28));

% Remove NAN's from array with rmmissing()
x_75V_HighFreq = rmmissing(table2array(T(:, 17)));
y_75V_HighFreq = rmmissing(table2array(T(:, 18)));
x_375V_HighFreq = rmmissing(table2array(T(:, 19)));
y_375V_HighFreq = rmmissing(table2array(T(:, 20)));
%% First analyze low frequency parts. 

% Find beginning/end of sine. 
[end_U_75_LF, end_Y_75_LF] = findEnds(x_75V_LowFreq, y_75V_LowFreq);
[end_U_375_LF, end_Y_375_LF] = findEnds(x_375V_LowFreq, y_375V_LowFreq);

% Plot for confirmation
figure(1);
plot(x_75V_LowFreq); hold on;
plot(end_U_75_LF, zeros(1, length(end_U_75_LF)), 'o'); hold off;

figure(2);
plot(y_75V_LowFreq); hold on;
plot(end_Y_75_LF, zeros(1, length(end_Y_75_LF)), 'o'); hold off;

%%
% Analyse each sine wave for gain/phase.
G_75_LW = [];
G_375_LW = [];
f_75_LW = [];
f_375_LW = [];
P_75_LW = [];
P_375_LW = [];

for i = 1:length(end_Y_75_LF)
       
    if(i==1)
        length_75 = end_Y_75_LF(i);
        posWave75V = y_75V_LowFreq(1:end_Y_75_LF(i));
        volWave75V = x_75V_LowFreq(1:end_Y_75_LF(i));
        
        length_375 = end_Y_375_LF(i);
        posWave375V = y_375V_LowFreq(1:end_Y_375_LF(i));
        volWave375V = x_375V_LowFreq(1:end_Y_375_LF(i));
    else
        length_75 = end_Y_75_LF(i) - end_Y_75_LF(i-1);
        posWave75V = y_75V_LowFreq(end_Y_75_LF(i-1):end_Y_75_LF(i));
        volWave75V = x_75V_LowFreq(end_Y_75_LF(i-1):end_Y_75_LF(i));
        
        length_375 = end_Y_375_LF(i) - end_Y_375_LF(i-1);
        posWave375V = y_375V_LowFreq(end_Y_375_LF(i-1):end_Y_375_LF(i));
        volWave375V = x_375V_LowFreq(end_Y_375_LF(i-1):end_Y_375_LF(i));
    end
    
    amp_pos_75V = (max(posWave75V) - min(posWave75V)) / 2;
    amp_vol_75V = (max(volWave75V) - min(volWave75V)) / 2;
    G_75_LW(i) = 20*log10(amp_pos_75V / amp_vol_75V);
    
    amp_pos_375V = (max(posWave375V) - min(posWave375V)) / 2;
    amp_vol_375V = (max(volWave375V) - min(volWave375V)) / 2;
    G_375_LW(i) = 20*log10(amp_pos_375V / amp_vol_375V);
    
    [h, iMaxPos75] = max(posWave75V);
    [h, iMaxVol75] = max(volWave75V);  
    
    [h, iMaxPos375] = max(posWave375V);
    [h, iMaxVol375] = max(volWave375V); 
  
    
    P_temp_75V = (iMaxVol75 - iMaxPos75) / (length_75) * 360;
    if P_temp_75V < -40
        P_75_LW(i) =  P_temp_75V;
    else
        P_75_LW(i) = P_temp_75V - 360; 
    end
    f_75_LW(i) = 1/ (length_75 / 100);
    
    P_temp_375V = (iMaxVol375 - iMaxPos375) / (length_375) * 360;
    if P_temp_375V < -40
        P_375_LW(i) =  P_temp_375V;
    else
        P_375_LW(i) = P_temp_375V - 360; 
    end
    f_375_LW(i) = 1/ (length_375 / 100);

end
%% Then analyze high frequency parts. 

% Find beginning/end of sine. 
[end_U_75_HF, end_Y_75_HF] = findEnds(x_75V_HighFreq, y_75V_HighFreq);
[end_U_375_HF, end_Y_375_HF] = findEnds(x_375V_HighFreq, y_375V_HighFreq);

% Plot for confirmation
figure(3);
plot(x_75V_HighFreq); hold on;
plot(end_U_75_HF, zeros(1, length(end_U_75_HF)), 'o'); hold off;

figure(4);
plot(y_75V_HighFreq); hold on;
plot(end_Y_75_HF, zeros(1, length(end_Y_75_HF)), 'o'); hold off;

%%
% Analyse each sine wave for gain/phase.
G_75_HW = [];
G_375_HW = [];
f_75_HW = [];
f_375_HW = [];
P_75_HW = [];
P_375_HW = [];

for i = 1:13%length(end_U_75_HF)
       
    if(i==1)
        length_75 = end_Y_75_HF(i);
        posWave75V = y_75V_HighFreq(1:end_Y_75_HF(i));
        volWave75V = x_75V_HighFreq(1:end_Y_75_HF(i));
        
        length_375 = end_Y_375_HF(i+1);
        posWave375V = y_375V_HighFreq(1:end_Y_375_HF(i+1));
        volWave375V = x_375V_HighFreq(1:end_Y_375_HF(i+1));
    else
        length_75 = end_Y_75_HF(i) - end_Y_75_HF(i-1);
        posWave75V = y_75V_HighFreq(end_Y_75_HF(i-1):end_Y_75_HF(i));
        volWave75V = x_75V_HighFreq(end_Y_75_HF(i-1):end_Y_75_HF(i));
        
        length_375 = end_Y_375_HF(i+1) - end_Y_375_HF(i);
        posWave375V = y_375V_HighFreq(end_Y_375_HF(i):end_Y_375_HF(i+1));
        volWave375V = x_375V_HighFreq(end_Y_375_HF(i):end_Y_375_HF(i+1));
    end
    
    amp_pos_75V = (max(posWave75V) - min(posWave75V)) / 2;
    amp_vol_75V = (max(volWave75V) - min(volWave75V)) / 2;
    G_75_HW(i) = 20*log10(amp_pos_75V / amp_vol_75V);
    
    amp_pos_375V = (max(posWave375V) - min(posWave375V)) / 2;
    amp_vol_375V = (max(volWave375V) - min(volWave375V)) / 2;
    G_375_HW(i) = 20*log10(amp_pos_375V / amp_vol_375V);
    
    [h, iMaxPos75] = max(posWave75V);
    [h, iMaxVol75] = max(volWave75V);  
    
    [h, iMaxPos375] = max(posWave375V);
    [h, iMaxVol375] = max(volWave375V); 
  
    
    P_temp_75V = (iMaxVol75 - iMaxPos75) / (length_75) * 360;
    if P_temp_75V < -40
        P_75_HW(i) =  P_temp_75V;
    else
        P_75_HW(i) = P_temp_75V - 360; 
    end
    f_75_HW(i) = 1/ (length_75 / 800);
    
    P_temp_375V = (iMaxVol375 - iMaxPos375) / (length_375) * 360;
    if P_temp_375V < -40
        P_375_HW(i) =  P_temp_375V;
    else
        P_375_HW(i) = P_temp_375V - 360; 
    end
    f_375_HW(i) = 1/ (length_375 / 800);

end

%% Guess for transfer function
s = tf('s');
zeta = 1;
omega = 2.3 * 2 * pi; 
k = 80000;
G = 1/s * k / (s^2 + 2 * zeta * omega * s + omega^2);

[mag,phase,wout] = bode(G,{10^-2 * 2 * pi, 10^2 * 2 * pi});
mag = 20 * log10(squeeze(mag));

% figure();
% bode(G);

%% Plot results

figure();
tiledlayout(2,1); 
nexttile;
semilogx(f_75_LW, G_75_LW, 'b'); grid on; hold on;
semilogx(f_375_LW, G_375_LW, 'r'); 
semilogx(f_75_HW, G_75_HW, 'k'); 
semilogx(f_375_HW, G_375_HW, 'g');
semilogx(wout / 2 / pi, mag, 'm'); hold off;
ylabel("Gain (dB)");
xlabel("Frequency (Hz)");nexttile;
semilogx(f_75_LW,  P_75_LW, 'b'); hold on;
semilogx(f_375_LW, P_375_LW, 'r');
semilogx(f_75_HW, P_75_HW, 'k'); 
semilogx(f_375_HW, P_375_HW, 'g');
semilogx(wout/ 2 / pi, squeeze(phase), 'm');
hold off;
ylim([-270, 0]);
ylabel("Phase (deg)");
xlabel("Frequency (Hz)");
grid on;



%%

function [endPointsX, endPointsY] = findEnds(pointsX, pointsY)

    downY = 0;
    downX = 0;
    prevY  = 0;
    prevX = 0;
    endPointsX = [];
    endPointsY = [];
    iX = 1;
    iY = 1;
    iPrevX = 0;
    iPrevY = 0;
    
    for i = 2:length(pointsY)
        if(downY == 1 && pointsY(i) - prevY > 0 && pointsY(i)< 5000 && i - iPrevY > 15)
            endPointsY(iY) = i;
            iY = iY + 1;
            downY = 0;
            iPrevY = i;
        end

        if(pointsY(i) - prevY < 0)
            downY = 1;
        elseif (pointsY(i) - prevY > 0)
            downY = 0;
        end

        prevY = pointsY(i);
        
        if(downX == 1 && pointsX(i) - prevX > 0 && pointsX(i)< 5000 && i - iPrevX > 5)
            endPointsX(iX) = i;
            iX = iX + 1;
            downX = 0;
            iPrevX = i;
        end

        if(pointsX(i) - prevX < 0)
            downX = 1;
        elseif (pointsX(i) - prevX > 0)
            downX = 0;
        end

        prevX = pointsX(i);
    end
    
    
    endPointsY(iY) = i;
end