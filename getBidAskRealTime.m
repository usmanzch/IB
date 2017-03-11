function [id] = getBidAskRealTime(ticker,ib)

        ibContract = ib.Handle.createContract;
        ibContract.symbol = ticker;
        ibContract.secType = 'STK';
        ibContract.exchange = 'SMART';
      
        ibContract.currency = 'USD';
        id = realtime(ib,ibContract, '233');

end