close all;clear all;clc;
%% ���ݵ���
cd 'D:\����\MATLAB��������\mat����\mat����\1108\'
intensity1 = importdata('1108_07_2.mat');   
% figure(99);mesh(intensity1);
cd 'D:\����\MATLAB��������\������ȡ+��λƫ��\����\'
%% �������� 
startpos1 = 157;endpos1 = 236; 
starttime = 1;endtime = length(intensity1);
%% ����Ԥ����
noise_deducted1 = datapre(intensity1,startpos1,endpos1,starttime,endtime);

maxsig =max(noise_deducted1);
%% ������ȡ
features =  featureall(intensity1,startpos1,maxsig,noise_deducted1,410);
features = table(features');
%% ������
writetable(features,'1108_07_2.csv');
