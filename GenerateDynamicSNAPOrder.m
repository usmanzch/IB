function [Table_Increment] = GenerateDynamicSNAPOrder(Table,SNAP_ID,ib,AccountNumber)

%delete all current Snap Mkt Orders
if ~isempty(SNAP_ID)
    for x=1:size(SNAP_ID,2)
        ib.Handle.cancelOrder(SNAP_ID(x));
    end
end
pause(2);

%get info from IB regarding current holdings
PortfolioData_Current = getIBPortfolio(ib,AccountNumber);

nTradedStocks = size(PortfolioData_Current,1);
nStocks = size(Table,1);

%get position lot from Table1 
for x =1:nTradedStocks
    for y = 1:nStocks
        z = strcmp(Table{y,3},  PortfolioData_Current{x,1});
        
        if z == 1;
            if sign(PortfolioData_Current{x,2}) == -1
                PortfolioData_Current{x,6} = -Table{y,2};
            else
                PortfolioData_Current{x,6} = Table{y,2};
            end
        end
    end
end


%calculate the difference (Table1 - PorfolioData_Current) & assign
%approprate trade signal in Table_Incerement
Table_Increment=cell(nTradedStocks,3);
for x = 1:nTradedStocks
    Table_Increment{x,1} = PortfolioData_Current{x,1};
    
    diff = PortfolioData_Current{x,6} - PortfolioData_Current{x,2};
    
    Table_Increment{x,2} = abs(diff);
    
    if sign(PortfolioData_Current{x,2}) == 1
        Table_Increment{x,3} =  'BUY';
    elseif sign(PortfolioData_Current{x,2}) == -1
        Table_Increment{x,3} =  'SELL';
    end

end


x = PortfolioData_Current(:,1);
y = Table(:,3);

bool = ismember(y,x);
pos=nTradedStocks+1;


for k = 2:size(bool,1) %jumping 1st row (title)
    if bool(k) == 0
        Table_Increment{pos,1} =  Table{k,3};
        Table_Increment{pos,2} =  Table{k,2};
        Table_Increment{pos,3} =  Table{k,1};        
        pos = pos+1;
    end
    
end



end
