function [ A, C ] = min_enclosing_ellipsoid( P, tol )
%MIN_ENCLOSING_ELLIPSOID Computes the minimum volume ellipsoid enclosing a
%set of N D-dimensional points P (which should be a vector of points)
%   based on the work by Moshtagh - "MINIMUM VOLUME ENCLOSING ELLIPSOIDS"
%   and the code provided here: http://stackoverflow.com/questions/1768197/bounding-ellipse/1768440#1768440    
    d = size(P, 1);   
    % Number of oints
    N = size(P, 2);

    % Add a row of 1s to the 2xN matrix P - so Q is 3xN now.
    Q = [P; ones(1,N)];

    % Initialize
    count = 1;
    err = 1;
    % u is an Nx1 vector where each element is 1/N
    u = (1/N) * ones(N,1);

    % Khachiyan Algorithm
    while err > tol    
        % Matrix multiplication: 
        X = Q*diag(u)*Q';        
        M = diag(Q' * inv(X) * Q);

        % Find the value and location of the maximum element in the vector M
        [maximum, j] = max(M);        

        % Calculate the step size for the ascent
        step_size = (maximum - d -1)/((d+1)*(maximum-1));

        % Calculate the new_u:        
        new_u = (1 - step_size)*u ;

        % Increment the jth element of new_u by step_size
        new_u(j) = new_u(j) + step_size;

        % Store the error by taking finding the square root of the SSD 
        % between new_u and u        
        err = norm(new_u - u);

        % Increment count and update u
        count = count + 1;
        u = new_u;
    end

    % Put the elements of the vector u into the diagonal of a matrix
    % U with the rest of the elements as 0
    U = diag(u);

    % Compute the A-matrix
    A = (1/d) * inv(P * U * P' - (P * u)*(P*u)' );
    
    % compute the center
    C = P * u;       
 end
