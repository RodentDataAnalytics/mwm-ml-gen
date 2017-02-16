function tags = tags_list(varargin)
%% TAGS_LIST contains a list of all the available tags

% DO NOT MODIFY NEXT LINE %
TAG_0 = {'UD', 'undefined', 0, 0};

%% Available Tags %%
% Format: {'abbreviation', 'description', score, weight}
% score: used to sort tags according to "goodness" of the strategy
% weight: used to give priority to some classes when mapping strategies to trajectories
% Tags with no score or weight will be excluded from the clustering process
TAG_1 = {'TT', 'thigmotaxis', 1, 1};
TAG_2 = {'IC', 'incursion', 2, 1};
TAG_3 = {'SC', 'scanning', 3, 1};
TAG_4 = {'FS', 'focused search', 4, 10};
TAG_5 = {'CR', 'chaining response', 5, 10};
TAG_6 = {'SO', 'self orienting', 6, 10};
TAG_7 = {'SS', 'scanning surroundings', 7, 1};
TAG_8 = {'ST', 'target scanning', 8, 10};
%TAG_9 = {'DF', 'direct finding'};
%TAG_10 = {'AT', 'approaching target'};
% more user defined tags...

%tags = {TAG_0,TAG_1,TAG_2,TAG_3,TAG_4,TAG_5,TAG_6,TAG_7,TAG_8,TAG_9,TAG_10};
tags = {TAG_0,TAG_1,TAG_2,TAG_3,TAG_4,TAG_5,TAG_6,TAG_7,TAG_8};

if ~isempty(varargin)
    TAG_1 = {'DF', 'direct finding', 1, 1};
    TAG_2 = {'AT', 'approaching target', 2, 1};
    TAG_3 = {'TT', 'thigmotaxis', 3, 1};
    TAG_4 = {'IC', 'incursion', 4, 1};
    TAG_5 = {'SC', 'scanning', 5, 1};
    TAG_6 = {'SO', 'self orienting', 6, 10};
    TAG_7 = {'ST', 'target scanning', 7, 10};
    tags = {TAG_1,TAG_2,TAG_3,TAG_4,TAG_5,TAG_6,TAG_7};
end

end

