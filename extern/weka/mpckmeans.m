function [ distr, centroids ] = mpckmeans( x, constr, k )
%MPCKMEANS MPCK clustering algorithm
%   x is the input data, 
%   constr is the constraint matrix 
%   k is the desired number of clusters
    import weka.clusterers.MPCKMeans;
    import weka.clusterers.InstancePair;
    import weka.core.metrics.*;
    import java.io.*;
    import java.util.*;
    import weka.core.*;

    d = size(x);
            
     % create attributes Cell Array
    attr = {};
    for i = 1:d(2)
        name = sprintf('feat%d', i);
        attr{i} = name; 
    end
    
    wInterface = WekaInterface();
    data = wInterface.WekaCreateInstances(x,'data',attr);
    
    % constraints 
    c = wInterface.WekaPrepareConstraints(constr);
    
    mpck = weka.clusterers.MPCKMeans();
    mpck.setTotalTrainWithLabels(data);    

    mpck.buildClusterer(c, data, data, k, data.numInstances())    
    
    distr = mpck.getClusterAssignments();
    distr = distr';
    centroids_inst = mpck.getClusterCentroids();
    centroids = zeros(k, d(2));
    for i = 1:k
        % don't forget - java indices are zero based!
        centroids(i, :) = centroids_inst.instance(i - 1).toDoubleArray();
    end
    centroids = centroids';
end