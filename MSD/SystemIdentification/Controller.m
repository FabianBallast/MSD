%% Guess for transfer function
s = tf('s');
zeta = 1;
omega = 2.3 * 2 * pi; 
k = 80000;
G = 1/s * k / (s^2 + 2 * zeta * omega * s + omega^2);

omega_control = 100;
C_ff = 1 / Gres * (1/(s/omega_control + 1)^4);


wc = 35;
gain_G = abs(evalfr(Gres, wc * 1j));
kp = 1/(5*gain_G);
wi = 1/10 * wc;
wd = 1/5 * wc;
wt = 5 * wc;
C_fb = kp*((1 + s/wd)/(1 + s/wt));%*(1 + wi/s)%*(wc/(s + wc));
C_fb2 = 1.5*(s+14.45)^2/(s+60)^2;

[mag,phase,wout] = bode(G,{10^-2 * 2 * pi, 10^2 * 2 * pi});
mag = 20 * log10(squeeze(mag));
[magc,phasec,woutc] = bode(C_ff,{10^-2 * 2 * pi, 10^2 * 2 * pi});
magc = 20 * log10(squeeze(magc));
[magc_fb,phasec_fb,woutc_fb] = bode(C_fb,{10^-2 * 2 * pi, 10^2 * 2 * pi});
magc_fb = 20 * log10(squeeze(magc_fb));

% figure();
% bode(G);

%% Plot results
close all;

figure();
title('Plant');
bode(Gres);

figure()
title('Feedforward');
bode(C_ff);

figure();
title('Total feedforward gain');
bode(C_ff * Gres);

figure();
title('Feedback');
bode(C_fb);

figure();
title('Open Loop Feedback');
bode(C_fb * Gres);
margin(C_fb * Gres);

%% Simulations with normal step
close all;

opt = stepDataOptions('StepAmplitude',360);
figure();
step(C_ff, opt);
title('Input required for feedforward');

figure();
step(C_ff * Gres, opt);
title('Output with feedforward');

figure();
step(C_fb / (1 + C_fb * Gres), opt);
title('Input required for feedback');

figure();
step(C_fb * Gres / (1 + C_fb * Gres), opt);
title('Output with feedback');


%% Pre-filter test
[r, t] = stepFilter(0, 360, 0.005, 2200, 9000);
figure();
plot(t, r);

figure();
[y, tOut] = lsim(C_ff, r, t);
plot(tOut, y);
title('Input required for feedforward');

figure();
lsim(C_ff * Gres, r, t);
%plot(tOut, y);
title('Output with feedforward');

figure();
[y, tOut] = lsim(C_fb / (1 + C_fb * Gres), r, t);
plot(tOut, y);
title('Input required for feedback');

figure();
lsim(C_fb * Gres / (1 + C_fb * Gres), r, t);
%plot(tOut, y);
title('Output with feedback');

%% Pre-filter digital
close all;
ts = 0.005; %100 Hz
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