function NN_training(LongTermpastData,path)
    %% PastData
    PastData_ANN = LongTermpastData(1:(end-96*7),:);    % PastData load
    PastData_ANN(~any(PastData_ANN(:,13),2),:) = [];    % if there is 0 value in generation column -> delete
    [m_PastData_ANN, ~] = size(PastData_ANN);  
    %% set featur
    % P0(hour+quater), P1(Humidity), P2(WindSpeed),  P3(Temperature), P4(cloud),P5(rain), P6(solarirradiation)
    R=corrcoef(PastData_ANN(:,:));
    k=1;m=1;
    for i=1:size(R,1)
        if abs(R(end-1,i))>0.25 && i< size(R,2)-1
            predictor_sun(k)=i;
            k=k+1;
        end
        if abs(R(end,i))>0.25 && i<size(R,2)
            predictor_ger(m)=i;
            m=m+1;
        end
    end
    feature1 =[5 predictor_sun];
    feature2 =[5 predictor_ger];

    PastData_ANN(:,5)=PastData_ANN(:,5)+PastData_ANN(:,6)*0.25;
    %% Train solar model
    for i_loop = 1:3
        x_solar_ANN = transpose(PastData_ANN(1:m_PastData_ANN,feature1)); % input(feature)
        t_solar_ANN = transpose(PastData_ANN(1:m_PastData_ANN,12)); % target
        % Create and display the network
        net_solar_ANN = fitnet([20,20,20,15],'trainscg');
        net_solar_ANN.trainParam.showWindow = false;
        net_solar_ANN = train(net_solar_ANN,x_solar_ANN,t_solar_ANN); % Train the network using the data in x and t
        net_solar_ANN_loop{i_loop} = net_solar_ANN;             % save result
    end
    %% Train PV model
    for i_loop = 1:3
        trainDay_ANN =m_PastData_ANN;
        x_PV_ANN = transpose(PastData_ANN(1:trainDay_ANN,feature2)); % input(feature)
        t_PV_ANN = transpose(PastData_ANN(1:trainDay_ANN,13)); % target
        % Create and display the network
        net_PV_ANN = fitnet([20,20,20,15],'trainscg');
        net_PV_ANN.trainParam.showWindow = false;
        net_PV_ANN = train(net_PV_ANN,x_PV_ANN,t_PV_ANN); % Train the network using the data in x and t
        net_PV_ANN_loop{i_loop} = net_PV_ANN;             % save result
    end
    %% save result mat file
    clearvars input;
    clearvars shortTermPastData;
    building_num = num2str(LongTermpastData(2,1));
    save_name = '\PV_fitnet_ANN_';
    save_name = strcat(path,save_name,building_num,'.mat');
    clearvars path;
    save(save_name,'net_solar_ANN_loop','feature1','net_PV_ANN_loop','feature2');
end
