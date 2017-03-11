function [Performance_each, Performance_all, Performance_time, PnL] = getPerformance(Notional, AllocationNotionalRep, returns_daily)

Performance_each    = AllocationNotionalRep(1:end-1,:) .* returns_daily;
Performance_all     = sum(Performance_each,2);
Performance_time    = cumsum(Performance_all);

PnL =  Notional + Performance_time;
end