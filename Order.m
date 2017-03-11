function [order] = Order(table, ib,id)

table = table(2:end,:);

for x=1:size(table,1);
if table{x,2} == 0 ;    
    continue;
end

ibContract = ib.Handle.createContract;
ibContract.symbol = table{x,1};
ibContract.secType = 'STK';
ibContract.exchange = 'SMART';
%ibContract.primaryExchange = 'ARCA';
ibContract.currency = 'USD';

ibMktOrder = ib.Handle.createOrder;
ibMktOrder.action = table{x,3};
ibMktOrder.totalQuantity = table{x,2};
ibMktOrder.orderType = 'MKT';



result = createOrder(ib,ibContract,ibMktOrder,id);
id = id+1;
end

order = id;
end