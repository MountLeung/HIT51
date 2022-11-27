close all;clear all;clc;
%% 参数设置 
startpos1 = 100; endpos1 = 290; 
starttime  = 1;                

%% 数据导入 & 预处理（去除底噪+移除静止时间+人数判断、矩阵切割）
intensity1 = importdata('4-1.mat'); 
noise_deducted1 = datapre(intensity1,startpos1,endpos1,starttime,length(intensity1));
%Silence Removal
[row,column] = size(noise_deducted1);
pure_noise_matrix = zeros(row,3000);%3000点噪声
new_intensity1 = [pure_noise_matrix noise_deducted1(:,1:round(column/2)) pure_noise_matrix noise_deducted1(:,1+round(column/2):column) pure_noise_matrix];
% figure(1)
% mesh(new_intensity1);
max_old = max(noise_deducted1);
max_new = max(new_intensity1);
silence_removed1 = silence_removal(new_intensity1); 
max_processed = max(silence_removed1);
figure(2)
subplot(311);plot(max_old);title("原始步行振动信号")
subplot(312);plot(max_new);title("加入纯噪声")
subplot(313);plot(max_processed);title("消除纯噪声")



