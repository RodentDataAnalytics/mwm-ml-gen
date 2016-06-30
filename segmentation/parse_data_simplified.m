function [ ids ] = parse_data_simplified( path, id_field, sessions )
%PARSE_DATA_SIMPLIFIED gets the animals ids from csv files
 
    ids = cell(sessions,1);
    ids_temp = [];
    session = 1;
    f = dir(fullfile(path));

    % take the first folder
    for k = 3:length(f)
        if f(k).isdir == 1
            fprintf('Parsing Animal IDs from folder: %s\n',f(k).name);
            new_path = [path '/' f(k).name];
            ext = {'/*.csv','/*.CSV','/*.xlsx','/*.XLSX'};
            for i = 1:length(ext)
                files = dir(fullfile([path '/' f(k).name], ext{i}));
                if ~isempty(files)
                    break
                end    
            end         
            for j = 1:length(files)
                [~, ~, ext] = fileparts(fullfile(new_path,'/',files(j).name));
                if isequal(ext,'.CSV') || isequal(ext,'.csv')
                    % open the file
                    fid = fopen(fullfile(new_path,'/',files(j).name));
                    % get the first line
                    num_cols = fgetl(fid);
                    % close it
                    fclose(fid);
                    % get the number of columns
                    num_cols = length(find(num_cols==','))+1; 
                    % make the file format
                    fmt = repmat('%s ',[1,num_cols]);
                    % re-open the file and parse all its data
                    fid = fopen(fullfile(new_path,'/',files(j).name));
                    data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
                    data = data{1};
                    fclose(fid);
                    % Search the Animal ID field and parse the ID number
                    i = 1;
                    while i <= size(data,1)
                        if isequal(data{i,1},id_field)
                            id = sscanf(data{i,2}, '%d');
                            break;
                        end
                        i = i+1;
                    end                      
                elseif isequal(ext,'.XLSX') || isequal(ext,'.xlsx')
                    [~, ~, data] = xlsread(fullfile(new_path,'/',files(j).name));
                    while i <= size(data,1)
                        if isequal(data{i,1},id_field)
                            id = data{i,2};
                            break;
                        end
                        i = i+1;
                    end    
                end

                % store the animal ids
                try
                	ids_temp = [ids_temp, id];
                catch
                	errordlg('Animal ID not found. Check the provided ID Field','Parse ID Error');
                	return	
                end	
            end
            % store the unique animal ids per session
            ids{session} = unique(ids_temp);
            ids_temp = [];
            if session == sessions
                break;
            end    
            session = session + 1;
        end
    end    

end

