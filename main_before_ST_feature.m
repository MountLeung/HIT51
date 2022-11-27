%% 数据导入 & 预处理（去除底噪+人数判断、矩阵切割+移除静止时间）
close all;clear all;clc;

intensity1 = importdata('1107_10_1w5.mat');   

%% 参数设置 
% startpos1 = 110 ;endpos1 = 290;   %10可   9不准  11报错 12错解
startpos1 = 100 ;endpos1 = 290;     %9 前面不准  10准 11取到7500准了  12末尾不准
% startpos1 = 100 ;endpos1 = 300;   %10可  11报错    12错解

starttime  = 1;Observe_Window_LEN = 600;
noise_reducted1 = datapre(intensity1,startpos1,endpos1,starttime,length(intensity1));
num_walker1 = p_count(max(noise_reducted1(:,starttime:starttime+Observe_Window_LEN),[],2));
% [cell_of_matrix_sig1,cell_of_matrix_pos1] = matrix_div_and_reconstr2(noise_reducted1(:,1:7500),num_walker1); %for 11
[cell_of_matrix_sig1,cell_of_matrix_pos1] = matrix_div_and_reconstr2(noise_reducted1,num_walker1);

% figure(1); mesh(noise_reducted1);
% figure(2)
% % subplot(311);mesh(noise_reducted1(:,1:7800));title('Person A+B')  %10 12
% subplot(311);mesh(noise_reducted1(:,10200:15000));title('Person A+B')  %9
% subplot(311);mesh(noise_reducted1(:,1:4800));title('Person A+B')  %11
% subplot(311);mesh(noise_reducted1);title('Person A+B')
% subplot(312);mesh(cell_of_matrix_sig1{1});title('After Division: Person A')
% subplot(313);mesh(cell_of_matrix_sig1{2});title('After Division: Person B')

%% Silence Removal

%% Get Max Intensity Vector of Time Domain
max11=max(cell_of_matrix_sig1{1});
max12=max(cell_of_matrix_sig1{2});

% max1=max(noise_reducted1);
% max2=max(noise_reducted2);
% max3=max(noise_reducted3);
%% For Silence Removal
% pure_noise = max3(1680:1979);%300点噪声
% max11 = zeros(1,5500);
% max11(1:3000) = max1(1:3000); 
% for k = 1:5
%     max11(3001+(k-1)*300:3300+(k-1)*300) = pure_noise;
% end        
% max11(4501:5500)= max1(4001:5000);

% figure(10);mesh(intensity1);    % h1=title("疾走");h1.FontSize = 25;
% figure(14);mesh(intensity2);
% figure(15);mesh(intensity3);
% % 
% figure(8);
% subplot(3,1,1);plot(max1);
% subplot(3,1,2);plot(max2);
% subplot(3,1,3);plot(max3);

%% 步频特征挖掘                 
% [~,num_peak1,~,~,delta_peak_time1] =  Rx_ana(max11,410);  % NOTE:main_peak_index = length(max)
% [~,num_peak2,~,~,delta_peak_time2] =  Rx_ana(max12,410);
% [f1,peak1_pos,peak1_value,peak1_index,delta_step_time_var1] = get_peak_pos(max11,cell_of_matrix_sig1{1},num_peak1,delta_peak_time1,startpos1,500);  %f是再结合时间-最大强度图得到的步频，更精准
% [f2,peak2_pos,peak2_value,peak2_index,delta_step_time_var2] = get_peak_pos(max12,cell_of_matrix_sig1{2},num_peak2,delta_peak_time2,startpos1,500);

%% 步幅特征挖掘       
% [~,average_stride1,var_stride1] = get_stride(peak1_pos);
% [~,average_stride2,var_stride2] = get_stride(peak2_pos);

%% 能量特征挖掘       
% 统计time_range peak_pos_range内的时域能量
% [step_energy_array1,left_side_E1,right_side_E1] = get_step_energy2(cell_of_matrix_sig1{1},startpos1,peak1_pos,peak1_index);
% [step_energy_array2,left_side_E2,right_side_E2] = get_step_energy2(cell_of_matrix_sig1{2},startpos1,peak2_pos,peak2_index);
% 
% mean_E1 = mean(step_energy_array1);
% mean_E2 = mean(step_energy_array2);

%% 定位:只分辨在左/右光纤上某位置点
% pos1 = get_each_step_pos(left_side_E1,right_side_E1,peak1_pos);
% pos2 = get_each_step_pos(left_side_E2,right_side_E2,peak2_pos);

%% 偏离盲道判断
% warning1 = deviation_judge(1,left_side_E1,right_side_E1);
% warning2 = deviation_judge(1,left_side_E2,right_side_E2);
