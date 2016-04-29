function home = home_directory()
    if ispc
        home = [getenv('APPDATA') '\'];
    else
        home = [getenv('HOME') '/'];
    end
end