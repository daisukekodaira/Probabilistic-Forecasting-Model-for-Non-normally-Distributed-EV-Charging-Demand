function preprocess(data)
    %% interpolation
    % Get duration
    initYear = data.year(1);
    endYear = data.year(1);
    initMonth = data.Month(1);
    endMonth = data.Month(1);
    initDay = data.Day(1);
    endDay = data.Day(1);
    initialDateTime = datetime([data.year(1),  data.Month(1), data.Day(1), 0, 0, 0]);
    endDateTime = datetime([data.year(end),  data.Month(end), data.Day(end)]);
    days = day(initialDateTime) - day(endDateTime);
    steps = days*24*4;  % days*hours*quarters   

    for quarters = 1:4
        for hours = 1:24
            fullData.year = datetime()
    
    
    for year = initYear:endYear
        for month = initMonth(year):endMonth(year)
            for day = initDay(month):endDay(month)
                fullTable.Year(1) = year*ones(96,1); 
            
            end
        end
    end
            
            fullTable.BuildingIndex(1) = data.BuildingIndex(1);
        fullTable.year(1) = data.BuildingIndex(1);
        fullTable.BuildingIndex = data.BuildingIndex(1);
        fullTable.BuildingIndex = data.BuildingIndex(1);
        fullTable.BuildingIndex = data.BuildingIndex(1);
    


end