%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date: 12th Dec 2018
% Editor: Daisuke Kodaira
% e-mail: daisuke.kodaira03@gmail.com
% Description for this code:
%   Convert characters in original.csv files as "EVdata.csv" to numbers.
%   original csv files can be obtained here: https://dundeecity.l3.ckan.io/dataset/ev-charging-data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
% Read given csv files
filename1 = 'EVdata.csv';
opts = detectImportOptions(filename1);
T = readtable(filename1,opts); % read input csv file
siteNum = zeros(size(T.Site,1),1);
groupNum = zeros(size(T.Group,1),1);
modelNum = zeros(size(T.Model,1),1);
num = 1;
% Site
for i = 1:size(T.Site,1)
    if i == 1
        siteNum(i,1) = num;
        siteList(1,1) = convertCharsToStrings(char(T.Site(i)));
        siteList(1,2) = num;
    else
        for j = 1:size(siteList,1)
            if convertCharsToStrings(char(T.Site(i))) == siteList(j,1)
                 siteNum(i,1) = siteList(j,2);
                 break
            end
        end
    end
    if siteNum(i,1) == 0
        num = num +1;
        siteList(end+1,1) = convertCharsToStrings(char(T.Site(i)));
        siteList(end,2) = num;
        siteNum(i,1) = siteList(end,2);
    end
end

% Group
num = 1;
for i = 1:size(T.Group,1)
    if i == 1
        groupNum(i,1) = num;
        groupList(1,1) = convertCharsToStrings(char(T.Group(i)));
        groupList(1,2) = num;
    else
        for j = 1:size(groupList,1)
            if convertCharsToStrings(char(T.Group(i))) == groupList(j,1)
                 groupNum(i,1) = groupList(j,2);
                 break
            end
        end
    end
    if groupNum(i,1) == 0
        num = num +1;
        groupList(end+1,1) = convertCharsToStrings(char(T.Group(i)));
        groupList(end,2) = num;
        groupNum(i,1) = groupList(end,2);
    end
end

% Model
num = 1;
for i = 1:size(T.Model,1)
    if i == 1
        modelNum(i,1) = num;
        modelList(1,1) = convertCharsToStrings(char(T.Model(i)));
        modelList(1,2) = num;
    else
        for j = 1:size(modelList,1)
            if convertCharsToStrings(char(T.Model(i))) == modelList(j,1)
                 modelNum(i,1) = modelList(j,2);
                 break
            end
        end
    end
    if modelNum(i,1) == 0
        num = num +1;
        modelList(end+1,1) = convertCharsToStrings(char(T.Model(i)));
        modelList(end,2) = num;
        modelNum(i,1) = modelList(end,2);
    end
end

output = [siteNum groupNum modelNum];
csvwrite('myFile.csv',output);