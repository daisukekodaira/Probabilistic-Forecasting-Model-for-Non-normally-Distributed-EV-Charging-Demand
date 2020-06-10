
function readMatFileData(allRecords, filepath)

    %% Load .mat files from give path of "shortTermPastData"
    folderpath = fileparts(filepath);
    buildingIndex = allRecords(1,1);

    %% Error recognition: Check mat files exist
    name1 = [folderpath, '\', 'EVmodel_', num2str(buildingIndex), '.mat'];
    name2 = [folderpath, '\', 'EnergyTransErrDist_', num2str(buildingIndex), '.mat'];
    name3 = [folderpath, '\', 'SOCErrDist_', num2str(buildingIndex), '.mat'];
    name4 = [folderpath, '\', 'EVpsoCoeff_', num2str(buildingIndex), '.mat'];
    if exist(name1) == 0 || exist(name2) == 0 || exist(name3) == 0 || exist(name4) == 0
        flag = -1;
        return
    end

    %% Load mat files
    s(1).fname = 'EVmodel_';
    s(2).fname = 'EnergyTransErrDist_';
    s(3).fname = 'SOCErrDist_';
    s(4).fname = 'EVpsoCoeff_';
    s(5).fname = num2str(buildingIndex);    
    extention='.mat';
    for i = 1:size(s,2)-1
        Name(i).string = strcat(s(i).fname, s(end).fname);
        matname = fullfile(folderpath, [Name(i).string extention]);
        load(matname)
    end
    global c_EnergyTrans
end