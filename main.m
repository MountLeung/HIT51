close all;clear all;clc;
%% 数据导入
cd 'D:\毕设\MATLAB程序整理\mat生成\mat数据\1108\'
intensity1 = importdata('1108_07_2.mat');   
% figure(99);mesh(intensity1);
cd 'D:\毕设\MATLAB程序整理\特征提取+定位偏航\程序\'
%% 参数设置 
startpos1 = 157;endpos1 = 236; 
starttime = 1;endtime = length(intensity1);
%% 数据预处理
noise_deducted1 = datapre(intensity1,startpos1,endpos1,starttime,endtime);

maxsig =max(noise_deducted1);
%% 特征提取
features =  featureall(intensity1,startpos1,maxsig,noise_deducted1,410);
features = table(features');
%% 保存表格
writetable(features,'1108_07_2.csv');
