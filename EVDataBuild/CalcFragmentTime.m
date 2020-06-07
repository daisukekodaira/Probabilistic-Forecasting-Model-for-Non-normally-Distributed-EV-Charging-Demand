% Cut out fraction 
% ex) StartTime 23:55 -> StartTime 24:00  (5min is cut out)
%       Calculate the amount of energy during cut out "5min" 

function [energyAmount, modifiedStartTime, modifiedEndTime]  = calcFragmentTime(startTime, endTime, oneMinutUsage)
    sixtyMatrix = ones(size(startTime,1),1)*60;
        
    % StartTIme
    residueFromSixty = sixtyMatrix - minute(startTime);
    residue = residueFromSixty;
    for i = 1:size(residueFromSixty,1)
        while residue(i) - 15 > 0
            residue(i) = residue(i) - 15;
        end
        energyAmount(i,1) = residue(i).*oneMinutUsage(i);
    end
    modifiedStartTime = startTime + minutes(residue);
        
    % EndTime
    residue = minute(endTime);    
    for i = 1:size(residue,1)
        while residue(i) - 15 > 0
            residue(i) = residue(i) - 15;
        end
        energyAmount(i,2) = residue(i).*oneMinutUsage(i);
    end
    modifiedEndTime = endTime - minutes(residue);
    
end