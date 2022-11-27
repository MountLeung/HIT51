function [num_person,edge_index_LS,edge_index_RS,count] = p_count(vec)
%P_COUNT 观察窗口内有效人数，判断行人是否相遇，并返回左右两边的峰脚点，对应关系未知
%输入vec:观察窗口内max_intensity_by_pos
N = length(vec);
MID = 100;    %N/2
count = 0;
i = 1;                  %从低位向高位
edge_index_LS = [];
edge_index_RS = [];

%% 统计与存储峰脚点        VERSION2 to be updated：乒乓搜索
while(i<N)
    temp_l = 0;
    temp_r = 0;
    if vec(i)>0.045      % 阈值修改于11.23
        flag = 1;%某POS在观察窗口内有人出现 
        %向左边搜索峰脚点
        t = i-1;
        if t == 0
            temp_l = 1;
        end
        while(t >0 && flag == 1)
            if vec(t) == 0 
                flag = 0;
                temp_l = t;
            elseif vec(t) ~= 0 && t == 1
                flag = 0;
                temp_l = 1;
                t = t - 1;
            else
                t = t - 1;
            end
        end
        %向右边搜索峰脚点
        flag = 1;
        j = i+1;                     
        while(j<=N && flag == 1)
            if vec(j) == 0 
                flag = 0;
                temp_r = j;
             elseif vec(j) ~= 0 && j == N
                flag = 0;
                temp_r = N;
                j = j + 1;
            else
                j = j + 1;
            end
        end
        
        if temp_r ~= 0 && temp_l ~=0
            if temp_r - temp_l > 6           %防止记录伪峰
                count = count + 1;
                if temp_l >= MID    %Right Side
                    edge_index_RS = [edge_index_RS temp_l];
                else
                    edge_index_LS = [edge_index_LS temp_l];
                end
                if temp_r >= MID    %Right Side
                    edge_index_RS = [edge_index_RS temp_r];
                else
                    edge_index_LS = [edge_index_LS temp_r];
                end
            end
            i = j + 1;
        else
            break;
        end
    else
        i = i+1;
    end   
end

%% 相同点检查与可能的剔除（仅在加入相同点后左右不等，方剔除）
N_ls = length(edge_index_LS);
N_rs = length(edge_index_RS);
%左边
repeat_counter_LS = 0;
u = 1;
while(u<=N_ls-1)
    if edge_index_LS(u) == edge_index_LS(u+1)
        repeat_counter_LS = repeat_counter_LS + 2;
        u = u+2;
    else
        u = u+1;
    end
end

if repeat_counter_LS >0 && N_ls - repeat_counter_LS == N_rs    %%误检，差2N的情况,删
    edge_index_LS = array_delete1(edge_index_LS);
end  
    
%右边
repeat_counter_RS = 0;
u = 1;

while(u<=N_rs-1)
    if edge_index_RS(u) == edge_index_RS(u+1)
        repeat_counter_RS = repeat_counter_RS + 1;
        u = u+2;
    else
        u = u+1;
    end
end

if repeat_counter_RS >0 && N_rs - repeat_counter_RS == N_ls    %%误检，差2N的情况,删
    edge_index_RS = array_delete1(edge_index_RS);
end
% %%  查奇
% if check_flag == 1
%     N_ls = length(edge_index_LS);
%     N_rs = length(edge_index_RS);
%     if mod(N_ls,2) + mod(N_rs,2) == 2     %1+1  0+1?  1+0?
%         edge_index_list = [edge_index_LS edge_index_RS];
%         N_list = length(edge_index_list);
%         cross_num = (N_ls+N_rs)/4;
%         max_value = zeros(1,N_list/2);
%         for j = 1:N_list/2
%             for i = 1:2:N_list-1
%                 max_value(j) = max(vec(edge_index_list(i):edge_index_list(i+1)));
%             end
%         end
%         [~,min_index] = min(max_value);
%         if min_index == cross_num
%             delete_index_LS = N_ls;
%             delete_index_RS = 1;
%             edge_index_LS = array_delete2(delete_index_LS,edge_index_LS);
%             edge_index_LS = array_delete2(delete_index_RS,edge_index_LS);
%         elseif N_ls > N_rs
%             delete_index = [min_index,min_index+1];
%             edge_index_LS = array_delete2(delete_index,edge_index_LS);
%         else
%             delete_index = [2*(min_index-cross_num),2*(min_index-cross_num)+1];
%             edge_index_RS = array_delete2(delete_index,edge_index_RS);
%         end
%     end
% end
%     %%%check
%     i = 1;
%     LS_span = zeros(1,length(edge_index_LS)./2);
%     while(i<= length(edge_index_LS)-1)
%         LS_span(i) = edge_index_LS(i+1)-edge_index_LS(i); 
%         i = i+2;
%     end
%     
%     i = 1;
%     RS_span = zeros(1,length(edge_index_RS)./2);
%     while(i<= length(edge_index_RS)-1)
%         RS_span(i) = edge_index_RS(i+1)-edge_index_RS(i); 
%         i = i+2;
%     end
%     
%     %对比
%     N_LS_span = length(LS_span);
%     N_RS_span = length(RS_span);
%     t = 1;
%     while(t<=N_LS_span)
%         if abs(LS_span(t)-RS_span(N_RS_span-t)) >=15     
%% 镜像换算
if repeat_counter_LS+repeat_counter_RS ==0
    num_person = round(count/2);
else
    num_person = round(length(edge_index_LS)/2);
end

%输入检查
%         if temp_l == 0 && temp_r ~=0 && temp_r >=10
%             count = count +1;
%             i = temp_r +1;
%             if temp_r >= MID    %Right Side
%                 edge_index_RS = [edge_index_RS temp_r];
%             else
%                 edge_index_LS = [edge_index_LS temp_r];
%             end
%         elseif temp_r == 0 && temp_l ~=0 && N-temp_l >=15
%             count = count +1;
%             i = N;
%             if temp_l >= MID    %Right Side
%                 edge_index_RS = [edge_index_RS temp_l];
%             else
%                 edge_index_LS = [edge_index_LS temp_l];
%             end
%         elseif temp_r ~= 0 && temp_l ~=0
%             if temp_r - temp_l > 7
%                 count = count + 1;
%                 if temp_l >= MID    %Right Side
%                     edge_index_RS = [edge_index_RS temp_l];
%                 else
%                     edge_index_LS = [edge_index_LS temp_l];
%                 end
%                 if temp_r >= MID    %Right Side
%                     edge_index_RS = [edge_index_RS temp_r];
%                 else
%                     edge_index_LS = [edge_index_LS temp_r];
%                 end
%             end
%             i = j + 1;
%         else
%             break;
%         end
