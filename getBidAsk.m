function [BidAsk] = getBidAsk(tickersTrade,ib)
BidAsk = nan(size(tickersTrade,1),7);
    for x=1:size(tickersTrade,2)
       
        ibContract = ib.Handle.createContract;
        ibContract.symbol = tickersTrade{x};
        ibContract.secType = 'STK';
        ibContract.exchange = 'SMART';
      
        ibContract.currency = 'USD';
        d = getdata(ib,ibContract);

         disp(tickersTrade{x});
   
          BidAsk(x,1) = d.BID_PRICE;
          BidAsk(x,2) = d.BID_SIZE;
          BidAsk(x,3) = d.ASK_PRICE;
          BidAsk(x,4) = d.ASK_SIZE;
          BidAsk(x,5) = d.LAST_PRICE;
          BidAsk(x,6) = d.LAST_SIZE;
          
          try
          BidAsk(x,7) = d.VOLUME;
          catch
          end

           

    end
end