function preprocess(data)
    %% interpolation
    % Get duration
    initYear = data.year(1);
    endYear = data.year(1);
    initMonth = data.Month(1);
    endMonth = data.Month(1);
    initDay = data.Day(1);
    endDay = data.Day(1);
    
    datetime([data.year(1),  data.Month(1), data.Day(1)])
    
    
    
    initYear - endYear
    days = sum(emoday(initYear, initMonth:12))+...
                sum(emoday(initYear+1, initMonth:12));
    

    quarter*hour*day
    
    
    
    for year = initYear:endYear
        for month = initMonth:endMonth
            for day = initDay:endDay
                fullTable.Year(1) = year; 
            
            end
        end
    end
            
            fullTable.BuildingIndex(1) = data.BuildingIndex(1);
        fullTable.year(1) = data.BuildingIndex(1);
        fullTable.BuildingIndex = data.BuildingIndex(1);
        fullTable.BuildingIndex = data.BuildingIndex(1);
        fullTable.BuildingIndex = data.BuildingIndex(1);
    


end