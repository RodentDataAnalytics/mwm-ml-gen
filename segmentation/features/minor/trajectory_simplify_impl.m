function T = trajectory_simplify_impl( pts, lmin)   
    cur = 1;
    T = pts(1, :);
    prev = pts(1,:);
    for i = 2:size(pts,1)
        pt = pts(i,:);       
        if norm(prev(:, 2:3) - pt(:, 2:3)) >= lmin            
            T = [T; pt];    
            prev = pt;
        end
    end
end