function [dir_list,tmp] = build_results_tree(project_path, option, name, num, groups)
%BUILD_RESULTS_TREE

    dir_list = cell(1,num);
    %create folders names
    f1 = strcat(option,'-',name);
    f2 = num2str(groups);
    f2 = regexprep(f2,'[^\w'']',''); %remove gaps
    f2 = strcat('g',f2,'res_');   
    for i = 1:num
        output_dir = fullfile(project_path,'results',f1,strcat(f2,num2str(i)));
        tmp = fullfile(project_path,'results',f1);
        try
            % delete the folder if already exists
            if exist(output_dir,'dir');
                rmdir(output_dir,'s');
            end
            mkdir(output_dir);
        catch
            errordlg('Cannot create folder for the results');
            return
        end
        dir_list{i} = output_dir;
    end
    % make the summary dir
    output_dir = fullfile(project_path,'results',f1,strcat(f2,'summary'));
    try
        % delete the folder if already exists
        if exist(output_dir,'dir');
            rmdir(output_dir,'s');
        end
        mkdir(output_dir);
    catch
        errordlg('Cannot create folder for the results');
    end 
    dir_list{end+1} = output_dir;
end

