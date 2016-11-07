function [labs,len,ovl,note,ppath] = split_labels_name(path_labels)
%SPLIT_LABELS_NAME given the full file path of a label it returns the
%number of labels, the segments length, the segments overlap and the notes.

    [pathstr,name,~] = fileparts(path_labels);
    subname = strsplit(name,{'_','-'});
    labs = subname{2};
    len = subname{3};
    ovl = subname{4};
    if length(subname) > 4
        note = subname{5};
    else
        note = '';
    end
    ppath = fileparts(pathstr);
end

