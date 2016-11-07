function save_configs(table)
%SAVE_CONFIGS saves new configs to configs.txt

    if ~isdeployed
        path = fullfile(pwd,'configs','figure','configs.txt');
        writetable(table,path,'WriteVariableNames',0);
    else
        path = fullfile(ctfroot,'configs','figure','configs.txt');
        writetable(table,path,'WriteVariableNames',0);
    end

end