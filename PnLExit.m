function [order,ExitSignal] = PnLExit(ib,Offset,order,OrderType,AccountNumber)
    %close all active orders
    ib.Handle.reqGlobalCancel;
    
    pause(1.5)
    id = order ;
    %request current portfolio data
    portfolioData = portfolio(ib,AccountNumber);
    pause(1.5)
    %get current stock name and positions size
    portfolioSize = size(portfolioData.contract,1);
   
    portfolioTickers = cell(portfolioSize,1);
    for x = 1:portfolioSize
        portfolioTickers{x} = portfolioData.contract{x,1}.symbol;
    end

    portfolioPositions = portfolioData.position;
    
    %check if all positions have been liquidated
    allSoldCheck =sum(abs(cell2mat(portfolioPositions)));
    if allSoldCheck == 0;
        ExitSignal = 1;
    else
        ExitSignal = 0;
    end
    
    %generate exit SNAPS
    for x=1:portfolioSize;

       %skip stocks that don't have an allocation 
        if portfolioPositions{x,1} == 0 ;    
            continue;
        end

            %generate orders
            ibContract = ib.Handle.createContract;
            ibContract.symbol = portfolioTickers{x,1};
            ibContract.secType = 'STK';
            ibContract.exchange = 'SMART';
            ibContract.currency = 'USD';

            ibMktOrder = ib.Handle.createOrder;
            if sign(portfolioPositions{x,1}) == 1;
                action = 'SELL';
            elseif sign(portfolioPositions{x,1}) == -1;
                action = 'BUY';
            end
            ibMktOrder.action = action;
            quantity = abs(cell2mat(portfolioPositions(x,1)));
            ibMktOrder.totalQuantity = quantity;
            ibMktOrder.orderType = OrderType;
            ibMktOrder.auxPrice = Offset;

            %result stores information regarding the execution of the order
            result = createOrder(ib,ibContract,ibMktOrder,id);

            id = id+1;

    end

    order = id;

    
end