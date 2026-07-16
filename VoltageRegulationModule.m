function Voltage = VoltageRegulationModule(Input,Transformer,Bridge,Capacitor)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAM 7 : VoltageRegulationModule.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TransformerRegulation = 0.05;   % typical 5%
VoltageTolerance = 5;           % +/- 5%

Voltage.NoLoadVoltage = Transformer.PeakVoltage - Bridge.TotalForwardDrop;

Voltage.FullLoadSecondary = Input.Vac * (1 - TransformerRegulation);
Voltage.FullLoadPeak = Voltage.FullLoadSecondary * sqrt(2);

Voltage.CapacitorDrop = Capacitor.ActualRipple / 2;

Voltage.FullLoadVoltage = Voltage.FullLoadPeak - Bridge.TotalForwardDrop - Voltage.CapacitorDrop;

Voltage.TransformerDrop = Voltage.NoLoadVoltage - Voltage.FullLoadPeak + Bridge.TotalForwardDrop;
Voltage.BridgeDrop = Bridge.TotalForwardDrop;
Voltage.TotalDrop = Voltage.NoLoadVoltage - Voltage.FullLoadVoltage;

Voltage.Regulation = ((Voltage.NoLoadVoltage - Voltage.FullLoadVoltage) / Voltage.FullLoadVoltage) * 100;
Voltage.LoadRegulation = Voltage.NoLoadVoltage - Voltage.FullLoadVoltage;
Voltage.LineRegulation = Voltage.LoadRegulation / Input.Vac;

Voltage.OutputError = Voltage.FullLoadVoltage - Input.RequiredDC;
Voltage.OutputErrorPercent = abs(Voltage.OutputError) / Input.RequiredDC * 100;
Voltage.Margin = Voltage.FullLoadVoltage - Input.RequiredDC;

Voltage.RequiredTransformerVoltage = ...
    (Input.RequiredDC + Bridge.TotalForwardDrop + Voltage.CapacitorDrop) / sqrt(2);

if Voltage.OutputErrorPercent <= VoltageTolerance
    Voltage.VoltageStatus = 'PASS';
else
    Voltage.VoltageStatus = 'FAIL';
end
Voltage.Status = Voltage.VoltageStatus;

if Voltage.OutputErrorPercent <= 1
    Voltage.Quality = 'Excellent';
elseif Voltage.OutputErrorPercent <= 3
    Voltage.Quality = 'Very Good';
elseif Voltage.OutputErrorPercent <= 5
    Voltage.Quality = 'Good';
elseif Voltage.OutputErrorPercent <= 10
    Voltage.Quality = 'Acceptable';
else
    Voltage.Quality = 'Poor';
end

fprintf('\n-----------------------------------------------\n');
fprintf('Voltage Regulation Module Completed\n');
fprintf('-----------------------------------------------\n');
fprintf('No-Load Voltage        : %.2f V\n', Voltage.NoLoadVoltage);
fprintf('Full-Load Voltage      : %.2f V\n', Voltage.FullLoadVoltage);
fprintf('Total Voltage Drop     : %.2f V\n', Voltage.TotalDrop);
fprintf('Voltage Regulation     : %.2f %%\n', Voltage.Regulation);
fprintf('Output Error           : %.2f %%\n', Voltage.OutputErrorPercent);
fprintf('Required Xfmr Voltage  : %.2f VAC\n', Voltage.RequiredTransformerVoltage);
fprintf('Quality                : %s\n', Voltage.Quality);
fprintf('Status                 : %s\n', Voltage.Status);
fprintf('-----------------------------------------------\n');
end