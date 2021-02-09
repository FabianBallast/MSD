T = readtable('data.xlsx');

%%
% Reading is slow. New part. 
x_7V = table2array(T(:, 9));
y_7V = table2array(T(:, 10));

x_7V = x_7V(1:length(x_7V)-1, :);
y_7V = y_7V(1:length(y_7V)-1, :);

fs = 100;

nfs = 1*length(x_7V);
wind = kaiser(nfs,15);

tfestimate(x_7V,y_7V,[],[],nfs,fs)
%%
data = iddata(y_7V, x_7V, 1/fs);
sys = ssregest(data, 3);
%%
sysc = d2c(sys);
bode(sysc);