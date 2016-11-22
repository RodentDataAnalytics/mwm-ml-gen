function find_similar_unlabelled(segmentation_configs,Mfolder)
%FIND_SIMILAR_UNLABELLED counts how many times each segment appears as
%unlabelled over all the Mclassifications.

    files = dir(fullfile(Mfolder,'*.txt'));
    all_nums = [];
    for i = 1:length(files)
        % Open and parse the file
        fid = fopen(fullfile(Mfolder,files(i).name));
        text = textscan(fid, '%s','delimiter', '\n');
        text = text{1};
        fclose(fid);
        % Take all the Undecided seg numbers
        undecided = strsplit(text{3},'Undecided: ');
        undecided = str2double(undecided{2});
        nums = text(4:undecided+3);
        nums = str2double(nums);  
        all_nums = [all_nums ; nums];
    end
    % Count how many times we have each number
    u = unique(all_nums);
    table = zeros(length(u),2);
    table(:,1) = u;
    for i = 1:length(u)
        table(i,2) = length(find(all_nums == table(i,1)));
    end
    % Sort by number count
    table = sortrows(table,2);
    % Convert to trajectory-segments
    traj = zeros(size(table,1),1);
    segs = zeros(size(table,1),1);
    for i = 1:length(traj)
        [traj_id, seg_id] = find_traj_of_seg(segmentation_configs.SEGMENTS,table(i,1));
        traj(i) = traj_id;
        segs(i) = seg_id;
    end
    % Finalize the table
    table = [traj, segs, table];
    % Export as CSV-file
    table = num2cell(table);
    table = [{'Trajectry','Segment', 'Segment ID', 'Count'} ; table];
    table = cell2table(table);
    fpath = fullfile(Mfolder,'common_undefined.csv');
    writetable(table,fpath,'WriteVariableNames',0);
end

