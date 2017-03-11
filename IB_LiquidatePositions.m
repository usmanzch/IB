% Liquidate all positions 
% Run this code only when IB connection open 
PnLTargetHit = 1;
TimeLimitHit = 1;

disp('Starting liquidation process...');
offset = 0.00; 
OrderType = 'SNAP MID';

while PnLTargetHit == 1 || TimeLimitHit == 1;
    
    if PnLTargetHit == 1;
        offset = 0;
    end
    
    [OrderID,ExitSignal] = PnLExit(ib,offset,OrderID,OrderType,AccountNumber);
    
    if ExitSignal == 1;
        disp('All positions have been liquidated...');
        break;
    end
    
    if PnLTargetHit == 1;
        pause(12)
    elseif TimeLimitHit == 1;
        pause(12)
    end
    
    if offset > 0.01
        offset = offset - 0.05;
    end
    
     c = clock;    hour = c(4);    minutes=c(5);
    
    if  hour >= 15 && minutes >=45 % 3:45
        OrderType = 'MKT';
    end
    
end


% after all positions are closed, write PnL (3min) realized during the day 
PnL_Date = date;
filelocation = strcat('C:\Users\Trader\Desktop\GetData\Data\PnL\',PnL_Date);

for x=1:size(PnL_History,1)
    PnL_History{x,1} = m2xdate(PnL_History{x,1});
end
xlswrite(filelocation,PnL_History,1,'A1')

disp('End of program...');

close(ib)

[status_getGoogle] = getGoogleLastPrice(); %update last prices using Google