clear all; clc; close all;

 %% Read Input data
    % load a '.mat' file
    load EV_trainedLSTM_1;
    net = trainedLSTM_EnergyTrans;
    sequenceLength = size(x,2);
idxLayer = 2;

for i = 1:100
    features(:,i) = activations(net,x(:,i),idxLayer);
    [net, YPred(i)] = predictAndUpdateState(net,x(:,i));
end

features = cell2mat(features);
figure
heatmap(features(:,1:15));
xlabel("Time Step")
ylabel("Hidden Unit")
title("LSTM Activations")

disp('.... Done!');
