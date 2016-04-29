function [ obj ] = gui_setup_tags(obj,fn)
%SETUP_TAGS for the gui
    t_list = tags_list;
    if exist(fn,'file')
        % read the tags file
        tags_data = read_tags(fn);
        % update list of tags if needed
        % t_list_all = update_tags_list(tags_list,tags_data);
        t_list_all = tags_list;
        % exclude tags with no score
        t_list = {};
        k=1;
        for i=1:length(t_list_all)
            if  length(t_list_all{1,i})==4   
                t_list{1,k} = t_list_all{1,i};
                k=k+1;
            end    
        end    
        t_list_ab = cell(1,length(t_list));
        for i=1:length(t_list)
            t_list_ab{i} = t_list{1,i}{1,1};
        end    
        % update "tags" property of trajectory object
        for i=1:length(tags_data)
            index = tags_data{1,i}{1};
            if length(obj.SEGMENTS.items)>=index
                tags={};
                k=1;
                for j=1:length(tags_data{1,i}{1,2})
                    idx = find(strcmp(t_list_ab,tags_data{1,i}{1,2}{1,j}));
                    tags{1,k} = t_list{1,idx};
                    k=k+1;
                end    
                obj.SEGMENTS.items(1,index).tags = tags;   
            else
                error('MatchTags:InvalidTrajectory','The input file contains wrong data');
            end       
            if mod(i,100)==0
                fprintf('%d\n',i);
            end   
        end
    end
end    