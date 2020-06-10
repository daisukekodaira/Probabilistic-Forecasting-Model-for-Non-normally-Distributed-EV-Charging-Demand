% Devide the all records into long, short and forecast

function ForecastDataSet = createForecastDataSet(allRecords, year, month, day)
    % Get 'datetime' style
    allRecordDatetime = datetime(allRecords(:,2:4));
    initialDay = datetime([year month day]);
    lastDay = allRecordDatetime(end);
    day = initialDay;
    i = 1;
    while day <= lastDay
        % pick 1 week data
        ForecastDataSet(i).shortTerm = allRecords([find(datenum(day-8)<datenum(allRecordDatetime) &...
                                                                                      datenum(allRecordDatetime)<datenum(day))], :);
        % pick a day to be forecasted
        ForecastDataSet(i).predictors = allRecords(find(datenum(allRecordDatetime) == datenum(day)), 1:8); % predictors
        ForecastDataSet(i).target = allRecords(find(datenum(allRecordDatetime) == datenum(day)), 9:10); % Energy, SOC
        day = day+1;
        i = i+1;
    end
end