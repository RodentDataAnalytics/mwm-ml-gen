function error_messages(option, varargin)
%ERROR_MESSAGES 

    switch option
        case 1
            errordlg('Cannot load project settings','Error');
        case 2
            errordlg('No trajectory features has been computed','Error');
        case 3
            errordlg('Cannot load segmentation','Error');
        case 4
            errordlg('Cannot load labels','Error');
        case 5
            errordlg('Selected segmentation and labels do not match','Error');
        case 6
            errordlg('Cannot create classification folder','Error');
        case 7
            errordlg('Wrong input for Clusters');
        case 8
            errordlg('No project is currently loaded','Error');
        case 9
            errordlg('A labels files needs to be selected','Error');
        case 10
            errordlg('A segmentation and a labels files need to be selected','Error');
        case 11
            errordlg('Cannot create merged classification folder','Error');
        case 12
            errordlg('Cannot find equivalent segmentation object','Error');  
        case 13
            errordlg('The output folder specified does not exist','Error');
        case 14
            errordlg('The pool does not contain any classifiers','Error');
        case 15
            errordlg('Error loading classifier object','Error');    
        case 16
            errordlg('Error executing the majority rule','Error');
        case 17
            errordlg('Selected classification and segmentation do not match','Error');
        case 18
            errordlg('Error generating the results (generate_results.m)','Error:Dev');   
        case 19
            errordlg('Cannot create summary file','Error');
        case 20
            errordlg('Could not create p-values summary file','Error');
        case 21
            errordlg('Cannot create summary p-values figure','Error');
        case 22
            errordlg('Cannot generate metrics','Error');
    end
            

end

