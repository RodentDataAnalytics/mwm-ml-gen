function majority_rule_report(classifications,cannot_decide,threshold_skip,ppath)
%MAJORITY_RULE_REPORT generates a report file with the following format:
%header: [number of segments]_
%        [number of clusters per classifier separate by .]
%count: number of segments that could not be assigned with a label
%segment list: list of the above segments.

%EXAMPLE:
%----------------------------------------
%29476_14.105.55.84.30.93.114.89.86.95
%Total: 1886
%Undecided: 1886
%139
%141
%150
%169
%...
%Threshold: 0
%----------------------------------------

    % generate header
    clusters = zeros(length(classifications),1);
    segs = zeros(length(classifications),1);
    for i = 1:length(clusters)
        segs(i) = size(classifications{i}.FEATURES,1);
        clusters(i) = classifications{i}.DEFAULT_NUMBER_OF_CLUSTERS;
    end
    [segs,idx] = sort(segs);
    clusters = clusters(idx);
    str = strcat(num2str(segs(1)),'_',num2str(clusters(1)),'.');
    for i = 2:length(clusters)
        if segs(i-1) ~= segs(i)
            %remove the last dot and place '-'
            str = strcat(str(1:end-1),'-',strcat(num2str(segs(i))),'_');
        end
        str = strcat(str,num2str(clusters(i)),'.');
    end
    str = str(1:end-1); %remove the last dot
    
    % generate file name
    i = 1;
    while 1
        name = sprintf('unlabelled_segs_%d.txt',i);
        if ~exist(fullfile(ppath,name), 'file')
            break;
        end
        i = i+1;
    end
    
    % generate report
    total = [cannot_decide threshold_skip];
    total = unique(total);
    total = length(total);
    fid = fopen(fullfile(ppath,name),'wt');
    fprintf(fid,'%s\n',str);
    fprintf(fid,'Total: %d\n',total);
    fprintf(fid,'Undecided: %d\n',length(cannot_decide));
    if ~isempty(cannot_decide)
        for i = 1:length(cannot_decide)
            fprintf(fid,'%d\n',cannot_decide(i));
        end
    end
    fprintf(fid,'Threshold: %d\n',length(threshold_skip));
    if ~isempty(threshold_skip) 
        for i = 1:length(threshold_skip)
            fprintf(fid,'%d\n',threshold_skip(i));
        end
    end
    fclose(fid);
end

