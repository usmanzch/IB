clear; close all; clc;
%--------------------------------------------------------------------------
% startdate = floor(now)-1;
% enddate   = now;
%--------------------------------------------------------------------------
ib = ibtws('',7497);
tickers = {'PG', 	'CRM', 	'AAPL', 	'MSFT'}	
nTickers = size(tickers,2);

ibContract = ib.Handle.createContract;
ibContract.symbol = 'AAPL';
ibContract.secType = 'STK';
ibContract.exchange = 'SMART/ARCA';
ibContract.currency = 'USD';


barsize = '5 mins';
ticktype = '';
tradehours = 1;

tic

dataLimit = 5000
for k = 1:dataLimit
    
    startdate = floor(now)-k;
    enddate   = now-k;
    
    d(k) = timeseries(ib,ibContract,startdate,enddate,barsize,ticktype,tradehours);
    dates(k) = d(:,1);
    nDates(k) = size(dates,1);
    
    for ticker = 1: nTickers;
        
        ibContract = ib.Handle.createContract;
        ibContract.symbol = tickers{ticker};
        ibContract.secType = 'STK';
        ibContract.exchange = 'SMART/ARCA';
        ibContract.currency = 'USD';
        
        barsize = '5 mins';
        ticktype = '';
        tradehours = 1;
        d = timeseries(ib,ibContract,startdate,enddate,barsize,ticktype,tradehours);
        
        Data_Open(:,ticker)  =  d(1:end,2);
        Data_Close(:,ticker) =  d(1:end,5);
        Data_High(:,ticker)  =  d(1:end,3);
        Data_Low(:,ticker)   =  d(1:end,4);
        
        if mod(ticker,55) == 0;
            pause(600)
        end
    end
end
close(ib)