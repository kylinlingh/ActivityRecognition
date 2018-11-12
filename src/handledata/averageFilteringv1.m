function averageFiltering(cachedData,check_axis, check_id, win_size, output_file_name)
%check_axis = 'z';
%check_id = 33;
%check_acti = 2;
%win_size = 20;
%% Read data
id_data = cachedData(:,1);
acti_label = cachedData(:,2);

switch check_axis
    case 'x', component = 4;
    case 'y', component = 5;
    case 'z', component = 6;
end
axis_data = cachedData(:,component);
check_axis = axis_data(id_data == check_id);
check_label = acti_label(id_data == check_id);

%% Filter signals within same activity
pre_label = check_label(1);
output_raw_data = [];
output_raw_label = [];
output_filted_data = [];

cur_raw_data = [];
cur_raw_label = [];

for da_index = 1 : length(check_axis)
    cur_label = check_label(da_index);
    if cur_label == pre_label
       cur_raw_data = [cur_raw_data; check_axis(da_index)];
       cur_raw_label = [cur_raw_label; check_label(da_index)];
    else
        cumsum = [0];
        filted_data = [];
       % belief_min, belief_max = calculateBeliefArea(cur_raw_data);
        
        for i = 2 : length(cur_raw_data)+1
            cumsum(i) = (cumsum(i-1) + cur_raw_data(i-1));
            if i > win_size
                moving_ave = ( cumsum(i) - cumsum(i-win_size)) / win_size;
                filted_data = [filted_data; moving_ave];
%                output_raw_label = [output_raw_label; pre_label];
            end
        end
        output_raw_data = [output_raw_data; cur_raw_data(1: end-win_size+1)];
        output_raw_label = [output_raw_label; cur_raw_label(1: end-win_size+1)];
        output_filted_data = [output_filted_data; filted_data];
        cur_raw_data = [];
        cur_raw_label = [];
        pre_label = cur_label;
    end
end
fprintf('Length of output_raw_data: %d\n', length(output_raw_data));
fprintf('Length of output_raw_label: %d\n', length(output_raw_label));
fprintf('Length of output_filted_data: %d\n', length(output_filted_data));
output_data = [output_raw_data, output_filted_data, output_raw_label ];
%%
%{
    function [min, max] = calculateBeliefArea(dataArray)
        a=0.01; %0.01 ��Ӧ99%�������䣬 0.05 ��Ӧ95%�������� ��0.1 ��Ӧ90%��������
        if a==0.01
            n=2.576; % 2.576 ��Ӧ99%�������䣬 1.96 ��Ӧ95%�������� ��1.645 ��Ӧ90%��������
        elseif a==0.05
            n=1.96;
        elseif a==0.1
            n=1.645;
        end
        %�����Ӧ�ٷ�λֵ
        meana=mean(sampledata);
        stda=std(sampledata);
        sorta=sort(sampledata);  %�����ݴ�С��������
        leng=size(sampledata,1);
        CIa(1:2,1)=[sorta(leng*a/2);sorta(leng*(1-a/2))];
        %���ù�ʽ������������
        CIf(1:2,1)=[meana-n*stda;meana+n*stda];
        min = CIf(1,1);
        max = CIf(1,2);
    end
%}

csvwrite(output_file_name, output_data);
end