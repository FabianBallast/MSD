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
x_full = table2array(T(1:40000, 31));
y_full = table2array(T(1:40000, 32));
load(fullfile(matlabroot, 'toolbox', 'ident', 'iddemos', 'data', 'dcmotordata'));
data = iddata(y_full, x_full, 0.00125, 'Name', 'DC-motor');
% data = iddata(y(:, 1), u, 0.1, 'Name', 'DC-motor');
data.InputName = 'Voltage';
data.InputUnit = 'V';
data.OutputName = 'Angular position';
data.OutputUnit = 'deg';
data.Tstart = 0;
data.TimeUnit = 's';

a = 80000; 
b = 30; 
c = 200;

t = 1;
G = 0.25;
parameters = 0;
init_sys = idgrey('motorDyn',{'a',a; 'b', b; 'cr', c},'c');
init_sys.Structure.Parameters(1).Maximum = 150000;
% init_sys.Structure.Parameters(1).Free = false;
sys = greyest(data,init_sys);
figure();
opt = compareOptions('InitialCondition','zero');
compare(data,sys,Inf,opt)
%%
res = getpvec(sys);
Gres = 1/s * res(1) / (s^2 + res(2) * s + res(3));

bode(Gres);

%%
s = tf('s');
zeta = 1;
omega = 2.3 * 2 * pi; 
k = 80000;
Gs = 1/s * k / (s^2 + 2 * zeta * omega * s + omega^2);
t = 0:0.00125:100.104;
[yr, tr] = lsim(Gs, x_full, t(1:40000));
figure();
plot(tr, yr); hold on; plot(tr, y_full); hold off;
legend('model', 'data');
%% First model
opt = stepDataOptions('StepAmplitude',360);
Gsd = c2d(Gs, 0.005);
Gresd = c2d(Gres, 0.005);

T1 = 0.01 * Gres / (1+ 0.01*Gres);
T2 =  0.01* Gsd / (1+ 0.01*Gsd);

figure();
step(T2, opt); 
