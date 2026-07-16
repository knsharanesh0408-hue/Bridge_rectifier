function Power = PowerAnalysisModule(Input,Transformer,Bridge,Capacitor,LED)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAM 6 : PowerAnalysisModule.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HoursPerDay = 24;
DaysPerYear = 365;
ElectricityCost = 8.0;   % currency / kWh
MinimumEfficiency = 80;

Power.OutputVoltage = Input.RequiredDC;
Power.OutputCurrent = Input.LoadCurrent;
Power.OutputPower = Power.OutputVoltage * Power.OutputCurrent;

Power.InputPower = Transformer.InputPower;

Power.TransformerLoss = Transformer.PowerLoss;
Power.BridgeLoss = Bridge.PowerLoss;
Power.CapacitorLoss = Capacitor.PowerLoss;
Power.LEDPower = LED.Power;
Power.ResistorLoss = LED.ResistorPower;

Power.TotalLoss = Power.TransformerLoss + Power.BridgeLoss + ...
    Power.CapacitorLoss + Power.ResistorLoss;

Power.Efficiency = (Power.OutputPower / (Power.OutputPower + Power.TotalLoss)) * 100;

Power.TotalHeat = Power.TotalLoss;
Power.TransformerHeat = Power.TransformerLoss;
Power.BridgeHeat = Power.BridgeLoss;
Power.CapacitorHeat = Power.CapacitorLoss;
Power.ResistorHeat = Power.ResistorLoss;

Power.PowerFactor = 0.62;
Power.ApparentPower = Power.InputPower / Power.PowerFactor;
Power.ReactivePower = sqrt(Power.ApparentPower^2 - Power.InputPower^2);

Power.DailyEnergy = Power.InputPower * HoursPerDay / 1000;
Power.MonthlyEnergy = Power.DailyEnergy * 30;
Power.YearlyEnergy = Power.DailyEnergy * DaysPerYear;

Power.DailyCost = Power.DailyEnergy * ElectricityCost;
Power.MonthlyCost = Power.MonthlyEnergy * ElectricityCost;
Power.YearlyCost = Power.YearlyEnergy * ElectricityCost;

Power.LossPercentage = (Power.TotalLoss / (Power.OutputPower + Power.TotalLoss)) * 100;

Power.Loading = (Power.OutputPower / Transformer.RecommendedVA) * 100;

if Power.Loading <= 80
    Power.LoadStatus = 'GOOD';
elseif Power.Loading <= 100
    Power.LoadStatus = 'FULL LOAD';
else
    Power.LoadStatus = 'OVERLOADED';
end

if Power.Efficiency >= 95
    Power.EfficiencyClass = 'Excellent';
elseif Power.Efficiency >= 90
    Power.EfficiencyClass = 'Very Good';
elseif Power.Efficiency >= 85
    Power.EfficiencyClass = 'Good';
elseif Power.Efficiency >= 80
    Power.EfficiencyClass = 'Acceptable';
else
    Power.EfficiencyClass = 'Poor';
end

if Power.Efficiency >= MinimumEfficiency && strcmp(Power.LoadStatus,'GOOD')
    Power.Status = 'PASS';
else
    Power.Status = 'FAIL';
end

fprintf('\n-----------------------------------------------\n');
fprintf('Power Analysis Module Completed\n');
fprintf('-----------------------------------------------\n');
fprintf('Output Power         : %.2f W\n', Power.OutputPower);
fprintf('Input Power          : %.2f W\n', Power.InputPower);
fprintf('Total Loss           : %.2f W\n', Power.TotalLoss);
fprintf('Overall Efficiency   : %.2f %%\n', Power.Efficiency);
fprintf('Loss Percentage      : %.2f %%\n', Power.LossPercentage);
fprintf('Apparent Power       : %.2f VA\n', Power.ApparentPower);
fprintf('Reactive Power       : %.2f VAR\n', Power.ReactivePower);
fprintf('Daily Energy         : %.3f kWh\n', Power.DailyEnergy);
fprintf('Yearly Cost          : %.2f\n', Power.YearlyCost);
fprintf('Transformer Loading  : %.2f %%\n', Power.Loading);
fprintf('Load Status          : %s\n', Power.LoadStatus);
fprintf('Efficiency Class     : %s\n', Power.EfficiencyClass);
fprintf('Status               : %s\n', Power.Status);
fprintf('-----------------------------------------------\n');
end
