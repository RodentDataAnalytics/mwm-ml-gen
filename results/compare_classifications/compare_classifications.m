function error = compare_classifications(classifications,ppath)
    
    error = 1;
    if length(classifications) ~= 2
        errordlg('Select two classifications for comparisson','Error');
    end
    
    h = waitbar(0,'Loading...','Name','Confusion Matrix');
    
    % Find the segmentations
    tmp = dir(fullfile(ppath,'segmentation','*.mat'));
    segmentations = cell(1,2);
    for i = 1:2
        [error,~,segments,seg_length,seg_overlap,~,~,~] = split_mclassification_name(classifications{i});
        if error
            delete(h);
            errordlg('Wrong specified classification','Error');
            return;
        end
        for j = 1:length(tmp)
            [error,segs,lens,ovlp] = split_segmentation_name(fullfile(ppath,'segmentation',tmp(j).name));
            if error
                delete(h);
                errordlg('Wrong specified segmentation','Error');
                return;
            end
            if isequal(segments,segs) && isequal(seg_length,lens) && isequal(seg_overlap,ovlp)
                load(fullfile(ppath,'segmentation',tmp(j).name));
                segmentations{i} = segmentation_configs;
                clear segmentation_configs;
                break;
            end
        end
    end
    if isempty(segmentations{1}) || isempty(segmentations{2})
        delete(h);
        errordlg('Could not find the correct segmentation(s) inside the project.','Error');
        return;        
    end
    
    % Find matched segments
    matched = match_segments(segmentations);
    if isempty(matched)
        delete(h);
        errordlg('Cannot find matched segments','Error');
        return
    end
    
    % Select equal number of files from each classification folder
    files_1 = dir(fullfile(classifications{1},'*.mat'));
    files_2 = dir(fullfile(classifications{2},'*.mat'));
    
    % Check if everything is ok
    if isempty(files_1) || isempty(files_2)
        delete(h);
        errordlg('The specified folder does not contain classification_configs files','Error');
        return;
    end
    if isempty(strfind(files_1(1).name,'merged')) || isempty(strfind(files_2(1).name,'merged'))
        delete(h);
        errordlg('The specified folder does not contain classification_configs files','Error');
        return;
    end
    
    % Sort files
    queue = zeros(length(files_1),1);
    for i = 1:length(files_1)
        tmp = strsplit(files_1(i).name,{'merged_','.mat'});
        queue(i) = str2double(tmp{2});
    end
    [~,idx] = sort(queue);
    files_1 = files_1(idx);
    queue = zeros(length(files_2),1);
    for i = 1:length(files_2)
        tmp = strsplit(files_2(i).name,{'merged_','.mat'});
        queue(i) = str2double(tmp{2});
    end
    [~,idx] = sort(queue);
    files_2 = files_2(idx);
    
    % Collect all the tags
    load(fullfile(classifications{1},files_1(1).name));
    ids = zeros(1,length(classification_configs.ALL_TAGS));
    for i = 1:length(ids)
        ids(i) = classification_configs.ALL_TAGS{i}{3};
    end
    
    % Form the output folder
    name_1 = strsplit(classifications{1},{'\','/'});
    name_1 = name_1{end};
    name_2 = strsplit(classifications{2},{'\','/'});
    name_2 = name_2{end};
    name = strcat('comparison-',name_1,'.',name_2);
    ouput_folder = fullfile(ppath,'results',name);
    if ~exist(ouput_folder,'dir')
        mkdir(ouput_folder);
    end
    
    delete(h);
    
    h = waitbar(0,strcat('Computing agreements 1/',num2str(length(files_1))),'Name','Confusion Matrix');
    cmatrix = zeros(length(files_1),length(files_2));
    collect = {};
    
    %% Compute confusion matrices and statistics 
    for i = 1:length(files_1)
        load(fullfile(classifications{1},files_1(i).name));
        % select only matched segments
        class_1 = classification_configs.CLASSIFICATION.class_map(matched(:,1));
        % find number of segs per class (including undefined)
        per_strat = zeros(1,length(ids));
        for s = 1:length(ids)
            per_strat(s) = length(find(class_1 == ids(s)));
        end
        
        % Each loop will find agreement of class_map_1 ---> class_map_x
        for j = 1:length(files_2)
            load(fullfile(classifications{2},files_2(j).name));
            % select only matched segments
            class_2 = classification_configs.CLASSIFICATION.class_map(matched(:,2));
            
            % compute the confusion matrix
            [confusion_matrix,order] = confusionmat(class_1,class_2,'order',ids);
            
            diagonal = diag(confusion_matrix);
            % overall agreement (numeric)
            overall_agreement_num = sum(diagonal);
            % overall agreement (percentage)
            overall_agreement_per =  100 * ( overall_agreement_num / size(matched,1) );
            % agreement per strategy (numeric)
            per_strat_num = zeros(length(order),1);
            for o = 1:length(order)
                per_strat_num(o) = diagonal(o);
            end
            % agreement per strategy (percentage)
            per_strat_per = zeros(length(order),1);
            for o = 1:length(order)
                per_strat_per(o) = 100 * ( per_strat_num(o) / per_strat(o) );
            end
            % collect the results
            collect{j,1} = 'confusion matrix';
            collect{j,2} = confusion_matrix;
            collect{j,3} = 'agreement [numeric, percentage]';
            collect{j,4} = [overall_agreement_num, overall_agreement_per];
            collect{j,5} = 'agreement per strategy (numeric)';
            collect{j,6} = per_strat_num;
            collect{j,7} = 'agreement per strategy (percentage)';
            collect{j,8} = per_strat_per;
            
            cmatrix(i,j) = overall_agreement_per;
        end   
        
        %% Export everything
        %fprintf('Saving & exporting results...\n');
        
        number = strsplit(files_1(i).name,{'merged_','.mat'});
        save(fullfile(ouput_folder,strcat('collect_',number{2},'.mat')),'collect');
        
        %form the first column
        names1 = {};
        for j = 1:length(files_1)
            fileName = strsplit(files_1(j).name,'.mat');
            names1 = [names1, fileName{1}];
        end
        names2 = {};
        for j = 1:length(files_2)
            fileName = strsplit(files_2(j).name,'.mat');
            names2 = [names2, fileName{1}];
        end
        tags = cell(length(classification_configs.ALL_TAGS),1);
        for j = 1:length(tags)
            tags{j} = classification_configs.ALL_TAGS{j}{2};
        end
        col_names = {'Agreement';'Numeric';'Percentage';'Overall Numeric';'Overall Percentage'};
        column = cell(length(tags)+1,1);
        for j = 1:length(tags)
            column{j+1} = tags{j};
        end
        column = [column ; col_names];
        %form the main table
        table_all = {};
        for j = 1:size(collect,1)
            table = [tags' ; num2cell(collect{j,2}) ; tags' ; num2cell(collect{j,6})' ; num2cell(collect{j,8})'];
            table{end+2,1} = [];
            table{end-1,1} = strcat(num2str(collect{j,4}(1)),'/',num2str(size(matched,1)));
            table{end,1} = collect{j,4}(2);
            %put everything together
            table = [column,table];
            table{1,1} = strcat(names1{i},'--',names2{j});

            gap_line = cell(1,size(table,2));
            table_all = [table_all ; table ; gap_line];
        end
        table_all = table_all(1:end-1,:); %remove last empty row
        %write to CSV-file (.csv)
        header = ['Reference', tags'];
        [~,class_name] = fileparts(classifications{1});
        subheader = [strcat(class_name,'::',names1{i}) num2cell(per_strat)];
        table_all = [header ; subheader ; gap_line ; table_all]; 
        table_all = cell2table(table_all);
        writetable(table_all,fullfile(ouput_folder,strcat('agreement_',number{2},'.csv')),'WriteVariableNames',0);

        h = waitbar(i/length(files_1),h,strcat('Computing agreements ',num2str(i+1),'/',num2str(length(files_1))));
    end
    
    waitbar(1,h,'Finalizing');
    
    % Export the agreement matrix    
    column = {};
    for i = 1:length(files_1)
        tmp = strsplit(files_1(i).name,'.mat');
        column = [column; tmp{1}];
    end
    row = {};
    for i = 1:length(files_2)
        tmp = strsplit(files_2(i).name,'.mat');
        row = [row; tmp{1}];
    end  
    header = ['Agreement Matrix',row'];
    table = [column,num2cell(cmatrix)];
    table = [header;table];
    table = cell2table(table);
    save(fullfile(ouput_folder,'agreement_matrix.mat'),'cmatrix');
    writetable(table,fullfile(ouput_folder,'agreement_matrix.csv'),'WriteVariableNames',0);
    
    delete(h) %if it is not deleted the next figure is not generated
    
    % Export the agreement matrix as image (10x10 grid)
    
    %split the agreement matrix into 10x10 grids and in case we have
    %remainder increase the grids so that remainder = 0
    cmatrix_bk = cmatrix;
    integer_ = [0 0];
    for i = 1:2
        if size(cmatrix_bk,i) > 10
            integer = fix(size(cmatrix_bk,i)/10);
            remainder = rem(size(cmatrix_bk,i),10);
        end    
        if remainder > 0
            digit = num2str(size(cmatrix_bk,i));
            digit = str2num(digit(end));
            digit = 10-digit;
            si = size(cmatrix_bk,i);
            if i == 1
                cmatrix_bk(digit + si , :) = 0;
            else
                cmatrix_bk(:, digit + si) = 0;
            end  
            integer_(i) = integer + 1;
        else
            integer_(i) = integer;
        end
    end
    %x, y axes labels
    ylabels_ = cell(1,size(cmatrix_bk,1));
    for i = 1:size(cmatrix_bk,1)
        ylabels_{i} = strcat('c',num2str(i));
    end
    xlabels_ = cell(1,size(cmatrix_bk,2));
    for i = 1:size(cmatrix_bk,2)
        xlabels_{i} = strcat('c',num2str(i),char(39));
    end
    
    k = 1; %counts decades from up to down
    kk = 1; %counts decades from left to right
    for ii = 1 : integer_(1) * integer_(2)
        if k <= size(cmatrix_bk,1)
            cmatrix = cmatrix_bk(k:k+9,kk:kk+9);
            ylabels = ylabels_(k:k+9);
            xlabels = xlabels_(kk:kk+9);
            k = k+10;
        elseif k > size(cmatrix_bk,1)
            k = 1;
            kk = kk+10;
            cmatrix = cmatrix_bk(k:k+9,kk:kk+9);
            ylabels = ylabels_(k:k+9);
            xlabels = xlabels_(kk:kk+9);
            k = k+10;
        end
        
        % Generate and export the image
        f = imagesc_adv(cmatrix,'colorbar','on','colormap_range',[0 100],'XTickLabel',xlabels,'YTickLabel',ylabels);
        if isempty(f)
            errordlg('Cannot generate image. x-axis size can be up to 676.','Error');
            return
        else
            [~, ~, ~, Export, ExportStyle] = parse_configs;
            export_figure(f, ouput_folder, sprintf('agreement_matix_icon%d',ii), Export, ExportStyle);
            delete(f)
        end   
    end   
    
    error = 0;
end
        