function getEVForecasting(filepath, ResultfileName)
    %% Load EV records
    allRecords = csvread(filepath,1,0);
    predictors = 1:8;   % From 'Building' to 'P2(Holiday)'
        
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
        name(i).string = strcat(s(i).fname, s(end).fname);
        matname = fullfile(folderpath, [name(i).string extention]);
        load(matname);
    end

    %% Repeated Forecasting 
    % parameters
    % FirstRecord; the first day for the forecasting. 
    FirstRecord.year = 2018;
    FirstRecord.month = 8;
    FirstRecord.day  = 24;
    % alpha for Prediction Interval (confidence level)
    ci_percentage = 0.05; % 0.05 = 95% it must be between 0 to 1
    
    % Get data set (shortTermPastData, forecastData, TargetData) for each
    % day to be forecasted
    DayilyForecastData = createForecastDataSet(allRecords, FirstRecord.year, FirstRecord.month, FirstRecord.day);
    
    % Get the number of days in the forecast data
    days = size(DayilyForecastData,2);
    days = 1;
    % Get PI and Mean value
    for day = 1:days
        % 'getEVModel' returnes 
        % - forecastResult.Energy
        % - forecastResult.SOC'
        [forecastResult(day)] = getEVModel(DayilyForecastData(day).shortTerm, ...
                                                                  DayilyForecastData(day).predictors, ...
                                                                  folderpath);
        % Display the process for a user
        p = round(day*100/days,1);
        X = [num2str(p), '%'];
        disp(['Processing...Completed  ' X]);
    end
    
    %% Generate Result file    
    % Compose the output data matrix
    for day = 1:days
        if day == 1
            outputmatrix = [DayilyForecastData(day).predictors ...
                                       forecastResult(day).SOC ...
                                       forecastResult(day).Energy ...
                                       DayilyForecastData(day).target];
        else
            outputmatrix = [outputmatrix; ...
                                       DayilyForecastData(day).predictors ...
                                       forecastResult(day).SOC ... 
                                       forecastResult(day).Energy ...
                                       DayilyForecastData(day).target];
        end
    end
    % Create table to write it down on CSV file
    T = array2table(outputmatrix, ...
                              'VariableNames', ...
                              {'BuildingIndex', 'Year', 'Month', 'Day', 'Hour', 'Quarter','DayInWeek','HolidayOrNot', ...
                                'SOCmean', 'SOCPImin', 'SOCPImax', ...
                                'EVDemandmean', 'EVDemandPImin', 'EVDemandPImax', ...
                                'TargetEVDemand', 'TargetSOC'});
    % Write the result table on the CSV file
    writetable(T, ResultfileName);
    
    % for debugging -----------------------------------------------------------------------------------------
    display_result('EnergyTrans', T.EVDemandmean, T.EVDemandPImin, T.EVDemandPImax, T.TargetEVDemand, ci_percentage);
    display_result('SOC', T.SOCmean, T.SOCPImin, T.SOCPImax, T.TargetSOC, ci_percentage);
    % for debugging ---------------------------------------------------------------------     
end