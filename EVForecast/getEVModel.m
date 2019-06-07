% ---------------------------------------------------------------------------
% EV prediction: Foecasting algorithm 
% 6th March,2019 Updated by Daisuke Kodaira 
% Contact: daisuke.kodaira03@gmail.com
%
% function flag = demandForecast(shortTermPastData, ForecastData, ResultData)
%     flag =1 ; if operation is completed successfully
%     flag = -1; if operation fails.
%     This function depends on demandModel.mat. If these files are not found return -1.
%     The output of the function is "ResultData.csv"
% ----------------------------------------------------------------------------

function flag = getEVModel(shortTermPastData, ForecastData, ResultData)
    tic;
    
    %% parameters
    ci_percentage = 0.05; % 0.05 = 95% it must be between 0 to 1

    %% Load data
    if strcmp(shortTermPastData, 'NULL') == 0 || strcmp(ForecastData, 'NULL') == 0
        shortPast = csvread(shortTermPastData,1,0);
        predictors = csvread(ForecastData,1,0);
        Resultfile = ResultData;
    else
        flag = -1;
        return
    end       

    %% Load .mat files from give path of "shortTermPastData"
    filepath = fileparts(shortTermPastData);
    buildingIndex = shortPast(1,1);
    
    %% Error recognition: Check mat files exist
    name1 = [filepath, '\', 'EVmodel_', num2str(buildingIndex), '.mat'];
    name2 = [filepath, '\', 'EnergyTransErrDist_', num2str(buildingIndex), '.mat'];
    name3 = [filepath, '\', 'SOCErrDist_', num2str(buildingIndex), '.mat'];
    name4 = [filepath, '\', 'EVpsoCoeff_', num2str(buildingIndex), '.mat'];
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
        matname = fullfile(filepath, [name(i).string extention]);
        load(matname);
    end
    
    %% Get individual prediction for test data
    [PredEnergyTrans_kmeans(:,1), PredSOC_kmeans(:,1)]  = kmeansEV_Forecast(predictors, filepath);
    %     [PredEnergyTrans_Valid(1).data(:,1), PredSOC_Valid(1).data(:,1)]  = NeuralNetwork_Forecast(predictors, path);
    PredEnergyTrans(1).data(:,1) =  PredEnergyTrans_kmeans(:,1);
    PredSOC(1).data(:,1) =  PredSOC_kmeans(:,1);
    
    %% Get combined prediction result with weight for each algorithm
    for i = 1:size(PredEnergyTrans,1)
        if i == 1
            DetermPredEnergyTrans = coeff(i).*PredEnergyTrans(i).data;
            DetermPredSOC = coeff(i).*PredSOC(i).data;
        else
            DetermPredEnergyTrans = DetermPredEnergyTrans + coeff(i).*PredEnergyTrans(i).data;
            DetermPredSOC = DetermPredSOC + coeff(i).*PredSOC(i).data;  
        end
    end
    
    %% Generate Result file    
    % Headers for output file
    hedder = {'BuildingIndex','CustomerID', 'Year', 'Month', 'Day', 'Hour', 'Quarter', 'SOCMean', 'SOCCIMin', 'SOCCIMax', ...
                      'EVDemandMean', 'DemandCIMin', 'DemandCIMax', 'CILevel'};
    fid = fopen(Resultfile,'wt');
    fprintf(fid,'%s,',hedder{:});
    fprintf(fid,'\n');
    
    % Make distribution of prediction
    % Note: UnqcustomerID means unique customer IDs in past data set. 
    %           Each unique customer ID has each histogram composed of error records derived from past data. 
    UnqcustomerID(:,1) = extractfield(EnergyTransErrDist,'customerID'); % extract unique IDs
    for i = 1:size(UnqcustomerID,1) % make a loop for the number of IDs (the number of histograms is equal to the number of IDs)
        probPredEnergyTrans(i,1).pred = NaN;    % initialize with NaN
        probPredEnergyTrans(i,1).customerID = UnqcustomerID(i); % put customerIDs
        probPredSOC(i,1).pred = NaN;
        probPredSOC(i,1).customerID = UnqcustomerID(i);
    end
    % Compose error Distribution
    for i = 1:size(DetermPredEnergyTrans,1)
        idx = find(UnqcustomerID==predictors(i,2)); % get the index of ID corresponding to ID in given forecasting files. "predictors(:,2)" stores customer IDs.
        if isnan(probPredEnergyTrans(idx).pred) == 1    % If the customer ID doesn't have predicted record, add as new record
            probPredEnergyTrans(idx).pred = DetermPredEnergyTrans(i) + EnergyTransErrDist(idx).err;
            probPredSOC(idx).pred = DetermPredSOC(i) + SOCErrDist(idx).err;
            probPredSOC(idx).pred = max(probPredSOC(idx).pred, 0);    % all records in SOC must be bigger than zero
        else  % If the customer ID has some predicted records, apend the new records to existing records
            probPredEnergyTrans(idx).pred = [probPredEnergyTrans(idx).pred; DetermPredEnergyTrans(i) + EnergyTransErrDist(idx).err];
            probPredSOC(idx).pred = [probPredSOC(idx).pred; DetermPredSOC(i) + SOCErrDist(idx).err];
            probPredSOC(idx).pred = max(probPredSOC(idx).pred, 0);    % all records in SOC must be bigger than zero
        end
        % %         for debugging --------------------------------------------------------------------------
        %                 h = histogram(probPredEnergyTrans(:,i), 'Normalization','probability');
        %                 h.NumBins = 10;
        % %         for debugging -------------------------------------------------------------------------------------
    end    
    % Make duplicated records
    % Note: In case that one customer ID has only one records, duplicated recored
    %           is generated to leverage "mean" function in latter part
    for i = 1:size(probPredEnergyTrans,1) 
        if size(probPredEnergyTrans(i).pred, 1) == 1 && isnan(probPredEnergyTrans(i).pred) == 0 
            probPredEnergyTrans(i).pred = [probPredEnergyTrans(i).pred; probPredEnergyTrans(i).pred];
            probPredSOC(i).pred = [probPredSOC(i).pred; probPredSOC(i).pred];
        end
        % Get mean value of Probabilistic load prediction
        probPredEnergyTrans(i).mean = mean(probPredEnergyTrans(i).pred);
        probPredSOC(i).mean = mean(probPredSOC(i).pred);
    end
    % Get Prediction Interval
    [probPredEnergyTrans] = getPI(probPredEnergyTrans, ci_percentage);
    [probPredSOC] = getPI(probPredSOC, ci_percentage);
    % Make matrix to be written in "ResultData.csv"
    for i = 1:size(predictors,1)
        idx = find(UnqcustomerID==predictors(i,2));
        ETPImin(i,1) =  probPredEnergyTrans(idx).PImin;
        ETPImax(i,1) = probPredEnergyTrans(idx).PImax;
        SOCPImin(i,1) =  probPredSOC(idx).PImin;
        SOCPImax(i,1) = probPredSOC(idx).PImax;
        ETmean(i,1) =  probPredEnergyTrans(idx).mean;
        SOCmean(i,1) =  probPredSOC(idx).mean;
    end
    result = [predictors(:,1:7)  SOCmean SOCPImin SOCPImax ETmean ETPImin ETPImax... 
                   100*(1-ci_percentage)*ones(size(DetermPredEnergyTrans,1),1)];
    fprintf(fid,['%d,', '%d,', '%04d,', '%02d,', '%02d,', '%2d,','%1d,', '%f,', '%f,', '%f,', '%f,', '%f,', '%f,','%d', '\n'], result');
    fclose(fid);
    % for debugging --------------------------------------------------------
    observed = csvread('Target.csv');
    EnergyTransCI =  [EnergyTransCIMin, EnergyTransCIMax];
    SOCCI =  [SOCCIMin, SOCCIMax];
    graph_desc(1:size(predictors,1), DetermPredEnergyTrans, observed(1,:), EnergyTransCI, 'EnergyTrans', ci_percentage); % EnergyTrans
    graph_desc(1:size(predictors,1), DetermPredSOC, observed(2,:), SOCCI, 'SOC', ci_percentage); % SOC
    % Cover Rate of PI
    count = 0;
    for i = 1:size(observed,1)
        if (L_boundary(i)<=observed(i)) && (observed(i)<=U_boundary(i))
            count = count+1;
        end
    end
    PICoverRate = 100*count/size(observed,1);
    MAPE(1) = mean(abs(yDetermPred - observed)*100./observed); % combined
    MAPE(2) = mean(abs(predicted_load(1).data - observed)*100./observed); % k-means
    disp(['PI cover rate is ',num2str(PICoverRate), '[%]/', num2str(100*(1-ci_percentage)), '[%]'])
    disp(['MAPE of demand mean: ', num2str(MAPE(1)), '[%]'])
    disp(['MAPE of kmeans: ', num2str(MAPE(2)), '[%]'])
    % for debugging --------------------------------------------------------------------- 
    
    flag = 1;
    toc;
end
