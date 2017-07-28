function [time_per_segment,rem_time] = intervals_time(d_points, store_d)
% Returns the time slot in which the animal implemented each strategy
    
    time_per_segment = -1*ones(size(d_points,1),size(d_points,2));
    rem_time = -1*ones(size(store_d,1),1);
    
    for i = 1:size(d_points,1)
        if isempty(d_points{i,2}) %unsegmented trajectory was converted to segment
            tmp = d_points{i,1}(:,1);
            time_per_segment(i,1) = tmp(end) - tmp(1);
            rem_time(i) = 0;
            continue;
        end
        cum_time = 0;
        for j = 1:size(d_points,2)
            if isempty(d_points{i,j})
                continue;
            end
            sel_seg = d_points{i,j}(:,1);
            if sel_seg(end) == - 1 %find end time
                if j ~= size(d_points,2) && ~isempty(d_points{i,j+1})
                    tmp = d_points{i,j+1}(:,1);
                else %take from the remaining points
                    tmp = store_d{i}(:,1);
                end
                a = find(tmp ~= -1);
                if isempty(a)
                    continue
                end
                a = tmp(a(1));
                b = find(sel_seg ~= -1);
                if isempty(b)
                    continue
                end
                b = sel_seg(b(end));
                end_time = b + (a-b)/2;
            end
            start_time = sel_seg(1);
            if sel_seg(1) == -1 %find start time (the first one cannot have -1)
                tmp = d_points{i,j-1}(:,1);
                a = find(tmp ~= -1);
                if isempty(a)
                    continue
                end
                a = tmp(a(end));
                b = find(sel_seg ~= -1);
                if isempty(b)
                    continue
                end                
                b = sel_seg(b(1));
                start_time = b + (b-a)/2;                
            end
            time_per_segment(i,j) = end_time - start_time;
            cum_time = cum_time + time_per_segment(i,j);
        end
        rem_time(i) = store_d{i}(end,1) - cum_time;
    end
end