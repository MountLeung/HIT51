function cell_of_matrix_sig = matrix_div_and_reconstr(raw_matrix,num_person)
%MATRIX_DIV_AND_RECONSTR 切割POS×TIME矩阵到各人
%BACKGROUND 相交问题只存在于测试集，所以只需要一段信号（取相交前、后二者中时间间隔长的），而不需要拼接
%假设单组数据只有一种人数结构（不适用于流分析）
%每个元胞数组都是矩阵，列数为点数，行数为POS数(同noise_reducted)
Observe_Win_LEN = 600;
MAX_TOLERANT_RANGE = 15;
[POS,n] = size(raw_matrix);
MID = round(POS/2);

if num_person > 1               %需要进行切割重构：测试集的复杂情况
    cross_flag = 0;             
    cross_time = 0;
    cell_of_matrix_sig = cell(1,num_person);
    cell_of_matrix_pos = cell(1,num_person);
    %% 搜索相交时间、再次分离时间
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
    %% 判断输出的时段 && 分离信号
    if cross_time-Observe_Win_LEN >= n-re_seperate_time     %取相交前的信号，分离后进行输出
        n_time = cross_time-Observe_Win_LEN;
        n_pos = round(n_time/Observe_Win_LEN);
        %初始化存储结构
        for k = 1:num_person
            cell_of_matrix_sig{k} = zeros(POS,n_time);
            cell_of_matrix_pos{k} = zeros(4,n_pos);
        end  
        i = 1;                                          %循环初始条件
        while(i<=n_time)
            [~,L_edge_pos,R_edge_pos] = p_count(max(raw_matrix(:,i:i+Observe_Win_LEN-1),[],2));
            N_LS_edge_pos = length(L_edge_pos);
            N_RS_edge_pos = length(R_edge_pos);
            %左多右少
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
            %右多左少    
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
            %循环迭代条件
            i = i + Observe_Win_LEN;
        end
    
    else                                %取相交并再次分开后的信号，分离后进行输出
        n_time = n-re_seperate_time;
        n_pos = round(n_time/Observe_Win_LEN);
        for k = 1:num_person
            cell_of_matrix_sig{k} = zeros(POS,n_time);
            cell_of_matrix_pos{k} = zeros(4,n_pos);
        end
        i = re_seperate_time;                    %循环初始条件
        while(i<=n_time)
            [~,L_edge_pos,R_edge_pos] = p_count(max(raw_matrix(:,i:i+Observe_Win_LEN-1),[],2));
            N_LS_edge_pos = length(L_edge_pos);
            N_RS_edge_pos = length(R_edge_pos);
            
            %左多右少
            if N_LS_edge_pos >= N_RS_edge_pos
                counter_LS = 1;                        %已经配对的元素数量
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
            %循环迭代条件
            i = i + Observe_Win_LEN;
        end
    end
    %% 按行人序号划分POS上下界、重构切割后的信号矩阵    
    for k = 1:num_person
        LS_low_bound = min(cell_of_matrix_pos{k}(1,:));
        LS_high_bound = max(cell_of_matrix_pos{k}(2,:));
        RS_low_bound = min(cell_of_matrix_pos{k}(3,:));
        RS_high_bound = max(cell_of_matrix_pos{k}(4,:));
        
        cell_of_matrix_sig{k}(LS_low_bound:LS_high_bound,:) = raw_matrix(LS_low_bound:LS_high_bound,1:n_time);
        cell_of_matrix_sig{k}(RS_low_bound:RS_high_bound,:) = raw_matrix(RS_low_bound:RS_high_bound,1:n_time);            
    end
else                        %单人行：无干扰情况
    cell_of_matrix_sig{1} = raw_matrix;
end


