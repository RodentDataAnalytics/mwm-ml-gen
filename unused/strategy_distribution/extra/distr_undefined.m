function [identified_seg_classes,marked] = distr_undefined(strats,strategy_length,seg_classes,norm_method)
%DISTR_UNDEFINED adds labels to undefined segments based on neighboured 
%defined ones.

%INPUT
% strats = 1xN array with strategies (id numbers) that exist.
% strategy_length = feature length of the segments.
% seg_classes = 1xN array with segment labels.
% norm_method = normalization method; used when we choose between classes
%               (see normalizations.m). 'skip' to skip distr_undefined.
%RETURN
% identified_seg_classes = the fully classified trajectory
% marked = if the trajectory is fully unclassified it is marked

    %in case we want to skip this function
    if isequal(norm_method,'skip')
        identified_seg_classes = seg_classes;
        marked = 0;
        return;
    end    
    marked = 0; %becomes 1 in case the segment is 100% unclassified. 
    undef = find(strats == 0);
    strats = strats(2:end); %remove the undefined 
    strategy_length = strategy_length(2:end); %remove the undefined
    if undef
        % normalize each strategy length
        w = normalizations(strategy_length,norm_method);
    else
        identified_seg_classes = seg_classes;
        return;
    end  
    % find indexes wih undefined
    def = find(seg_classes ~= 0);
    % find indexes wih defined
    undef = find(seg_classes == 0);
    u = 1;
    while u <= length(undef)
        %if this element is still undefined
        fprintf('%d\n',u);
        if seg_classes(undef(u)) == 0
            %find previous and next defined indexes
            %a = find(def == undef(u)-1);
            a = find(def < undef(u));
            try
                a = def(a(end));
            catch
            end    
            %b = find(def == undef(u)+1);
            b = find(def > undef(u));
            try
                b = def(b(1));
            catch
            end    
            if ~isempty(a) && ~isempty(b)
                %if we do not have 3 or more undefined in a row
                if b - a <= 3
                    %the class with the less weight wins
                    x1 = find(strats == seg_classes(a));
                    x2 = find(strats == seg_classes(b));
                    if w(x1) > w(x2)
                        seg_classes(undef(u)) = strats(x2);
                    elseif w(x1) < w(x2) 
                        seg_classes(undef(u)) = strats(x1);
                    else % in the etremely rare case they are equal
                        seg_classes(undef(u)) = strats(x2);
                    end 
                    u = u+1;
                %if we have 3 or more undefined in a row    
                else
                    if mod(b-a,2) == 0 %if even => odd number of zeros
                        % split them and reculculate the middle 0 only
                        q = fix(b-a-1/2); 
                        seg_classes(a:a+q) = seg_classes(a);
                        seg_classes(b-q:b) = seg_classes(b);
                        u = u+q;
                        %u = u+1;
                    else    
                        q = (b-a-1)/2;
                        %the class with the less weight takes 1 more
                        x1 = find(strats == seg_classes(a));
                        x2 = find(strats == seg_classes(b));
                        if w(x1) > w(x2)
                            seg_classes(a:a+q-1) = seg_classes(x1);
                            seg_classes(b-q-1:b) = seg_classes(x2);
                        elseif w(x1) < w(x2) 
                            seg_classes(a:a+q) = seg_classes(x2);
                            seg_classes(b-q:b) = seg_classes(x1);
                        else % in the etremely rare case they are equal
                            seg_classes(a:a+q) = seg_classes(a);
                            seg_classes(b-q:b) = seg_classes(b);
                        end   
                        u = u+(q*2);
                        %u = u+1;
                    end
                end
            %if it happens to be the first or the last    
            else
                if isempty(a) && ~isempty(b)
                    seg_classes(undef(u)) = seg_classes(b);
                elseif ~isempty(a) && isempty(b)
                    seg_classes(undef(u)) = seg_classes(a);
                else
                    %means that the trajectory is not defined at all
                    marked = 1;
                    break;
                end    
                u = u+1;
            end
        else
            u = u+1;
        end
    end    
    % return
    identified_seg_classes = seg_classes;    
end

