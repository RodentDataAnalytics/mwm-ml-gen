function val = trajectory_time_within_radius( traj, values )
    x0 = values(1);
    y0 = values(2);
    r = values(3)*6;
    tol = values(4);

    pts = trajectory_simplify_impl(traj.points, tol); 
    ltot = 0;
    lins = 0;
    for i = 2:size(pts, 1)
       % direction vector of trajectory segment
       d = pts(i, 2:3) - pts(i - 1, 2:3);
       % vector from centre of platform to segment start
       f = pts(i - 1, 2:3) - [x0, y0];
       
       a = d*d';
       b = 2*(f*d');
       c = f*f' - r^2;
       disc = b^2 - 4*a*c;
       
       lseg = norm(pts(i, 2:3) - pts(i - 1, 2:3));
       ltot = ltot + lseg;
       if disc >= 0           
           % there is an intersection with the platform
           disc = sqrt(disc);
           t1 = (-b - disc) / (2*a);
           t2 = (-b + disc) / (2*a);
           % check cases
           if t1 >= 0 && t1 <= 1
               % beginning of segment crossed the circle
               if t2 >= 0 && t2 <= 1
                    % segment crosses and overshoots the circle
                   lins = lins + (t2 - t1)*lseg;
               else
                   % entered the circle area
                   lins = lins + (1 - t1)*lseg;                   
               end
           elseif t2 >= 0 && t2 <= 1
               % left the circle area
               lins = lins + t2*lseg;
           elseif norm(pts(i - 1, 2:3) - [x0, y0]) <= r ...
               && norm(pts(i, 2:3) - [x0, y0]) <= r
               % segment fully contained in the circle
               lins = lins + lseg;
           end
       end              
    end   
    
    val = lins / ltot;
end