function features =  featureall(intensity,startpos,maxsig,noise_reducted,GAP)
features = [];%特征值数组

%% 分组提取 时间-最大强度图 的参数  (含噪声多,后期更换）非平稳信号可用？
%分组? 求统计量：方差均值比、峰值系数   
n = 2500;
mydata1 = yuanbaoshuzu(maxsig,n);
feature1 = extractf(mydata1,maxsig,n);
features = [features feature1];
%% 步频
[~,num_peak,~,~,delta_peak_time] =  Rx_ana(maxsig,GAP);
[f,peak_pos,~,peak_index,delta_time_var] = get_peak_pos(maxsig,noise_reducted,num_peak,delta_peak_time,startpos,410);  %f是再结合时间-最大强度图得到的步频，更精准
features = [features,f,delta_time_var];
%% 步幅
[~,average_stride,var_stride] = get_stride(peak_pos);
features = [features,average_stride,var_stride];
%% 能量
[step_energy_array,~,~] = get_step_energy(noise_reducted,startpos,peak_pos,peak_index);
features = [features,mean(step_energy_array)];
%% 单步特征
[raw_sig_group,~,after_hampel] = get_each_step_sig(peak_pos,peak_index,intensity);
used_fig_num = 0;
after_pca = step_group_observe(raw_sig_group,used_fig_num,after_hampel); 
feature_single_step_time_domain = extract_f_of_single_step(after_pca);
features = [features feature_single_step_time_domain];
%% STFT
[Spec,~] = DSTFT(after_pca,866*2,45,866);
stft_feature_pca = stft_ana(Spec,after_pca);
features = [features stft_feature_pca];
%% HHT
[~,hhtfeature] = hhtfretrans(hht(after_pca),0);
features = [features hhtfeature];
%% 二维获取
step_sig_group2 = get_each_step_sig2(peak_pos,peak_index,intensity);
%% 时域特征分解
[pattern2,~] = eigendivide(step_sig_group2);
timef = gatpatternf(pattern2);
features = [features timef];
%% 小波变换
[cA,~] = dwt_3_wave(step_sig_group2,'db4',used_fig_num); %一次调用 出三张图
wtf = get_feature(cA);
features = [features wtf];


