function [ ids ] = parse_data_simplified( path, id_field, sessions )
%PARSE_DATA_SIMPLIFIED gets the animals ids from csv or xlsx files
 
    ids = cell(sessions,1);
    ids_temp = [];
    session = 1;
    f = dir(fullfile(path));
    
    % take the first folder
    for k = 3:length(f)
        if f(k).isdir == 1
            fprintf('Parsing Animal IDs from folder: %s\n',f(k).name);
            new_path = [path '/' f(k).name];
            ext = {'/*.csv','/*.CSV','/*.xlsx','/*.XLSX','/*.txt','/*.TXT'};
            for i = 1:length(ext)
                files = dir(fullfile([path '/' f(k).name], ext{i}));
                if ~isempty(files)
                    break
                end    
            end         
            str = ['Parsing Animal IDs from folder: ',sscanf(f(k).name,'%s')];
            h = waitbar(0,str,'Name','Parsing animal IDs');
            for j = 1:length(files)
                [~, ~, ext] = fileparts(fullfile(new_path,'/',files(j).name));
                if isequal(ext,'.CSV') || isequal(ext,'.csv') || isequal(ext,'.TXT') || isequal(ext,'.txt')
                    % open the file
                    fid = fopen(fullfile(new_path,'/',files(j).name));
                    % get the first line
                    num_cols = fgetl(fid);
                    % close it
                    fclose(fid);
                    % get the number of columns
                    if isequal(ext,'.TXT') || isequal(ext,'.txt')
                        num_cols = length(find(num_cols==';'))+1; 
                    else    
                        num_cols = length(find(num_cols==','))+1; 
                    end    
                    % make the file format
                    if isequal(ext,'.TXT') || isequal(ext,'.txt')
                        fmt = repmat('%q ',[1,num_cols]);
                    else
                        fmt = repmat('%s ',[1,num_cols]);
                    end    
                    % re-open the file and parse all its data
                    fid = fopen(fullfile(new_path,'/',files(j).name));
                    if isequal(ext,'.TXT') || isequal(ext,'.txt')
                        data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',';');
                    else
                        data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
                    end    
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
                    % MAC cannot read XLSX files with xlsread
                    if ismac
                        close(h);
                        disp('XLSX file format is not supported on MAC. Use TXT or CSV format.');
                        return
                    end    
                    [~, ~, data] = xlsread(fullfile(new_path,'/',files(j).name));
                    while i <= size(data,1)
                        if isequal(data{i,1},id_field)
                            if isnumeric(data{i,2})
                                id = data{i,2};
                            else
                                id = str2num(data{i,2});
                            end    
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
                    close(h);
                	return	
                end	
                waitbar(j/length(files));
            end
            close(h);
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

