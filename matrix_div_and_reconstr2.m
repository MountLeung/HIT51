function [cell_of_matrix_sig,cell_of_matrix_pos] = matrix_div_and_reconstr2(raw_matrix,num_person)
%MATRIX_DIV_AND_RECONSTR �и�POS��TIME���󵽸���
%BACKGROUND �ཻ����ֻ�����ڲ��Լ�������ֻ��Ҫһ���źţ�ȡ�ཻǰ���������ʱ�������ģ���������Ҫƴ��
%VERSION3 :
%�״�  ��4*num_person���ŵ�  ����
%�˱ܺ��β��   ��������+�����ɶ��߽���������+����������Ӧ��Ԫ���滻�״�Ԫ��
%���赥������ֻ��һ�������ṹ������������������
%ÿ��Ԫ�����鶼�Ǿ�������Ϊ����������ΪPOS��(ͬnoise_reducted)

Observe_Win_LEN = 600;
[POS,n] = size(raw_matrix);
directions = zeros(1,num_person); %1:�������������:LS ascending  -1:�������������:LS descending
LS_B_index = zeros(1,num_person);
RS_B_index = zeros(1,num_person);
LS_R_index = zeros(1,num_person);
RS_R_index = zeros(1,num_person);

if num_person > 1               %��Ҫ�����и��ع������Լ��ĸ������
    cross_flag = 0;             
    cross_time = 0;
    cell_of_matrix_sig = cell(1,num_person);
    cell_of_matrix_pos = cell(1,num_person);
    %% �����ཻʱ�䡢�ٴη���ʱ��    VERSION2��include case of No crossing ��
    i = 1;
    while(i<=n && cross_flag == 0 )
        temp_num = p_count(max(raw_matrix(:,i:i+Observe_Win_LEN-1),[],2));
        if temp_num ~= num_person
            temp_num = p_count(max(raw_matrix(:,i+Observe_Win_LEN:i+2*Observe_Win_LEN-1),[],2));
            if temp_num ~= num_person
                cross_flag = 1;
                cross_time = i;
            end
        end
        i = i+Observe_Win_LEN;   
    end
    
    if cross_time ~= 0                      %���ཻ
        i = cross_time;
        while(i<=n-2*Observe_Win_LEN+1 && cross_flag == 1 )
            temp_num = p_count(max(raw_matrix(:,i:i+Observe_Win_LEN-1),[],2));
            if temp_num == num_person
                temp_num = p_count(max(raw_matrix(:,i+Observe_Win_LEN:i+2*Observe_Win_LEN-1),[],2));
                if temp_num == num_person         %�������ȣ�������������ļ��ཻ���
                    cross_flag = 0;
                    re_seperate_time = i;
                end
            end
            i = i+Observe_Win_LEN;
        end
        if cross_flag ~= 0                  %ֱ�����û����
            re_seperate_time = n;
        end
            
        %% �ж������ʱ�� && �����ź�
        if cross_time-Observe_Win_LEN > n-re_seperate_time     %ȡ�ཻǰ���źţ������������
            start_time = 1;
            end_time = cross_time-2*Observe_Win_LEN-1;
            n_time = end_time;
            %��ʼ������Ĵ洢�ṹ
            for k = 1:num_person
                cell_of_matrix_sig{k} = zeros(POS,n_time);
            end
            %�״���β������
            Win1_Bottom = get_pos_window_bottom(num_person,max(raw_matrix(:,1:Observe_Win_LEN),[],2));
            WinLAST_Bottom = get_pos_window_bottom(num_person,max(raw_matrix(:,end_time-Observe_Win_LEN+1:end_time),[],2));
            directions = zeros(1,num_person);
            for k = 1:num_person
                if Win1_Bottom{k}(1) < WinLAST_Bottom{k}(1)  %�������������
                    directions(k) = 1;
                    LS_B_index(k) = Win1_Bottom{k}(1);       %B:BEST
                    RS_B_index(k) = Win1_Bottom{k}(4);
                    LS_R_index(k) = WinLAST_Bottom{k}(2);    %R:Replaced
                    RS_R_index(k) = WinLAST_Bottom{k}(3);
                else
                    directions(k) = -1;
                    LS_B_index(k) = Win1_Bottom{k}(2);
                    RS_B_index(k) = Win1_Bottom{k}(3);
                    LS_R_index(k) = WinLAST_Bottom{k}(1);
                    RS_R_index(k) = WinLAST_Bottom{k}(4);
                end
            end          
        else                                %ȡ�ཻ���ٴηֿ�����źţ������������
            start_time = re_seperate_time;
            end_time = n; 
            n_time = n-re_seperate_time+1;
            %��ʼ������Ĵ洢�ṹ
            for k = 1:num_person
                cell_of_matrix_sig{k} = zeros(POS,n_time);
            end
            %�״���β������
            Win1_Bottom = get_pos_window_bottom(num_person,max(raw_matrix(:,re_seperate_time:re_seperate_time+Observe_Win_LEN-1),[],2));
            WinLAST_Bottom = get_pos_window_bottom(num_person,max(raw_matrix(:,end_time-Observe_Win_LEN+1:end_time),[],2));
            for k = 1:num_person
                if Win1_Bottom{k}(1) < WinLAST_Bottom{k}(1)  %�������������
                    directions(k) = 1;
                    LS_B_index(k) = Win1_Bottom{k}(1);       %B:BEST
                    RS_B_index(k) = Win1_Bottom{k}(4);
                    LS_R_index(k) = WinLAST_Bottom{k}(2);    %R:Replaced
                    RS_R_index(k) = WinLAST_Bottom{k}(3);
                else
                    directions(k) = -1;
                    LS_B_index(k) = Win1_Bottom{k}(2);
                    RS_B_index(k) = Win1_Bottom{k}(3);
                    LS_R_index(k) = WinLAST_Bottom{k}(1);
                    RS_R_index(k) = WinLAST_Bottom{k}(4);
                end
            end
        end
    else                    %ʼ�����ཻ
            start_time = 1;
            end_time = n;
            n_time = n;
            %��ʼ������Ĵ洢�ṹ
            for k = 1:num_person
                cell_of_matrix_sig{k} = zeros(POS,n_time);
            end
            %�״���β������
            Win1_Bottom = get_pos_window_bottom(num_person,max(raw_matrix(:,1:Observe_Win_LEN),[],2));
            WinLAST_Bottom = get_pos_window_bottom(num_person,max(raw_matrix(:,end_time-Observe_Win_LEN+1:end_time),[],2));
            directions = zeros(1,num_person);
            for k = 1:num_person
                if Win1_Bottom{k}(1) < WinLAST_Bottom{k}(1)  %�������������
                    directions(k) = 1;
                    LS_B_index(k) = Win1_Bottom{k}(1);       %B:BEST
                    RS_B_index(k) = Win1_Bottom{k}(4);
                    LS_R_index(k) = WinLAST_Bottom{k}(2);    %R:Replaced
                    RS_R_index(k) = WinLAST_Bottom{k}(3);
                else
                    directions(k) = -1;
                    LS_B_index(k) = Win1_Bottom{k}(2);
                    RS_B_index(k) = Win1_Bottom{k}(3);
                    LS_R_index(k) = WinLAST_Bottom{k}(1);
                    RS_R_index(k) = WinLAST_Bottom{k}(4);
                end
            end
    end
        %% ��������Ż���POS���½硢�ع��и����źž���
        for k = 1:num_person
            LS_low_bound  = compare0(1,LS_B_index(k),LS_R_index(k));
            LS_high_bound = compare0(2,LS_B_index(k),LS_R_index(k));
            RS_low_bound  = compare0(1,RS_B_index(k),RS_R_index(k));
            RS_high_bound = compare0(2,RS_B_index(k),RS_R_index(k));
            
            cell_of_matrix_sig{k}(LS_low_bound:LS_high_bound,:) = raw_matrix(LS_low_bound:LS_high_bound,start_time:end_time);
            cell_of_matrix_sig{k}(RS_low_bound:RS_high_bound,:) = raw_matrix(RS_low_bound:RS_high_bound,start_time:end_time);
            cell_of_matrix_pos{k}=[LS_low_bound,LS_high_bound,RS_low_bound,RS_high_bound];
        end

else                        %�����У��޸������
    cell_of_matrix_sig{1} = raw_matrix;
    cell_of_matrix_pos{1} = {};
    %%%�ռ併��


end