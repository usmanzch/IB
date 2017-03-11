function [Table,filename] = TradeAnalysis(Decision)

[~,~,raw] = xlsread('C:\Users\Trader\Desktop\DailyTrades\IB_TRADES.xlsx');
%delete column if nan found in ticker position
raw( cellfun( @(raw) isnumeric(raw) && isnan(raw), raw(:,3) ), :) = []; 

%flip table so first trade appear at the top
Table = flip(raw);

if isnan(Table{1,10})
    TransactionCost = cell2mat(Table(:,9));  
else
    TransactionCost = cell2mat(Table(:,10));
end

Table = Table(:,3:6);

%organize and clean data if stock bought or sold in chucks
for y =1:size(Table,1);
    for x=1:size(Table,1);
        if ( y == x );
            continue;
        end
        
        if (strcmp(Table{x,1}, Table{y,1}))
            if (strcmp(Table{x,2}, Table{y,2}))
                mktval_1 = Table{x,3}* Table{x,4};
                mktval_2 = Table{y,3}* Table{y,4};
                totalShares = Table{x,3}+Table{y,3};
                
                Table{y,3} =  totalShares;
                Table{y,4} = (mktval_1+mktval_2)/totalShares;
                 TransactionCost(y,1) = TransactionCost(y,1) + TransactionCost(x,1);
                 
                 TransactionCost(x,1) = 0;
                Table(x,:) = {0,0,0,0};
            end
        end
    end
end

% make all sold positions negative and establish market value of positions
for y =1:size(Table,1);
    
    if isequal(Table{y,2}, 'SLD')
        Table{y,3} = Table{y,3} * -1;
    end
    
    Table{y,6} = Table{y,3}* Table{y,4};
    
end

%this loops adds the market value of each transaction to get PnL (Trailing)
Table(1,7) = cell(1,1);
for y =1:size(Table,1);
    for x=1:size(Table,1);
        if ( y == x );
            continue;
        end
        
        if (strcmp(Table{x,1}, Table{y,1}))
            if (isempty(Table{y,7}));
                Table{y,7} = Table{x,6};
            else
                Table{y,7} =  Table{y,7} + Table{x,6};
            end
            
             TransactionCost(y,1) = TransactionCost(y,1) + TransactionCost(x,1);
                 
             TransactionCost(x,1) = 0;
            
            Table(x,:) = {0,0,0,0,0,0,0};  
        end
    end
end

%calculate PnL of each stock using Trailing(US$)
for y =1:size(Table,1);
    if strcmp(Table{y,2},'BOT')
        Table{y,8} = -1*(Table{y,6} + Table{y,7});
    elseif strcmp(Table{y,2},'SLD')
        Table{y,8} = -1*(Table{y,6} + Table{y,7}); 
    end
end

Table(cellfun(@(x) ~x(1),Table(:,1)),:) = []; %remove all zeros 
%clean all rows that have 0


Transactions = cell2mat(Table(:,8));
%get PnL for Trailing
PnL = sum(Transactions,1) - sum(TransactionCost,1);


%Everything below is now used to calulate PnL using fixed STOP
[num,txt,raw] = xlsread('C:\Users\Trader\Desktop\GetData\Data\Stocks\TITANIC_FAST\GoogleLast.xlsx');

tickers = raw(1,2:end);
last = raw(2,2:end);
high = raw(4,2:end);
low = raw(5,2:end);
openPrice = raw(3,2:end);
closePrice = raw(2,2:end);
for x=1:size(tickers,2)
   tickers{1,x} = strrep(tickers{1,x}, '.', ' ');
   tickers{1,x} = strrep(tickers{1,x}, '-', ' ');
end

for y=1:size(tickers,2);
     if isnan(tickers{1,y});
            tickers(:,y:end) = [];
        last(:,y:end) = [];
        high(:,y:end) = [];
        low(:,y:end) = [];
        break;
    end
end

%find prices of traded stocks from the google file
for y =1:size(Table,1)
    position = find(ismember(tickers,Table{y,1}) );
    Table{y,10} = high{position};
    Table{y,11} = low{position};
    Table{y,12} = last{position};
end

%calculate stp level and determine if the level was hit
for y =1:size(Table,1)
    if strcmp(Table{y,2},'BOT')
        Table{y,13} = Table{y,4} * (1-Decision.SL_Long);
        
        if Table{y,13} >= Table{y,11}
            Table{y,14} = 'HIT';
        end
    elseif strcmp(Table{y,2},'SLD')
        Table{y,13} = Table{y,4} * (1+Decision.SL_Short);
        
        if Table{y,13} <= Table{y,10}
            Table{y,14} = 'HIT';
        end 
    end
end

%get exit level using stop, if stop was not hit, use last price as exit
for y =1:size(Table,1)
    if strcmp(Table{y,14},'HIT')
        Table{y,15} = -1*(Table{y,3} * Table{y,13}) ;
    else 
        Table{y,15} = -1*(Table{y,12} * Table{y,3});
    end
end

%calculate PnL of each stock using fixed stop (US$)
for y =1:size(Table,1);
    if strcmp(Table{y,2},'BOT')
        Table{y,16} = -1*(Table{y,6} + Table{y,15});
    elseif strcmp(Table{y,2},'SLD')
        Table{y,16} = -1*(Table{y,6} + Table{y,15}); 
    end
end


for y =1:size(Table,1);
    Table{y,18} = Table{y,12} * -1*(Table{y,3});
    Table{y,19} = -1*(Table{y,18} + Table{y,6});
end

for y =1:size(Table,1);
    
    Table{y,6}= Table{y,6}*-1;
    Table{y,7}= Table{y,7}*-1;
    Table{y,15}= Table{y,15}*-1;
    Table{y,18}= Table{y,18}*-1;
    Table{y,5} = Table{y,7}/Table{y,3};
    Table{y,3} = abs(Table{y,3});
end

%clean 0 from transactioncost
TransactionCost = TransactionCost(TransactionCost~=0);

Table(:,9:end+1) = Table(:,8:end);
for y =1:size(Table,1);
    Table{y,8} = TransactionCost(y);
end
Transactions = cell2mat(Table(:,17));
PnL_Stop = sum(Transactions,1) - sum(TransactionCost,1);

Transactions = cell2mat(Table(:,20));
PnL_Raw = sum(Transactions,1) - sum(TransactionCost,1);

%----------------------------------------------------------------------
%calculate results 
% tickersTraded = Table(1:end,1);
% type = Table(1:end,2);
% quantityTraded = Table(1:end,3);
% 
% 
% table_backtest = cell(0,0);
% 
% 
% for x =1:size(tickersTraded,1)
%     position = find(ismember(tickers,tickersTraded{x})==1);
%     table_backtest(end+1,1) = openPrice(1,position);
%     table_backtest(end,2) = closePrice(1,position);
%     table_backtest{end,3} = closePrice{1,position}/openPrice{1,position} -1;
%     
%     if strcmp(type{x},'SLD')
%         table_backtest{x,3} =  table_backtest{x,3}*-1;
%     end
% end
% 
% 
% for x =1:size(tickersTraded,1)
%     if strcmp(type{x},'BOT')
%         table_backtest{x,4} = table_backtest{x,1} * quantityTraded{x} *-1;
%         table_backtest{x,5} = table_backtest{x,2} * quantityTraded{x};
%     end
%     if strcmp(type{x},'SLD')
%         table_backtest{x,4} = table_backtest{x,1} * quantityTraded{x};
%         table_backtest{x,5} = table_backtest{x,2} * quantityTraded{x} *-1;
%     end
%     table_backtest{x,6} = table_backtest{x,4} + table_backtest{x,5} ;
%     
% end
% mktval = [table_backtest{:,6}];
% EoD = sum(mktval) - sum(TransactionCost,1);
% 
% Table = [Table, Table(:,10) ,table_backtest];

%------------------------------------------------------------------------
Table{end+2,9} = PnL;
Table{end,17} = PnL_Stop;
Table{end,20} = PnL_Raw;
%Table{end,27} = EoD;

Title = {'Ticker','Type','Position','Entry Price','Exit Price','Entry Level','Exit Level (Trailing SL)', 'Comission',...
    'USD$ PnL (Trailing SL)', '' ,'High', 'Low','Last', 'Stop Level' , 'Hit?', 'Exit Level (Fixed SL)','USD$ PnL (Fixed SL)',...
    '','Exit Level (No Stop)','USD$ PnL (No Stop)' };

Table = [Title;Table];




date = datestr(datetime('now'));
date = strrep(date, ':', '_');
filename = strcat('C:\Users\Trader\Desktop\DailyTrades\','TradeAnalysis_',date,'.xlsx');

xlswrite(filename, Table,1)


end


