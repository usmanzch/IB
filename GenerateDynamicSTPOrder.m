function [OrderID,STP_ID,STP_LIST] = GenerateDynamicSTPOrder(NextOrder,Decision,STP_ID,ib)

% Cancel current MIT orders in the market
if ~isempty(STP_ID)
    for x=1:size(STP_ID,2)
        ib.Handle.cancelOrder(STP_ID(x));
    end
end 
pause(2);

STP_ID = [];
STP_LIST = cell(0,0);


%get info from IB regarding current holdings
PortfolioData_Current = getIBPortfolio(ib);
nTradedStocks = size(PortfolioData_Current,1);

id = NextOrder;

%sending new MITs that match the holdings within the IB portfolio
for x=1:nTradedStocks;
    STP_LIST{end+1,1} = PortfolioData_Current{x,1};
    STP_LIST{end,2} = PortfolioData_Current{x,2};
    
    
    ibContract = ib.Handle.createContract;
    ibContract.symbol = PortfolioData_Current{x,1};
    ibContract.secType = 'STK';
    ibContract.exchange = 'SMART';
    ibContract.currency = 'USD';
    
    ibMktOrder = ib.Handle.createOrder;
    if sign(PortfolioData_Current{x,2}) == -1
        action = 'BUY';
        ibMktOrder.action = action;
        ibMktOrder.totalQuantity = abs(PortfolioData_Current{x,2});
        ibMktOrder.orderType = 'STP';
        ibMktOrder.auxPrice = round(PortfolioData_Current{x,3}*(1+Decision.SL_Short),2);
        
    elseif sign(PortfolioData_Current{x,2}) == 1
        action = 'SELL';
        ibMktOrder.action = action;
        ibMktOrder.totalQuantity = abs(PortfolioData_Current{x,2});
        ibMktOrder.orderType = 'STP';
        ibMktOrder.auxPrice = round(PortfolioData_Current{x,3}*(1-Decision.SL_Long),2);
    end
    
    %result stores information regarding execution of the order
    result = createOrder(ib,ibContract,ibMktOrder,id);
    STP_ID(end+1) = id;
    id = id +1;
    
end



OrderID = id;
end