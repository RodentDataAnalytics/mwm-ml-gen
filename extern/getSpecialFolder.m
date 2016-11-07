% Code from http://uk.mathworks.com/help/matlab/matlab_external/read-special-system-folder-path.html

function result = getSpecialFolder(arg)
% Returns the special system folders such as "Desktop", "MyMusic" etc.
% arg can be any one of the enum element mentioned in this link
% http://msdn.microsoft.com/en-us/library/
% system.environment.specialfolder.aspx
% e.g. 
%       >> getSpecialFolder('Desktop')
%
%       ans = 
%       C:\Users\jsmith\Desktop
 
% Get the type of SpecialFolder enum, this is a nested enum type.
specialFolderType = System.Type.GetType(...
    'System.Environment+SpecialFolder');
% Get a list of all SpecialFolder enum values 
folders = System.Enum.GetValues(specialFolderType);
enumArg = [];
 
% Find the matching enum value requested by the user
for i = 1:folders.Length
    if (strcmp(char(folders(i)), arg))
        enumArg = folders(i);
    break
    end
end
 
% Validate
if(isempty(enumArg))
    error('Invalid Argument')
end
 
% Call GetFolderPath method and return the result
result = System.Environment.GetFolderPath(enumArg);
end