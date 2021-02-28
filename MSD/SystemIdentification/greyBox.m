%% Read data from file. 
clear all;
close all;
T = readtable('data.xlsx');
%%
syms a b c real;

s = tf('s');
g = 1/s * 2 / (s^2 + 3*s + 4);
[A,B,C,D] = tf2ss([2], [1, 3, 4, 0])
%%
dt = 0.002;
x_full = rmmissing(table2array(T(:, 34)));
y_full = rmmissing(table2array(T(:, 35)));

T_end = (length(x_full)-1)*dt;
t1 = 0:dt:T_end;


figure();
plot(t1, x_full);

figure();
plot(t1, y_full);

x_f2 = rmmissing(table2array(T(:, 31)));
y_f2 = rmmissing(table2array(T(:, 32)));

dt2 = 0.00125;
T_end2 = (length(x_f2)-1)*dt2;
t2 = 0:dt2:T_end2;


figure();
plot(t2, x_f2);

figure();
plot(t2, y_f2);

stepdata = rmmissing(table2array(T(:, 37)));
tstep = 0:0.005:((length(stepdata)-1)*0.005);

%% Black box
figure();
N = length(x_full);
nfs = [];
wind = [];

% [T, f1] = tfestimate(x_f2, y_f2, wind, [], nfs, 800);
% [C, f] = mscohere(x_f2, y_f2, [], [], [], 800);
% subplot(3,1,1); semilogx(f, 20*log10(abs(T)));
% subplot(3,1,2); semilogx(f, rad2deg(angle(T)));
% subplot(3,1,3); semilogx(f, C);

sys2=tfest(data,3,0);
bode(sys2);
%%

% x_full = table2array(T(1:40000, 31));
% y_full = table2array(T(1:40000, 32));
load(fullfile(matlabroot, 'toolbox', 'ident', 'iddemos', 'data', 'dcmotordata'));
% data = iddata(y_full, x_full, 0.002, 'Name', 'DC-motor');
% data = iddata(y_f2, x_f2, dt2, 'Name', 'DC-motor');
data = iddata(Y_ID, V_ID, dt2, 'Name', 'DC-motor');
% data = iddata(y(:, 1), u, 0.1, 'Name', 'DC-motor');
data.InputName = 'Voltage';
data.InputUnit = 'V';
data.OutputName = 'Angular position';
data.OutputUnit = 'deg';
data.Tstart = 0;
data.TimeUnit = 's';

% a = 80000; 
% b = 30; 
% c = 200;
% 
% t = 1;
% G = 0.25;

k = 80000;
zeta =1;
omega = 2.3 * 2 * pi; 

% 1/s * k / (s^2 + 2 * zeta * omega + omega^2)

parameters = 0;
init_sys = idgrey('motorDyn',{'k',k; 'zeta', zeta; 'omega', omega},'c');
init_sys.Structure.Parameters(1).Maximum = 200000;
init_sys.Structure.Parameters(2).Maximum = 2;
init_sys.Structure.Parameters(3).Maximum = 100;

init_sys.Structure.Parameters(1).Minimum = 0;
init_sys.Structure.Parameters(2).Minimum = 0;
init_sys.Structure.Parameters(3).Minimum = 0.01;
% init_sys.Structure.Parameters(1).Free = false;
sys = greyest(data,init_sys);
figure();
opt = compareOptions('InitialCondition','zero');
compare(data,sys,Inf,opt)
%%
s = tf('s');
res = getpvec(sys);
Gres = 1/s * res(1) / (s^2 + 2*res(2)*res(3) * s + res(3)^2);

figure();
bode(Gres);

%%
s = tf('s');
zeta = 0.8;
omega = 2.3 * 2 * pi; 
k = 80000;
Gs = 1/s * k / (s^2 + 2 * zeta * omega * s + omega^2);
figure();
bode(Gs);
[yr, tr] = lsim(Gs, x_f2, t2);
figure();
plot(tr, yr); hold on; plot(tr, y_f2); hold off;
legend('model', 'data');
%% First model
opt = stepDataOptions('StepAmplitude',360);
Gsd = c2d(Gs, 0.005);
Gresd = c2d(Gres, 0.005);

T1 = 0.01 * Gres / (1+ 0.01*Gres);
T2 =  0.01* Gsd / (1+ 0.01*Gsd);
K2 = 0.01 / (1+ 0.01*Gsd);
figure();
plot(tstep, stepdata); hold on; step(T2, opt); step(T1, opt); hold off; 

figure();
step(K2, opt);
