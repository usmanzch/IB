function [order_STP] = OrderSTP(table)

table = table(2:end,:);
ib = ibtws('',7497); 
for x=1:size(table,1);
if table{x,2} == 0 ;    
    continue;
end

ibContract = ib.Handle.createContract;
ibContract.symbol = table{x,3};
ibContract.secType = 'STK';
ibContract.exchange = 'SMART';
%ibContract.primaryExchange = 'ARCA';
ibContract.currency = 'USD';

ibMktOrder = ib.Handle.createOrder;
ibMktOrder.action = 'SELL';
ibMktOrder.totalQuantity = table{x,2};
ibMktOrder.orderType = 'STP';
ibMktOrder.auxPrice = table{x,9};

id = orderid(ib);

result = createOrder(ib,ibContract,ibMktOrder,id);

end
close(ib)
order_STP = 1;
end