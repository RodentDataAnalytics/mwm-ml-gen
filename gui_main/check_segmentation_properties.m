function error = check_segmentation_properties(seg_length,seg_overlap)
%CHECK_SEGMENTATION_PROPERTIES checks if the segmentation properties are
%correct.

    error = 1;
    seg_length = str2double(seg_length);
    seg_overlap = str2num(seg_overlap);
    if isnan(seg_length) || isempty(seg_overlap)
        errordlg('Segment length and overlap need to have numeric, non-zero and non-negative values','Input error');
        return
    end
    if seg_length <= 0 
        errordlg('Segment length needs to have a non-zero positive value','Input error');
        return;
    end
    for i = 1:length(seg_overlap)
        if seg_overlap(i) >= 1 || seg_overlap(i) <= 0
            errordlg('Segment overlap(s) need to be within the range 0 < seg_overlap < 1','Input error');
            return;
        end
    end
    error = 0;
end

