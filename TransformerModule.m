function Transformer = TransformerModule(Input)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAM 2 : TransformerModule.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PrimaryVoltage = 230;
SafetyFactorVA = 1.25;
BridgeDrop = 2 * Input.DiodeForwardVoltage;

Transformer.SecondaryVoltage = Input.Vac;
Transformer.PeakVoltage = Input.Vac * sqrt(2);
Transformer.RequiredSecondaryVoltage = (Input.RequiredDC + BridgeDrop) / sqrt(2);
Transformer.EstimatedDC = Transformer.PeakVoltage - BridgeDrop;
Transformer.RippleFrequency = 2 * Input.Frequency;

Transformer.TurnsRatio = PrimaryVoltage / Input.Vac;

Transformer.OutputPower = Input.RequiredDC * Input.LoadCurrent;
Transformer.InputPower = Transformer.OutputPower / (Input.TransformerEfficiency/100);
Transformer.PowerLoss = Transformer.InputPower - Transformer.OutputPower;

Transformer.VA = Input.Vac * Input.LoadCurrent;
Transformer.RequiredVA = Transformer.VA * SafetyFactorVA;

StandardVA = [1 2 3 5 6 9 12 15 18 24 30 36 50 60 75 100 120 150 200 250];
index = find(StandardVA >= Transformer.RequiredVA,1);
if isempty(index)
    Transformer.RecommendedVA = StandardVA(end);
else
    Transformer.RecommendedVA = StandardVA(index);
end

Transformer.SecondaryCurrent = Input.LoadCurrent;
Transformer.RecommendedCurrent = 1.25 * Input.LoadCurrent;

Transformer.CopperLoss = 0.60 * Transformer.PowerLoss;
Transformer.CoreLoss = 0.40 * Transformer.PowerLoss;

Transformer.NoLoadVoltage = Transformer.SecondaryVoltage;
Transformer.FullLoadVoltage = 0.95 * Transformer.SecondaryVoltage;
Transformer.VoltageRegulation = ...
    ((Transformer.NoLoadVoltage - Transformer.FullLoadVoltage) / Transformer.FullLoadVoltage) * 100;

if Transformer.RecommendedVA <= 15
    Transformer.RecommendedType = 'EI Core Transformer';
elseif Transformer.RecommendedVA <= 100
    Transformer.RecommendedType = 'Toroidal Transformer';
else
    Transformer.RecommendedType = 'Industrial Isolation Transformer';
end

Transformer.CalculatedEfficiency = (Transformer.OutputPower / Transformer.InputPower) * 100;

if Transformer.CalculatedEfficiency >= 85
    Transformer.Status = 'PASS';
else
    Transformer.Status = 'FAIL';
end

fprintf('\n-----------------------------------------------\n');
fprintf('Transformer Module Completed\n');
fprintf('-----------------------------------------------\n');
fprintf('Peak Voltage            : %.2f V\n', Transformer.PeakVoltage);
fprintf('Estimated DC Voltage    : %.2f V\n', Transformer.EstimatedDC);
fprintf('Turns Ratio             : %.2f : 1\n', Transformer.TurnsRatio);
fprintf('Transformer VA Rating   : %.2f VA\n', Transformer.RecommendedVA);
fprintf('Output Power            : %.2f W\n', Transformer.OutputPower);
fprintf('Input Power             : %.2f W\n', Transformer.InputPower);
fprintf('Power Loss              : %.2f W\n', Transformer.PowerLoss);
fprintf('Efficiency               : %.2f %%\n', Transformer.CalculatedEfficiency);
fprintf('Voltage Regulation      : %.2f %%\n', Transformer.VoltageRegulation);
fprintf('Recommended Transformer : %s\n', Transformer.RecommendedType);
fprintf('Status                  : %s\n', Transformer.Status);
fprintf('-----------------------------------------------\n');
end