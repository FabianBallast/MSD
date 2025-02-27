%% Read data from file. 
clear all;
T = readtable('data.xlsx');

%% Extract results
t_FB = rmmissing(table2array(T(:, 38)));
t_FF = rmmissing(table2array(T(:, 43)));

r_step_FB = rmmissing(table2array(T(:, 39)));
y_step_FB = rmmissing(table2array(T(:, 40)));

r_trian_FB = rmmissing(table2array(T(:, 41)));
y_trian_FB = rmmissing(table2array(T(:, 42)));


r_step_FF = rmmissing(table2array(T(:, 44)));
y_step_FF = rmmissing(table2array(T(:, 45)));

r_trian_FF = rmmissing(table2array(T(:, 46)));
y_trian_FF = rmmissing(table2array(T(:, 47)));

%% Plot full data set
close all;
figure();
plot(t_FB(1:length(r_step_FB)), r_step_FB); hold on;
plot(t_FB(1:length(r_step_FB)), y_step_FB); legend('Reference', 'Output'); hold off;
title('Feedback step input');

figure();
plot(t_FB(1:length(r_trian_FB)), r_trian_FB); hold on;
plot(t_FB(1:length(r_trian_FB)), y_trian_FB); legend('Reference', 'Output'); hold off;
title('Feedback triangular input');

figure();
plot(t_FF(1:length(r_step_FF)), r_step_FF); hold on;
plot(t_FF(1:length(r_step_FF)), y_step_FF); legend('Reference', 'Output'); hold off;
title('Feedforward step input');

figure();
plot(t_FF(1:length(r_trian_FF)), r_trian_FF); hold on;
plot(t_FF(1:length(r_trian_FF)), y_trian_FF); legend('Reference', 'Output'); hold off;
title('Feedforward triangular input');

%% Short two cycles sets
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



