function cell_of_matrix_sig = matrix_div_and_reconstr(raw_matrix,num_person)
%MATRIX_DIV_AND_RECONSTR �и�POS��TIME���󵽸���
%BACKGROUND �ཻ����ֻ�����ڲ��Լ�������ֻ��Ҫһ���źţ�ȡ�ཻǰ���������ʱ�������ģ���������Ҫƴ��
%���赥������ֻ��һ�������ṹ������������������
%ÿ��Ԫ�����鶼�Ǿ�������Ϊ����������ΪPOS��(ͬnoise_reducted)
Observe_Win_LEN = 600;
MAX_TOLERANT_RANGE = 15;
[POS,n] = size(raw_matrix);
MID = round(POS/2);

if num_person > 1               %��Ҫ�����и��ع������Լ��ĸ������
    cross_flag = 0;             
    cross_time = 0;
    cell_of_matrix_sig = cell(1,num_person);
    cell_of_matrix_pos = cell(1,num_person);
    %% �����ཻʱ�䡢�ٴη���ʱ��
    i = 1;
    while(i<=n && cross_flag == 0 )
        [temp_num,~,~] = p_count(max(raw_matrix(:,i:i+Observe_Win_LEN-1),[],2));
        if temp_num ~= num_person
            cross_flag = 1;
            cross_time = i;
        end
        i = i+Observe_Win_LEN;   
    end
    
    i = cross_time;
    while(i<=n && cross_flag == 1 )
        [temp_num,~,~] = p_count(max(raw_matrix(:,i:i+Observe_Win_LEN-1),[],2));
        if temp_num == num_person
            cross_flag = 0;
            re_seperate_time = i;
        end
        i = i+Observe_Win_LEN;   
    end
    %% �ж������ʱ�� && �����ź�
    if cross_time-Observe_Win_LEN >= n-re_seperate_time     %ȡ�ཻǰ���źţ������������
        n_time = cross_time-Observe_Win_LEN;
        n_pos = round(n_time/Observe_Win_LEN);
        %��ʼ���洢�ṹ
        for k = 1:num_person
            cell_of_matrix_sig{k} = zeros(POS,n_time);
            cell_of_matrix_pos{k} = zeros(4,n_pos);
        end  
        i = 1;                                          %ѭ����ʼ����
        while(i<=n_time)
            [~,L_edge_pos,R_edge_pos] = p_count(max(raw_matrix(:,i:i+Observe_Win_LEN-1),[],2));
            N_LS_edge_pos = length(L_edge_pos);
            N_RS_edge_pos = length(R_edge_pos);
            %�������
            if N_LS_edge_pos >= N_RS_edge_pos
                counter_LS = 1;                        
                counter_RS = 0;
                while(counter_LS <= N_LS_edge_pos)
                    cell_of_matrix_pos{round(counter_LS/2)}(1,round(i/Observe_Win_LEN)+1) = L_edge_pos(counter_LS);
                    temp_LS = L_edge_pos(counter_LS);
                    counter_LS = counter_LS + 1;
                    if counter_LS <= N_LS_edge_pos
                        cell_of_matrix_pos{round(counter_LS/2)}(2,round(i/Observe_Win_LEN)+1) = L_edge_pos(counter_LS);
                        counter_LS = counter_LS + 1;
                        if temp_LS + R_edge_pos(N_RS_edge_pos-counter_RS) - 2*MID <= MAX_TOLERANT_RANGE
                            cell_of_matrix_pos{round(counter_LS/2)}(4,round(i/Observe_Win_LEN)+1) = R_edge_pos(N_RS_edge_pos-counter_RS);
                            counter_RS = counter_RS + 1;
                            cell_of_matrix_pos{round(counter_LS/2)}(3,round(i/Observe_Win_LEN)+1) = R_edge_pos(N_RS_edge_pos-counter_RS);
                            counter_RS = counter_RS + 1;
                        else
                            cell_of_matrix_pos{round(counter_LS/2)}(4,round(i/Observe_Win_LEN)+1) = -1;
                            cell_of_matrix_pos{round(counter_LS/2)}(3,round(i/Observe_Win_LEN)+1) = -1;
                        end
                    else
                        cell_of_matrix_pos{round(counter_LS/2)}(4,round(i/Observe_Win_LEN)+1) =  R_edge_pos(N_RS_edge_pos-counter_RS);
                        break;
                    end                  
                end
            %�Ҷ�����    
            else
                counter_RS = 1;                        
                counter_LS = 0;
                while(counter_RS <= N_RS_edge_pos)
                    cell_of_matrix_pos{round(counter_RS/2)}(4,round(i/Observe_Win_LEN)+1) = R_edge_pos(N_RS_edge_pos-counter_RS+1);
                    counter_RS = counter_RS + 1;
                    if counter_RS <= N_RS_edge_pos
                        cell_of_matrix_pos{round(counter_RS/2)}(3,round(i/Observe_Win_LEN)+1) = R_edge_pos(N_RS_edge_pos-counter_RS+1);
                        counter_RS = counter_RS + 1;
                        if R_edge_pos(N_RS_edge_pos-counter_RS+2) + L_edge_pos(counter_LS+1) - 2*MID <= MAX_TOLERANT_RANGE
                            cell_of_matrix_pos{round(counter_RS/2)}(1,round(i/Observe_Win_LEN)+1) = L_edge_pos(counter_LS+1);
                            counter_LS = counter_LS + 1;
                            cell_of_matrix_pos{round(counter_RS/2)}(2,round(i/Observe_Win_LEN)+1) = L_edge_pos(counter_LS+1);
                            counter_LS = counter_LS + 1;
                        else
                            cell_of_matrix_pos{round(counter_RS/2)}(1,round(i/Observe_Win_LEN)+1) = -1;
                            cell_of_matrix_pos{round(counter_RS/2)}(2,round(i/Observe_Win_LEN)+1) = -1;
                        end
                    else
                        cell_of_matrix_pos{round(counter_LS/2)}(1,round(i/Observe_Win_LEN)+1) =  L_edge_pos(counter_LS+1);
                        break;
                    end                  
                end     
            end
            %ѭ����������
            i = i + Observe_Win_LEN;
        end
    
    else                                %ȡ�ཻ���ٴηֿ�����źţ������������
        n_time = n-re_seperate_time;
        n_pos = round(n_time/Observe_Win_LEN);
        for k = 1:num_person
            cell_of_matrix_sig{k} = zeros(POS,n_time);
            cell_of_matrix_pos{k} = zeros(4,n_pos);
        end
        i = re_seperate_time;                    %ѭ����ʼ����
        while(i<=n_time)
            [~,L_edge_pos,R_edge_pos] = p_count(max(raw_matrix(:,i:i+Observe_Win_LEN-1),[],2));
            N_LS_edge_pos = length(L_edge_pos);
            N_RS_edge_pos = length(R_edge_pos);
            
            %�������
            if N_LS_edge_pos >= N_RS_edge_pos
                counter_LS = 1;                        %�Ѿ���Ե�Ԫ������
                counter_RS = 0;
                while(counter_LS <= N_LS_edge_pos)
                    cell_of_matrix_pos{round(counter_LS/2)}(1,round(i/Observe_Win_LEN)+1) = L_edge_pos(counter_LS);
                    counter_LS = counter_LS + 1;
                    if counter_LS <= N_LS_edge_pos
                        cell_of_matrix_pos{round(counter_LS/2)}(2,round(i/Observe_Win_LEN)+1) = L_edge_pos(counter_LS);
                        counter_LS = counter_LS + 1;
                        if L_edge_pos(counter_LS - 2) + R_edge_pos(N_RS_edge_pos-counter_RS) - 2*MID <= MAX_TOLERANT_RANGE
                            cell_of_matrix_pos{round(counter_LS/2)}(4,round(i/Observe_Win_LEN)+1) = R_edge_pos(N_RS_edge_pos-counter_RS);
                            counter_RS = counter_RS + 1;
                            cell_of_matrix_pos{round(counter_LS/2)}(3,round(i/Observe_Win_LEN)+1) = R_edge_pos(N_RS_edge_pos-counter_RS);
                            counter_RS = counter_RS + 1;
                        else
                            cell_of_matrix_pos{round(counter_LS/2)}(4,round(i/Observe_Win_LEN)+1) = -1;
                            cell_of_matrix_pos{round(counter_LS/2)}(3,round(i/Observe_Win_LEN)+1) = -1;
                        end
                    else
                        cell_of_matrix_pos{round(counter_LS/2)}(4,round(i/Observe_Win_LEN)+1) =  R_edge_pos(N_RS_edge_pos-counter_RS);
                        break;
                    end                   
                end
                
            else
                counter_RS = 1;                        
                counter_LS = 0;
                while(counter_RS <= N_RS_edge_pos)
                    cell_of_matrix_pos{round(counter_RS/2)}(4,round(i/Observe_Win_LEN)+1) = R_edge_pos(N_RS_edge_pos-counter_RS+1);
                    counter_RS = counter_RS + 1;
                    if counter_RS <= N_RS_edge_pos
                        cell_of_matrix_pos{round(counter_RS/2)}(3,round(i/Observe_Win_LEN)+1) = R_edge_pos(N_RS_edge_pos-counter_RS+1);
                        counter_RS = counter_RS + 1;
                        if R_edge_pos(N_RS_edge_pos-counter_RS+2) + L_edge_pos(counter_LS+1) - 2*MID <= MAX_TOLERANT_RANGE
                            cell_of_matrix_pos{round(counter_RS/2)}(1,round(i/Observe_Win_LEN)+1) = L_edge_pos(counter_LS+1);
                            counter_LS = counter_LS + 1;
                            cell_of_matrix_pos{round(counter_RS/2)}(2,round(i/Observe_Win_LEN)+1) = L_edge_pos(counter_LS+1);
                            counter_LS = counter_LS + 1;
                        else
                            cell_of_matrix_pos{round(counter_RS/2)}(1,round(i/Observe_Win_LEN)+1) = -1;
                            cell_of_matrix_pos{round(counter_RS/2)}(2,round(i/Observe_Win_LEN)+1) = -1;
                        end
                    else
                        cell_of_matrix_pos{round(counter_LS/2)}(1,round(i/Observe_Win_LEN)+1) =  L_edge_pos(counter_LS+1);
                        break;
                    end                  
                end     
            end
            %ѭ����������
            i = i + Observe_Win_LEN;
        end
    end
    %% ��������Ż���POS���½硢�ع��и����źž���    
    for k = 1:num_person
        LS_low_bound = min(cell_of_matrix_pos{k}(1,:));
        LS_high_bound = max(cell_of_matrix_pos{k}(2,:));
        RS_low_bound = min(cell_of_matrix_pos{k}(3,:));
        RS_high_bound = max(cell_of_matrix_pos{k}(4,:));
        
        cell_of_matrix_sig{k}(LS_low_bound:LS_high_bound,:) = raw_matrix(LS_low_bound:LS_high_bound,1:n_time);
        cell_of_matrix_sig{k}(RS_low_bound:RS_high_bound,:) = raw_matrix(RS_low_bound:RS_high_bound,1:n_time);            
    end
else                        %�����У��޸������
    cell_of_matrix_sig{1} = raw_matrix;
end


