function [tickers,prices,ExitSignal]= ReadGooglePrices()
[num, txt, raw]      = xlsread('C:\Users\Trader\Desktop\GetData\Data\Stocks\TITANIC_FAST\GoogleLast.xlsx');

tickers             = txt(1,2:end);
lastPrices_close    = num(5,:); % close of the preceeding day
lastPrices_open     = num(1,:); %1 for last traded price, 2:open , 3:high, 4:low

[prices.Open,prices.Close,prices.High,prices.Low] = deal([lastPrices_close;lastPrices_open]);


%Case 1: Prices have not updated and open and close are matching
matchingNum = 0;
for x = 1:size (prices.Open,2)
    if matchingNum > 10;
        disp('Open and Close are the same for too many stocks, program terminated.');
        ExitSignal = 1;
        return 
    end
   if prices.Open(1,x) ==  prices.Open(2,x)
       matchingNum = matchingNum + 1;
   end
end

%Case 2: Prices did not update properly, too many nans
nanCheck = isnan(prices.Open);

nanCount = sum(nanCheck,2);

if (nanCount(1) ~= 0);
   warning('Missing %i prices for last close.',nanCount(1) );
end
if (nanCount(2) ~= 0);
   warning('Missing %i prices for todays open',nanCount(2) );
end

for x=1:size(nanCheck,2);
    if (nanCheck(1,x) == 0 && nanCheck(2,x) == 1);
        warning('Ticker: %s missing Open.',tickers{1,x} );
    elseif  (nanCheck(1,x) ==1 && nanCheck(2,x) == 0);
        warning('Ticker: %s missing Close.',tickers{1,x} );
    elseif (nanCheck(1,x) ==1 && nanCheck(2,x) == 1);
           warning('Ticker: %s missing Open & Close.',tickers{1,x} );
    end
    
end

if nanCount(1) > 10 || nanCount(2) > 10;
    disp('Too many NaN in Open and Close, program terminated.');
    ExitSignal = 1;
    return 
end

ExitSignal = 0;

end