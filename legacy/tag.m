classdef tag
    %TAG Groups together some commmon attributes of trajectories
    properties(GetAccess = 'public', SetAccess = 'protected')
        abbreviation = '';
        description = '';
        type = '';
        parent = '';
        score = 0; % used to sort tags according to "goodness" of the strategy
        weight = 1; % used to give priority to some classes when mapping strategies to trajectories
        sub_tags = {};
    end
    
    methods
        %% constructor        
        function obj = tag(a, d, t, sc, st, w)   
            obj.abbreviation = a;
            obj.description = d;
            obj.type = t;
            if nargin < 4
        		obj.score = 0;
            else
                obj.score = sc;
            end
            if nargin < 5 || isempty(st)
                % assume that classs tag == abbreviation
                obj.sub_tags = {a};
            else
                obj.sub_tags = st;
            end
            if nargin < 6
                obj.weight = 1;
            else
                obj.weight = w;
            end
        end             
        
        function res = matches(obj, abbrev)
            res = ~isempty(find(arrayfun( @(t) strcmp(abbrev, t), obj.sub_tags), 1));
        end
    end        
    
    methods(Static)
        function combined = combine_tags(tags)
            abbrev = {tags(1).abbreviation};
            full_abbrev = tags(1).abbreviation;
            desc = tags(1).description;
            tot_sc = tags(1).score;
            w = tags(1).weight;
            for i = 2:length(tags)
                abbrev = [abbrev, tags(i).abbreviation];                
                full_abbrev = sprintf('%s/%s', full_abbrev, tags(i).abbreviation);
                desc = sprintf('%s / %s', desc, tags(i).description);
                tot_sc = tot_sc + tags(i).score;
                w = w + tags(i).weight;
            end            
            combined = tag(full_abbrev, desc, tags(1).type, tot_sc, abbrev, w/length(tags));
        end
        
        function res = tag_position(tags, abbrev)
            pos = find(arrayfun( @(t) t.matches(abbrev), tags));
            if ~isempty(pos)
                res = pos(1);
            else
                res = 0;
            end            
        end                
        
        % constructs a mapping of an array of tags (source) to another
        % array of tags (target)
        function res = mapping(target, source)
            res = zeros(1, length(source));
            for i = 1:length(source)
                for j = 1:length(target)
                    if target(j).matches(source(i).abbreviation)
                        res(i) = j;
                        break;
                    end                    
                end
            end
        end
    end
end
