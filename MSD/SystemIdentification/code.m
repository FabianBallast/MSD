clear all;
close all;
%% Read data for velocity mapping
Tvel = readtable('data.xlsx','Sheet', 'Velocity');

tvel = table2array(Tvel(:, 1));

V_nomap = table2array(Tvel(:, 3));
vel_nomap = table2array(Tvel(:, 4));

V_map = table2array(Tvel(:, 6));
vel_map = table2array(Tvel(:, 7));

%% Plot results
figure();
plot(tvel, vel_nomap);
title('Velocity over time without mapping.');
xlim([0, max(tvel)]);
xlabel('Time (s)');
ylabel('Velocity (deg/s)');

figure();
plot(tvel, vel_map);
title('Velocity over time with mapping.');
xlim([0, max(tvel)]);
xlabel('Time (s)');
ylabel('Velocity (deg/s)');

figure();
plot(V_nomap, vel_nomap, '.');
title('Velocity versus voltage without mapping.');
xlim([min(V_nomap), max(V_nomap)]);
xlabel('Voltage (V)');
ylabel('Velocity (deg/s)');

figure();
plot(V_map, vel_map, '.');
title('Velocity versus voltage with mapping.');
xlim([min(V_map), max(V_map)]);
xlabel('Voltage (V)');
ylabel('Velocity (deg/s)');

%% Read data for system identification
Tvel = readtable('data.xlsx','Sheet', 'SystemID');

tID = table2array(Tvel(:, 1));

V_ID = table2array(Tvel(:, 3));
Y_ID = table2array(Tvel(:, 4));

%% Plot basic results
figure();
plot(tID, V_ID);
xlabel('Time (s)');
ylabel('Voltage (V)');
xlim([0, max(tID)]);
title('Input data');

figure();
plot(tID, Y_ID);
xlabel('Time (s)');
ylabel('Position (deg)');
xlim([0, max(tID)]);
title('Output data');

%% Do system identification
data = iddata(Y_ID, V_ID, tID(2), 'Name', 'DC-motor');
data.InputName = 'Voltage';
data.InputUnit = 'V';
data.OutputName = 'Angular position';
data.OutputUnit = 'deg';
data.Tstart = 0;
data.TimeUnit = 's';

% Initial values
k = 80000;
zeta =1;
omega = 2.3 * 2 * pi; 

init_sys = idgrey('motorDyn',{'k',k; 'zeta', zeta; 'omega', omega},'c');
init_sys.Structure.Parameters(1).Maximum = 200000;
init_sys.Structure.Parameters(2).Maximum = 2;
init_sys.Structure.Parameters(3).Maximum = 100;

init_sys.Structure.Parameters(1).Minimum = 0;
init_sys.Structure.Parameters(2).Minimum = 0;
init_sys.Structure.Parameters(3).Minimum = 0.01;

sys = greyest(data,init_sys);
figure();
opt = compareOptions('InitialCondition','zero');
compare(data,sys,Inf,opt);

%% Find parameters
values = getpvec(sys);

k_motor = values(1);
zeta_motor = values(2);
omega_motor = values(3); 

s = tf('s');
G = 1/s * k_motor/ (s^2+2*zeta_motor*omega_motor*s+omega_motor^2);

%% Feedforward and feedback filter
omega_control = 100;
C_ff = 1 / G * (1/(s/omega_control + 1)^4);

wc = 35;
gain_G = abs(evalfr(G, wc * 1j));
kp = 1/(5*gain_G);
wi = 1/10 * wc;
wd = 1/5 * wc;
wt = 5 * wc;
C_fb = kp*((1 + s/wd)/(1 + s/wt));

%% Bode plots
figure();
bode(C_ff*G);

figure();
bode(C_fb*G);
margin(C_fb*G);

T = (C_fb*G) / (1+C_fb*G);
S = 1/ (1+C_fb*G);
figure();
bodemag(T,S, {0.1, 1000});
legend('Comp. Sens.', 'Sensitivity');
%% Find speed and acc
Tspeed = readtable('data.xlsx','Sheet', 'Prefilter');

tspeed = table2array(Tspeed(:,1));
yspeed = table2array(Tspeed(:,2));

%% Plot data

r = accel(0.5, tspeed(2), 2400, 18000);

figure();
plot(tspeed, yspeed,'.'); hold on;
plot(tspeed, r); hold off;
legend('Measurements', 'Pre-filter');
ylabel('Position (deg)');
xlabel('Time (s)');

%%
[r, t] = stepFilter(0, 360, 0.005, 2400, 18000);
figure();
plot(t(101:201)-0.5, r(101:201));
xlabel('Time (s)');
ylabel('Position (deg)');

[r, t] = triangular(0, 1440, 0.005, 2400, 18000);
figure();
plot(t, r);
xlabel('Time (s)');
ylabel('Position (deg)');

%% Pre-filter test
[r, t] = stepFilter(0, 360, 0.005, 2400, 18000);
figure();
plot(t, r);

figure();
[y, tOut] = lsim(C_ff, r, t);
plot(tOut, y);
title('Input required for feedforward');

figure();
lsim(C_ff * G, r, t);
%plot(tOut, y);
title('Output with feedforward');

figure();
[y, tOut] = lsim(C_fb / (1 + C_fb * G), r, t);
plot(tOut, y);
title('Input required for feedback');

figure();
lsim(C_fb * G / (1 + C_fb * G), r, t);
%plot(tOut, y);
title('Output with feedback');

%% Pre-filter digital
close all;
ts = 0.01; %100 Hz
C_ffd = c2d(C_ff, 0.002, 'tustin');
C_fbd = c2d(C_fb, ts, 'tustin');
Gd = c2d(Gres, ts);
Gdf = c2d(Gres, 0.002);

[r, t] = stepFilter(0, 360, ts, 2200, 9000);
[r2, t2] = stepFilter(0, 360, 0.002, 2200, 9000);
figure();
plot(t, r);

figure();
[y, tOut] = lsim(C_ffd, r2, t2);
plot(tOut, y);
title('Input required for feedforward');

figure();
lsim(C_ffd * Gdf, r2, t2);
%plot(tOut, y);
title('Output with feedforward');

figure();
[y, tOut] = lsim(C_fbd / (1 + C_fbd * Gd), r, t);
plot(tOut, y);
title('Input required for feedback');

figure();
lsim(C_fbd * Gd / (1 + C_fbd * Gd), r, t);
%plot(tOut, y);
title('Output with feedback');

figure();
step(C_fbd / (1 + C_fbd * Gd), opt)

%% Results
Tres = readtable('data.xlsx', 'Sheet', 'Result');

%% Extract results
t_FB = rmmissing(table2array(Tres(:, 1)));
t_FF = rmmissing(table2array(Tres(:, 6)));

r_step_FB = rmmissing(table2array(Tres(:, 2)));
y_step_FB = rmmissing(table2array(Tres(:, 3)));

r_trian_FB = rmmissing(table2array(Tres(:, 4)));
y_trian_FB = rmmissing(table2array(Tres(:, 5)));


r_step_FF = rmmissing(table2array(Tres(:, 7)));
y_step_FF = rmmissing(table2array(Tres(:, 8)));

r_trian_FF = rmmissing(table2array(Tres(:, 9)));
y_trian_FF = rmmissing(table2array(Tres(:, 10)));

n_FB = 6001;
n_FF = 15001;
%% Plot full data set
close all;
figure();
plot(t_FB(1:n_FB), r_step_FB(1:n_FB)); hold on;
plot(t_FB(1:n_FB), y_step_FB(1:n_FB)); legend('Reference', 'Output'); hold off;
xlim([0, max(t_FB(1:n_FB))]);
title('Feedback step input');

figure();
plot(t_FB(1:n_FB), r_trian_FB(1:n_FB)); hold on;
plot(t_FB(1:n_FB), y_trian_FB(1:n_FB)); legend('Reference', 'Output'); hold off;
xlim([0, max(t_FB(1:n_FB))]);
title('Feedback triangular input');

figure();
plot(t_FF(1:n_FF), r_step_FF(1:n_FF)); hold on;
plot(t_FF(1:n_FF), y_step_FF(1:n_FF)); legend('Reference', 'Output'); hold off;
xlim([0, max(t_FF(1:n_FF))]);
title('Feedforward step input');

figure();
plot(t_FF(1:n_FF), r_trian_FF(1:n_FF)); hold on;
plot(t_FF(1:n_FF), y_trian_FF(1:n_FF)); legend('Reference', 'Output'); hold off;
xlim([0, max(t_FF(1:n_FF))]);
title('Feedforward triangular input');

%% Medium two cycles sets
T = 6; %s
length_FB = 6 / 0.005 + 1;
length_FF = 6 / 0.002 + 1;

close all;
figure();
plot(t_FB(1:length_FB), r_step_FB(1:length_FB)); hold on;
plot(t_FB(1:length_FB), y_step_FB(1:length_FB)); legend('Reference', 'Output'); hold off;
title('Feedback step input');

figure();
plot(t_FB(1:length_FB), r_trian_FB(1:length_FB)); hold on;
plot(t_FB(1:length_FB), y_trian_FB(1:length_FB)); legend('Reference', 'Output'); hold off;
title('Feedback triangular input');

figure();
plot(t_FF(1:length_FF), r_step_FF(1:length_FF)); hold on;
plot(t_FF(1:length_FF), y_step_FF(1:length_FF)); legend('Reference', 'Output'); hold off;
title('Feedforward step input');

figure();
plot(t_FF(1:length_FF), r_trian_FF(1:length_FF)); hold on;
plot(t_FF(1:length_FF), y_trian_FF(1:length_FF)); legend('Reference', 'Output'); hold off;
title('Feedforward triangular input');

%%

function [r, t] = stepFilter(start, target, dt, vmax, amax)

    
    t0 = vmax / amax;
    t1 = sqrt((target - start) / amax);
    s_max_a = amax * t1^2 + start;
    
    if(t1 > t0)
        t2 = (target - start + amax * t0^2) / (2 * amax * t0);
        t3 = t0 + 2 * (t2 - t0);
        t = 0:dt:2*t2;
    else
        t2 = 0;
        t3 = t1;
        t = 0:dt:2*t1;
    end
    
    state = 0;
    r = zeros(1, length(t));
    
    for ti = 1:length(t)
       
        switch state
            case 0
                r(ti) = 0.5 * amax * t(ti)^2 + start;
                
                if(t(ti) + dt >= t1)
                    state = 2;
                elseif(t(ti) + dt >= t0)
                    state = 1;
                end
%                     if(t2 == 0)
%                         state = 2;
%                     else
%                         state = 1;
%                     end
%                 end
            
            case 1
                r(ti) = 0.5 * amax * t0^2 + start + amax * t0 * (t(ti) - t0);
                
                if(t(ti) + dt >= t3)
                    state = 2;
                end
                
            case 2
                if(t2 == 0)
                    r(ti) = 0.5 * amax * t1^2 + amax * t1 * (t(ti) - t3) - 0.5 *amax *(t(ti) - t3)^2;
                else
                    r(ti) = 0.5 * amax * t0^2 + amax * t0 * (t3 - t0) + amax * t0 * (t(ti) - t3) - 0.5 *amax *(t(ti) - t3)^2;
                end
        end
    end
    
    spacing = 0.6; %s
    valones = ones(1, round(spacing/dt) +1);
    t = [-spacing-dt:dt:-dt, t, (t(end) + dt): dt:(t(end)+2*dt+2*spacing)];
    r = [start * valones, r, target*valones, target*valones];
    t = t+(spacing+dt);
    
    
end

function [r, t] = triangular(start, target, dt, vmax, amax)

    
    t0 = vmax / amax;
    t1 = sqrt((target - start) / amax);
    s_max_a = amax * t1^2 + start;
    t4 = 0;
    if(t1 > t0)
        t2 = (target - start + amax * t0^2) / (2 * amax * t0);
        t3 = t0 + 2 * (t2 - t0);
        t4 = 2*t2;
        t = 0:dt:2*t4;
        
    else
        t2 = 0;
        t3 = t1;
        t4 = 2*t1;
        t = 0:dt:t4;
        
    end
    
    state = 0;
    r = zeros(1, length(t));
    
    for ti = 1:length(t)
       
        switch state
            case 0
                r(ti) = 0.5 * amax * t(ti)^2 + start;
                
                if(t(ti) + dt >= t1)
                    state = 2;
                elseif(t(ti) + dt >= t0)
                    state = 1;
                end
%                     if(t2 == 0)
%                         state = 2;
%                     else
%                         state = 1;
%                     end
%                 end
            
            case 1
                r(ti) = 0.5 * amax * t0^2 + start + amax * t0 * (t(ti) - t0);
                
                if(t(ti) + dt >= t3)
                    state = 2;
                end
                
            case 2
                if(t2 == 0)
                    r(ti) = 0.5 * amax * t1^2 + amax * t1 * (t(ti) - t3) - 0.5 *amax *(t(ti) - t3)^2;
                else
                    r(ti) = 0.5 * amax * t0^2 + amax * t0 * (t3 - t0) + amax * t0 * (t(ti) - t3) - 0.5 *amax *(t(ti) - t3)^2;
                end
                
                if(t(ti) >= t4)
                    state = 3;
                end
             
            case 3
                r(ti) = target - 1/2 * amax * (t(ti)-t4)^2;
                
                if(t(ti) + dt >= t1 + t4)
                    state = 5;
                elseif(t(ti) + dt >= t0 + t4)
                    state = 4;
                end
            
            case 4
                r(ti) = target - 0.5 * amax * t0^2 - amax * t0 * (t(ti) - t0 - t4);
                
                if(t(ti) + dt >= t3+t4)
                    state = 5;
                end
            
            case 5
                if(t2 == 0)
                    r(ti) = target - 0.5 * amax * t1^2 - amax * t1 * (t(ti) - t3 - t4) + 0.5 *amax *(t(ti) - t3 - t4)^2;
                else
                    r(ti) = target - 0.5 * amax * t0^2 - amax * t0 * (t3 - t0) - amax * t0 * (t(ti) - t3 - t4) + 0.5 *amax *(t(ti) - t3 - t4)^2;
                end
        end
    end
    
    r = [r,r,r];
    t = [t, t+max(t)+dt, t+2*max(t)+2*dt];
       
    
end

function [r, t] = accel(tEnd, dt, vmax, amax)

    t = 0:dt:tEnd;
    t0 = vmax / amax;
   
    state = 0;
    r = zeros(1, length(t));
    
    for ti = 1:length(t)
       
        switch state
            case 0
                r(ti) = 0.5 * amax * t(ti)^2;
                
                if(t(ti) + dt >= t0)
                    state = 1;
                end

            
            case 1
                r(ti) = 0.5 * amax * t0^2 + amax * t0 * (t(ti) - t0);
                
     
        end
    end
       
end