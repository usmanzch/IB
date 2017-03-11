function [table] = getSlippage(ib,AccountNumber)

%Replace space with . before sending to python
% args = cell(0);
% for x=1:size(tradedTickers,2);
%     args{1,x} = strrep(tradedTickers{1,x},' ','.');
% end
% args = strjoin(tradedTickers);
% string = strcat('python C:\Users\Trader\Desktop\MR_Prod\pythonRequestData.py',{' '},args,' &');
% [status_ibRequest,output] = system(string{1,1});

p = portfolio(ib,AccountNumber);
pause(2);
table = cell(0);
for x =1 :size(p.contract,1)
    table{x,1} = p.contract{x,1}.symbol;
    table{x,1} = strrep(table{x,1},' ','.');
    table(x,2) = p.position(x,1);
    table(x,3) = p.averageCost(x,1);
end

table(cellfun(@(x) ~x,table(:,2)),:) = [];

[num,txt,raw] = xlsread('XLQ_RealTime.csv');
tickers   = raw(5:end,1);
midPrice = cell2mat(raw(5:end,4));

[~,pos] = ismember(table(:,1),tickers);

for x=1:size(pos,1)
    if pos(x) == 0
        continue;
    end
   table{x,4} = midPrice(pos(x));
   
   table{x,6} = table{x,4} - table{x,3};

   table{x,7} = table{x,6} * table{x,2};
   
end
    

slip = sum(cell2mat(table(:,7)));
table(end+1,7) = num2cell(slip);

slip = num2str(slip, '%1.2f');
fprintf('Slippage of: $%s for market entry.\n',slip);

Title = {'Tickers','Quantity', 'Price(Filled)', 'Prices(Allocation)', '', 'Slippage/Share', 'US$ Total Slippage'};

table = vertcat(Title,table);
filename = strcat('C:\Users\Trader\Desktop\SlippageAnalysis\Slippage_',datestr(now,'dd-mm-yyyy'),'.xlsx');
 if ~exist(filename, 'file') %this loop check if the file exists
     xlswrite(filename,table,1,'A1')
 else
     filename = strcat('C:\Users\Trader\Desktop\SlippageAnalysis\Slippage_',datestr(now,'dd-mm-yyyy_HH_MM_SS'),'.xlsx');
     xlswrite(filename,table,1,'A1')
 end



    
end