function output_matrix = silence_removal(raw_matrix)
%SILENCE_REMOVAL Remove Silence periods in raw Sig. Matrix
%basic logic:t-max_intensityΪ�գ���������POS��Χ�ڿ�
%��ԭSilence Removal�㷨�Ͻ�������Ӧ�Ľ������Ƶ�֡����Frame_LEN ��������ֵEnergy_THread
%NEW VERSION to be updated:����ԭ���Ӽ��
[row,~]=size(raw_matrix);
output_matrix = [];
output_matrix_temp = [];
max_vector = max(raw_matrix);
N = length(max_vector);
%% ���Ƶ�֡���ȡ�������ֵ
Frame_LEN = 0;
Win_LEN = 800;
Num_Win = floor(N/Win_LEN);
sig_center = zeros(1,Num_Win);
Win_mean = zeros(1,Num_Win);
for i = 1:Num_Win
    for j = 1+(i-1)*Win_LEN:i*Win_LEN-1
        sig_center(i) = j*max_vector(j)+sig_center(i); 
    end
    Win_mean(i) = mean(max_vector(1+(i-1)*Win_LEN:i*Win_LEN-1));
end
index = 0;
for i = 1:Num_Win-1
    if Win_mean(i) >=0.03 && Win_mean(i+1) >= 0.03       %����
        Frame_LEN = sig_center(i+1)-sig_center(i);
        index = i;
        break;
    end
end

if Frame_LEN == 0                                          %����ʧ��
    Frame_LEN = 800;
    Energy_THread = 0.008;                              %����
else
    sum = 0;
    for j = 1+(index-1)*Win_LEN:(index+1)*Win_LEN-1
        sum = sum+max_vector(j)^2;
    end
    Energy_THread = sum/2; 
end
%% ��֡ && ���֡����
N_frame = floor(N/Frame_LEN);
flag = zeros(1,N_frame);              %0:WALKING      1:SILENCE
Frame_E = zeros(1,N_frame);
for i = 1:N_frame
    for j = 1+(i-1)*Frame_LEN:i*Frame_LEN-1
        Frame_E(i) = max_vector(j)^2+Frame_E(i); 
    end
end

%% ��ֵ�˲�

%% �ж�ѡ��time_index
for i = 1:N_frame
    if Frame_E(i) > Energy_THread
        flag(i) = 0;
    else
        flag(i) = 1;
    end
end
%% ��ͣ��������
adjust_index = [];
insert_frame_index =[];
for i = 1:N_frame-2
    if flag(i)==0
        if flag(i+1)==1
            j=i+1;
            while(j<=N_frame-1 && flag(j)==1)
                j=j+1;
            end
            if j+1 < N_frame && flag(j+1)==0
                adjust_index = [adjust_index i j+1];
                insert_frame_index =[insert_frame_index i ];
            end
        end
    end
end
    
%% ��֡�ϳɣ��������
counter = 0;
for i = 1:N_frame
    if flag(i) == 0
        counter = counter+1;
        output_matrix_temp = [output_matrix_temp raw_matrix(:,1+(i-1)*Frame_LEN:i*Frame_LEN-1)];
        output_matrix = output_matrix_temp;%
    end
end

% if ~isempty(adjust_index)
%     %%%����
%     N_zeros = [];
%     count = length(adjust_index)/2;
%     for i = 1:count
%         [~,before_si_index] = max(max_vector(1+(adjust_index(i)-1)*Frame_LEN:adjust_index(i)*Frame_LEN-1));
% %         before_si_index = before_si_index + (adjust_index(i)-1)*Frame_LEN-1;
%         [~,after_si_index] = max(max_vector(1+(adjust_index(i+1)-1)*Frame_LEN:adjust_index(i+1)*Frame_LEN-1));
% %         after_si_index = after_si_index + (adjust_index(i+1)-1)*Frame_LEN-1-(adjust_index(i+1)-adjust_index(i))*Frame_LEN;
%         raw_delta = after_si_index-before_si_index;
%         N_zeros = [N_zeros round(0.75*(Frame_LEN - raw_delta))];
%     end
%     pointer = 1;
%     for i = 1:N_frame
%         if flag(i) == 0 && ismember(i,insert_frame_index) == 0
%             output_matrix = [output_matrix_temp raw_matrix(:,1+(i-1)*Frame_LEN:i*Frame_LEN-1)];
%         elseif flag(i) == 0 && ismember(i,insert_frame_index) == 1
%             output_matrix = [output_matrix_temp raw_matrix(:,1+(i-1)*Frame_LEN:i*Frame_LEN-1) zeros(row,N_zeros(pointer))];
%             pointer = pointer+1;
%         end
%     end
% else
%     output_matrix = output_matrix_temp;
% end
%% ����
end