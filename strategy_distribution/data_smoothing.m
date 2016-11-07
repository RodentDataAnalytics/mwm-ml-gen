function [trajectory_distribution] = data_smoothing(trajectory_distribution, minimum)
%DATA_SMOOTHING merge small trajectory parts with other neighboured one

    for i = 1:size(trajectory_distribution,1)
        j = 1;
        %for each cell
        while j <= size(trajectory_distribution{i,1},2)
            %check if the points is less than the minimum
            if size(trajectory_distribution{i,4}{j},1) < minimum
                %if it is the first element
                if j == 1
                    %give the points to the next one
                    trajectory_distribution{i,1}(1) = [];
                    trajectory_distribution{i,2}(2) = trajectory_distribution{i,2}(1) + trajectory_distribution{i,2}(2);
                    trajectory_distribution{i,2}(1) = [];
                    trajectory_distribution{i,3}(1) = [];
                    trajectory_distribution{i,4}{2} = [trajectory_distribution{i,4}{1} ; trajectory_distribution{i,4}{2}];
                    trajectory_distribution{i,4}(1) = [];
                %if it is the last element
                elseif j == size(trajectory_distribution{i,1},2)
                    %give the points to the previous one
                    trajectory_distribution{i,1}(j) = [];
                    trajectory_distribution{i,2}(j-1) = trajectory_distribution{i,2}(j-1) + trajectory_distribution{i,2}(j);
                    trajectory_distribution{i,2}(j) = [];
                    trajectory_distribution{i,3}(j) = [];
                    trajectory_distribution{i,4}{j-1} = [trajectory_distribution{i,4}{j-1} ; trajectory_distribution{i,4}{j}];
                    trajectory_distribution{i,4}(j) = [];
                %for everything else
                else
                    %get the weights of the previous and next one 
                    %winner is the one with the smallest weight
                    w1 = trajectory_distribution{i,1}(j-1);
                    w2 = trajectory_distribution{i,1}(j+1);
                    %give the points to the next one
                    if w1 > w2
                        trajectory_distribution{i,1}(j) = [];
                        trajectory_distribution{i,2}(j+1) = trajectory_distribution{i,2}(j+1) + trajectory_distribution{i,2}(j);
                        trajectory_distribution{i,2}(j) = [];
                        trajectory_distribution{i,3}(j) = [];
                        trajectory_distribution{i,4}{j+1} = [trajectory_distribution{i,4}{j} ; trajectory_distribution{i,4}{j+1}];
                        trajectory_distribution{i,4}(j) = [];
                    %give the points to the previous one
                    else    
                        trajectory_distribution{i,1}(j) = [];
                        trajectory_distribution{i,2}(j-1) = trajectory_distribution{i,2}(j-1) + trajectory_distribution{i,2}(j);
                        trajectory_distribution{i,2}(j) = [];
                        trajectory_distribution{i,3}(j) = [];
                        trajectory_distribution{i,4}{j-1} = [trajectory_distribution{i,4}{j-1} ; trajectory_distribution{i,4}{j}];
                        trajectory_distribution{i,4}(j) = [];  
                    end                        
                end
            else
                j = j + 1;
            end    
        end
    end   
end

