custom = -1.*ones(12,2);
k = 1;
for j = 1:27 %12
    for i = j:12:size(mfried,1) %27
        custom(k,:) = mfried(i,:);
        k = k+1;
    end
    friedman(custom,1,'off')
    k = 1;
end