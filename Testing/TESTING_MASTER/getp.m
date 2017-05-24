function tmp=getp(rpath,option)
    if option == 1
        f = dir(fullfile(rpath,'g12res_summary','*.txt'));
        tmp = [];
        if isempty(f)
            fid = fopen(fullfile(rpath,'g12res_1','strategies_p.txt'));
            A = fscanf(fid,'%s');
            A = strsplit(A,{'Class','_frdm:'}); 
            for t = 3:2:17
                tmp = [tmp;str2num(A{t})];
            end
            fclose(fid);
        else
            fid = fopen(fullfile(rpath,'g12res_summary','binomial.txt'));
            A = fscanf(fid,'%s');
            A = strsplit(A,{'[',']'}); 
            for t = 2:2:16
                if isequal(A{t}(2),'.');
                    temp = A{t}(1:4);
                    tmp = [tmp;str2num(temp)];
                else
                    tmp = [tmp;0];
                end
            end
        end        
    elseif option == 2
        f = dir(fullfile(rpath,'g12res_summary','*.txt'));
        if isempty(f)
            fid = fopen(fullfile(rpath,'g12res_1','transitions_p.txt'));
            A = fscanf(fid,'%s');
            A = strsplit(A,'p_frdm:');
            tmp = str2num(A{2});
            fclose(fid);
        else
            fid = fopen(fullfile(rpath,'g12res_summary','binomial.txt'));
            A = fscanf(fid,'%s');
            A = strsplit(A,{'[',']'}); 
            if isequal(A{2}(2),'.');
                tmp = str2num(A{2}(1:4));
            else
                tmp = 0;
            end
        end               
    end
end