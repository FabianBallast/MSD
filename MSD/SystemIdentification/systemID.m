T = readtable('data.xlsx');

%%
% Reading is slow. New part. 
x_7V = table2array(T(:, 9));
y_7V = table2array(T(:, 10));

x_7V = x_7V(2:length(x_7V)-1, :);
y_7V = y_7V(2:length(y_7V)-1, :);

x_7V = str2double(x_7V);
y_7V = str2double(y_7V);


freq= logspace(-2, 1, 27);
endSin = [];
stepsPrev = 0;

down = 0;
prev  = 0;
iIm = [];
in = 1;
iPrev = 0;
for i = 2:length(y_7V)
    if(down == 1 && y_7V(i) - prev > 0 && y_7V(i)<5000 && i - iPrev > 15)
        iIm(in) = i;
        in = in + 1;
        down = 0;
        iPrev= i;
    end
    
    if(y_7V(i) - prev < 0)
        down = 1;
    elseif (y_7V(i) - prev > 0)
        down = 0;
    end
    
    prev = y_7V(i);
end

amps= 0;
G = [];
f = [];
P = [];

for i = 2:length(iIm)
    chunck = y_7V(iIm(i-1):iIm(i));
    chunck_in = x_7V(iIm(i-1):iIm(i));
    amps(i) = (max(chunck) - min(chunck)) / 2;
    amps_in = (max(chunck_in) - min(chunck_in)) / 2;
    G(i-1) = 20*log10(amps(i) / amps_in);
    [h, maxI] = max(chunck);
    [h, maxIn] = max(chunck_in);
    P_temp = (maxIn - maxI) / (iIm(i) - iIm(i-1)) * 360;
    if P_temp < 0
        P(i-1) =  P_temp;
    else
        P(i-1) = P_temp - 360; 
    end% + 90;
    f(i-1) = 1/((iIm(i) - iIm(i-1)) / 100);
end

figure();
tiledlayout(2,1); 
nexttile;
semilogx(f, G); grid on;
ylabel("Gain (dB)");
xlabel("Frequency (Hz)");nexttile;
semilogx(f,  P); 
ylim([-270, 0]);
ylabel("Phase (deg)");
xlabel("Frequency (Hz)");
grid on;
% for i = 1:length(freq)
%     Tr = 1 / freq(i);
%     steps = Tr*100 + stepsPrev;
%     stepsPrev = steps;
%     endSin(i) = steps;
% end

figure();
plot(x_7V);
% hold on;
% plot(iIm, zeros(1, length(iIm)), 'o');hold off;
%%
fs = 100;

nfs = 1*length(x_7V);
wind = kaiser(nfs,15);

f = logspace(-2, 1, 28);

tfestimate(x_7V,y_7V,[],[],f,fs)
[T,f] = tfestimate(x_7V,y_7V,[],[],nfs,fs);
figure(1);
subplot(2,1,1);semilogx(f,20*log10(abs(T)));
subplot(2,1,2);semilogx(f,rad2deg(angle(T)));
%%
data = iddata(y_7V, x_7V, 1/fs);
sys = ssregest(data, 3);
%%
% sysc = d2c(sys);
% bode(sysc);