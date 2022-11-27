close all;clear all;clc;
%% 参数设置 
startpos1 =100;endpos1 = 290; 
startpos23 = 185;endpos23 = 232;  
starttime  = 1;Observe_Window_LEN = 600;                %get start_time!

%% 数据导入 & 预处理（去除底噪+人数判断、矩阵切割+移除静止时间）
intensity1 = importdata('1107_11_1w5.mat');   
intensity2 = importdata('B1.mat');
intensity3 = importdata('B3.mat');
noise_reducted1 = datapre(intensity1,startpos1,endpos1,starttime,length(intensity1));
noise_reducted2 = datapre(intensity2,startpos23,endpos23,starttime,length(intensity2));
noise_reducted3 = datapre(intensity3,startpos23,endpos23,starttime,length(intensity3));

figure(1)
mesh(noise_reducted1);
% subplot(211);mesh(noise_reducted1(:,4201:4800));
% subplot(212);mesh(noise_reducted1(:,4201-2000:4800));
y = max(noise_reducted1(:,9001:9600),[],2);
% y = max(noise_reducted1(:,1:600),[],2);
% y = max(noise_reducted1(:,1801:2401),[],2);
figure(22)
plot(y)

[num_person,edge_index_LS,edge_index_RS,c] = p_count(y);