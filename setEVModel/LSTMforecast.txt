function result_LSTM = PVset_LSTM_Forecast(input,path)
% PV prediction: LSTM Model Forecast algorithm
%% load .mat file
Forecastdata = input(:,[1:4 7:end-3]);
building_num = num2str(Forecastdata(2,1));
load_name = '\PV_LSTM_';
load_name = strcat(path,load_name,building_num,'.mat');
load(load_name,'-mat');
%% forecast solar
data1=Forecastdata(:,predictorscol1);
XTest1 =((data1 - meandata(predictorscol1))./sigdata(predictorscol1))';
solar_net = predictAndUpdateState(solar_net,XTrain1);
[solar_net,YPred_solar(:,1:48)] = predictAndUpdateState(solar_net,XTrain1(:,end-48+1:end));
numTimeStepsTest = size(XTest1,2);
for i = 1:numTimeStepsTest
    [solar_net,YPred_solar(:,i+48)] = predictAndUpdateState(solar_net,XTest1(:,i),'ExecutionEnvironment','auto');
end
Forecastdata(:,end+1)=YPred_solar(48+1:end)';
%% forecast pv
data2=Forecastdata(:,predictorscol2);
XTest2 =((data2 - meandata(predictorscol2))./sigdata(predictorscol2))';
pv_net = predictAndUpdateState(pv_net,XTrain2);
[pv_net,YPred(:,1:48)] = predictAndUpdateState(pv_net,XTrain2(:,end-48+1:end));
numTimeStepsTest = size(XTest2,2);
for i = 1:numTimeStepsTest
    [pv_net,YPred(:,i+48)] = predictAndUpdateState(pv_net,XTest2(:,i),'ExecutionEnvironment','auto');
end
result_LSTM = (sigdata(end).*YPred(48+1:end) + meandata(end))'; 
for i=1:size(result_LSTM,1)
    if result_LSTM(i)<0
        result_LSTM(i)=0;
    end
end