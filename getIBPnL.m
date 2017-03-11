function[time,LivePnL] = getIBPnL(ib,AccountNumber)


    portfolioData = portfolio(ib,AccountNumber);
    
    
    unrealized = portfolioData.unrealizedPNL;
    realized = portfolioData.realizedPNL;
    
    unrealized = cell2mat(unrealized);
    realized = cell2mat(realized);
    
    LivePnL = sum(realized) + sum(unrealized);
     time = datetime('now');

end