function max_loop = trajectory_longest_loop( traj, values )
    ext = values(1);
    tol = values(2);
    
    pts = trajectory_simplify_impl(traj.points, tol); 
    d = zeros(size(pts, 1) - 1, 2);
    % compute direction vectors for each pair of points
    for i = 2:size(pts, 1)
        d(i - 1, :) = pts(i, 2:3) - pts(i - 1, 2:3);
    end

    max_loop = 0;
    % for each pair of line segments
    i = 1;
    while i < length(d)
        for j = (i + 2):length(d)
            rs = cross(d(i, :), d(j, :));
            if rs ~= 0  % check if they intersect               
                % vector from starting points of the 2 segments            
                pq = pts(j, 2:3) - pts(i, 2:3);
                t = cross(pq, d(j, :)) / rs;
                u = cross(pq, d(i, :)) / rs;
                
                intersect = 0;
                if t >= 0 && t <= 1 && u >= 0 && u <= 1
                    % they intersect, compute length of loop
                    intersect = 1;                    
                elseif (i == 1 && u >= 0 && u<= 1)
                   % first segment would self-cross the trajectory if
                   % extended further; see how far                   
                   e = norm(d(i, :))*abs(t) + norm(d(j, :))*u;
                   if t < 0 && e <= ext
                       intersect = 1;
                   end                    
                elseif (j == size(d, 1) && t >=0 && t<= 1)
                   % last segment, to the same check if we project if
                   % further                   
                   e = norm(d(i, :))*(1 - t) + norm(d(j, :))*abs(u);
                   if u > 0 && e < ext 
                       intersect = 1;
                   end
                end
                
                if intersect
                    l = sum(sqrt( d( (i + 1):(j - 1), 1).^2 + d( (i + 1):(j - 1), 2).^2 ));                    
                    l = l + norm(d(i, :))*(1 - t) + norm(d(j, :))*u;
                    max_loop = max(l, max_loop);       
                    i = j;
                    break;
                end
            end            
        end
        i = i + 1;
    end
    
    
    function v = cross(x, y)
        v = x(1)*y(2) - x(2)*y(1);
    end    
end