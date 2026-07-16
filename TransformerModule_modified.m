%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TransformerModule.m
%
% COMMERCIAL POWER SUPPLY DESIGN CALCULATOR
%
% Calculates all transformer parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Transformer = TransformerModule(Input)

% If run directly with no Input supplied (e.g. clicking Run in the
% editor), ask the user to type in each value. Transformer Efficiency
% is NOT asked here anymore -- it is now calculated automatically
% further below, based on the transformer's VA rating. When called
% properly from Program 1 (PowerSupplyDesignCalculator.m), the real
% Input struct passed in is used instead and this block is skipped.
if nargin == 0
    fprintf('\n');
    fprintf('-----------------------------------------------\n');
    fprintf('TransformerModule - Standalone Test Mode\n');
    fprintf('Enter values below (or run via Program 1 instead)\n');
    fprintf('-----------------------------------------------\n');

    Input.Vac = input('Transformer AC Voltage (VAC RMS) = ');
    Input.RequiredDC = input('Required DC Output Voltage (V) = ');
    Input.LoadCurrent = input('Load Current (A) = ');
    Input.Frequency = input('AC Frequency (Hz) = ');
    Input.DiodeForwardVoltage = input('Diode Forward Voltage (V) = ');
end

%% Constants

PrimaryVoltage = 230;                 % VAC
SafetyFactorVA = 1.25;                % 25% Design Margin
BridgeDrop = 2 * Input.DiodeForwardVoltage;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Electrical Calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer.SecondaryVoltage = Input.Vac;

Transformer.PeakVoltage = ...
    Input.Vac * sqrt(2);

Transformer.RequiredSecondaryVoltage = ...
    (Input.RequiredDC + BridgeDrop) / sqrt(2);

Transformer.EstimatedDC = ...
    Transformer.PeakVoltage - BridgeDrop;

Transformer.RippleFrequency = ...
    2 * Input.Frequency;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Transformer Turns Ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer.TurnsRatio = ...
    PrimaryVoltage / Input.Vac;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VA Rating
%% (Moved earlier so the transformer's SIZE is known before its
%%  efficiency is auto-estimated below. Formulas are unchanged.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer.VA = ...
    Input.Vac * Input.LoadCurrent;

Transformer.RequiredVA = ...
    Transformer.VA * SafetyFactorVA;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Recommended Standard Transformer
%% (Moved earlier, same reason as above. Formulas unchanged.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

StandardVA = [1 2 3 5 6 9 12 15 18 24 30 36 ...
              50 60 75 100 120 150 200 250];

index = find(StandardVA >= Transformer.RequiredVA,1);

if isempty(index)
    Transformer.RecommendedVA = StandardVA(end);
else
    Transformer.RecommendedVA = StandardVA(index);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Automatic Transformer Efficiency Estimation  (NEW)
%%
%% Instead of asking the user to type an efficiency value, it is now
%% estimated automatically from the transformer's own VA rating
%% (its physical size), using standard industry-typical efficiency
%% ranges for each transformer size/type:
%%   Small EI-core   (<=15 VA)   : ~80% typical
%%   Toroidal        (<=100 VA)  : ~88% typical
%%   Industrial iso. (>100 VA)   : ~94% typical
%% This mirrors the same VA breakpoints used later in the
%% "Transformer Recommendation" section for consistency.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Transformer.RecommendedVA <= 15
    Input.TransformerEfficiency = 80;
elseif Transformer.RecommendedVA <= 100
    Input.TransformerEfficiency = 88;
else
    Input.TransformerEfficiency = 94;
end

Transformer.AssumedEfficiency = Input.TransformerEfficiency;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Power Calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer.OutputPower = ...
    Input.RequiredDC * Input.LoadCurrent;

Transformer.InputPower = ...
    Transformer.OutputPower / ...
    (Input.TransformerEfficiency / 100);

Transformer.PowerLoss = ...
    Transformer.InputPower - ...
    Transformer.OutputPower;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Current Rating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer.SecondaryCurrent = ...
    Input.LoadCurrent;

Transformer.RecommendedCurrent = ...
    1.25 * Input.LoadCurrent;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copper Loss Estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer.CopperLoss = ...
    0.60 * Transformer.PowerLoss;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Core Loss Estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer.CoreLoss = ...
    0.40 * Transformer.PowerLoss;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Voltage Regulation Estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer.NoLoadVoltage = ...
    Transformer.SecondaryVoltage;

Transformer.FullLoadVoltage = ...
    0.95 * Transformer.SecondaryVoltage;

Transformer.VoltageRegulation = ...
    ((Transformer.NoLoadVoltage - ...
      Transformer.FullLoadVoltage) / ...
      Transformer.FullLoadVoltage) * 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Transformer Recommendation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Transformer.RecommendedVA <= 15

    Transformer.RecommendedType = ...
        'EI Core Transformer';

elseif Transformer.RecommendedVA <= 100

    Transformer.RecommendedType = ...
        'Toroidal Transformer';

else

    Transformer.RecommendedType = ...
        'Industrial Isolation Transformer';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Efficiency Check
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer.CalculatedEfficiency = ...
    (Transformer.OutputPower / ...
     Transformer.InputPower) * 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Design Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Transformer.CalculatedEfficiency >= 85

    Transformer.Status = 'PASS';

else

    Transformer.Status = 'FAIL';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n');
fprintf('-----------------------------------------------\n');
fprintf('Transformer Module Completed\n');
fprintf('-----------------------------------------------\n');

fprintf('Peak Voltage                : %.2f V\n', ...
        Transformer.PeakVoltage);

fprintf('Estimated DC Voltage        : %.2f V\n', ...
        Transformer.EstimatedDC);

fprintf('Turns Ratio                 : %.2f : 1\n', ...
        Transformer.TurnsRatio);

fprintf('Transformer VA Rating       : %.2f VA\n', ...
        Transformer.RecommendedVA);

fprintf('Auto-Estimated Efficiency   : %.2f %%\n', ...
        Transformer.AssumedEfficiency);

fprintf('Output Power                : %.2f W\n', ...
        Transformer.OutputPower);

fprintf('Input Power                 : %.2f W\n', ...
        Transformer.InputPower);

fprintf('Power Loss                  : %.2f W\n', ...
        Transformer.PowerLoss);

fprintf('Efficiency                  : %.2f %%\n', ...
        Transformer.CalculatedEfficiency);

fprintf('Voltage Regulation          : %.2f %%\n', ...
        Transformer.VoltageRegulation);

fprintf('Recommended Transformer     : %s\n', ...
        Transformer.RecommendedType);

fprintf('Status                      : %s\n', ...
        Transformer.Status);

fprintf('-----------------------------------------------\n');

end