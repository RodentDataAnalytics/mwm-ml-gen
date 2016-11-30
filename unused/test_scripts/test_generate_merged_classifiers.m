sample_length = 80;
iterations_length = 70;
threshold = 0;
project_path = 'C:\Users\Avgoustinos\Documents\MWMGEN\demo_original_set_1';
classifications = {'class_1301_10388_250_07-tiago'};


h = waitbar(0,'init');

for i = 2:sample_length
    
    str = ['Sample = ',num2str(i),'/',num2str(sample_length),' iteration = ',num2str(j),'/',num2str(iterations_length)];
    waitbar(0,h,str)
    
    for j = 1:iterations_length
        error = execute_Mclassification(project_path, classifications, i, j, threshold);
        if error
            fprinf('error at sample_length: %d, iterations_length: %d',i,j);
        end
        
        str = ['Sample = ',num2str(i),'/',num2str(sample_length),' iteration = ',num2str(j),'/',num2str(iterations_length)];
        waitbar(j/iterations_length,h,str);
    end
end

delete(h);
