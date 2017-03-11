function [PortfolioData] = getIBPortfolio(ib,AccountNumber)

p = portfolio(ib,AccountNumber);
nActiveStocks = size(p.contract,1); % stocks where we currently hold a position
symbol = cell(nActiveStocks,1);

for k = 1:nActiveStocks
    symbol{k,1} = p.contract{k,1}.symbol;
end

position    = p.position;
averageCost = p.averageCost;
marketVal   = p.marketValue;

%PortfolioData = [symbol, position, averageCost, marketVal]


% create table
PortfolioData      = cell(nActiveStocks,5);
PortfolioData(:,1) = symbol;
PortfolioData(:,2) = position;
PortfolioData(:,3) = averageCost;
PortfolioData(:,4) = marketVal;

%remove tickers with no 0 positions
PortfolioData = PortfolioData([PortfolioData{:,2}] ~= 0,:);

for x=1:size(PortfolioData,1);
    PortfolioData{x,5} = abs(PortfolioData{x,4});
end

PortfolioData = sortrows(PortfolioData,-5);
% titles = {'Ticker' 'Position' 'AvgPrice' 'Market Val' 'Abs Market Val'};
% PortfolioData = [titles; PortfolioData];
end