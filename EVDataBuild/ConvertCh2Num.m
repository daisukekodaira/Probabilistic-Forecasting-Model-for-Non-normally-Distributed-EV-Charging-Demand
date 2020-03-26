% Description for this code:
%   Convert characters in original.csv files as "EVdata.csv" to numbers.

function T = ConvertCh2Num(T)
    % Pick each column
    siteArray = zeros(size(T.Site,1),1);
    groupAaary = zeros(size(T.Group,1),1);
    modelArray = zeros(size(T.Model,1),1);
    num = 1;
    % Site
    for i = 1:size(T.Site,1)
        if i == 1
            siteArray(i,1) = num;
            siteList(1,1) = convertCharsToStrings(char(T.Site(i)));
            siteList(1,2) = num;
        else
            for j = 1:size(siteList,1)
                if convertCharsToStrings(char(T.Site(i))) == siteList(j,1)
                     siteArray(i,1) = siteList(j,2);
                     break
                end
            end
        end
        if siteArray(i,1) == 0
            num = num +1;
            siteList(end+1,1) = convertCharsToStrings(char(T.Site(i)));
            siteList(end,2) = num;
            siteArray(i,1) = siteList(end,2);
        end
    end

    % Group
    num = 1;
    for i = 1:size(T.Group,1)
        if i == 1
            groupAaary(i,1) = num;
            groupList(1,1) = convertCharsToStrings(char(T.Group(i)));
            groupList(1,2) = num;
        else
            for j = 1:size(groupList,1)
                if convertCharsToStrings(char(T.Group(i))) == groupList(j,1)
                     groupAaary(i,1) = groupList(j,2);
                     break
                end
            end
        end
        if groupAaary(i,1) == 0
            num = num +1;
            groupList(end+1,1) = convertCharsToStrings(char(T.Group(i)));
            groupList(end,2) = num;
            groupAaary(i,1) = groupList(end,2);
        end
    end

    % Model
    num = 1;
    for i = 1:size(T.Model,1)
        if i == 1
            modelArray(i,1) = num;
            modelList(1,1) = convertCharsToStrings(char(T.Model(i)));
            modelList(1,2) = num;
        else
            for j = 1:size(modelList,1)
                if convertCharsToStrings(char(T.Model(i))) == modelList(j,1)
                     modelArray(i,1) = modelList(j,2);
                     break
                end
            end
        end
        if modelArray(i,1) == 0
            num = num +1;
            modelList(end+1,1) = convertCharsToStrings(char(T.Model(i)));
            modelList(end,2) = num;
            modelArray(i,1) = modelList(end,2);
        end
    end
    T.Site = siteArray;
    T.Group = groupAaary;
    T.Model = modelArray;
end