function [ animals_trajectories_map,n ] = friedman_test( animals_trajectories_map )
%FIREDMAN_TEST takes two animal groups and makes them equal
%Note: not in use. Currently the user specifies which animals to exclude

   [~,n1] = size(animals_trajectories_map{1,1});
   [~,n2] = size(animals_trajectories_map{1,2});
   if n1~=n2
       n = min(n1,n2);
       animals_trajectories_map{1,1} = animals_trajectories_map{1,1}(:,n);
       animals_trajectories_map{1,2} = animals_trajectories_map{1,2}(:,n);
   else
       n = n1;
   end 

end

