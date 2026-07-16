function Capacitor = CapacitorModule(Input,Bridge)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAM 4 : CapacitorModule.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SafetyVoltageFactor = 1.50;
MaximumRippleVoltage = Input.AllowedRipple;

Capacitor.RippleFrequency = 2 * Input.Frequency;

Capacitor.RequiredCapacitance = ...
    (Input.LoadCurrent / (Capacitor.RippleFrequency * MaximumRippleVoltage)) * 1e6;

StandardCaps = [470 680 1000 1500 2200 3300 4700 6800 8200 10000 15000 22000];
Index = find(StandardCaps >= Capacitor.RequiredCapacitance,1);
if isempty(Index)
    Capacitor.RecommendedCapacitance = StandardCaps(end);
else
    Capacitor.RecommendedCapacitance = StandardCaps(Index);
end

Capacitor.ActualRipple = ...
    Input.LoadCurrent / (Capacitor.RippleFrequency * (Capacitor.RecommendedCapacitance/1e6));

Capacitor.RippleCurrent = 1.8 * Input.LoadCurrent;

Capacitor.ESR = Input.CapacitorESR;
Capacitor.PowerLoss = Capacitor.RippleCurrent^2 * Capacitor.ESR;

BridgeVoltage = Bridge.OutputVoltage;
Capacitor.StoredEnergy = 0.5 * (Capacitor.RecommendedCapacitance/1e6) * BridgeVoltage^2;

Capacitor.LoadResistance = Bridge.OutputVoltage / Input.LoadCurrent;
Capacitor.TimeConstant = Capacitor.LoadResistance * (Capacitor.RecommendedCapacitance/1e6);

Capacitor.MinimumVoltage = Bridge.OutputVoltage;
VoltageRequired = Bridge.OutputVoltage * SafetyVoltageFactor;
if VoltageRequired <= 16
    Capacitor.VoltageRating = 16;
elseif VoltageRequired <= 25
    Capacitor.VoltageRating = 25;
elseif VoltageRequired <= 35
    Capacitor.VoltageRating = 35;
elseif VoltageRequired <= 50
    Capacitor.VoltageRating = 50;
else
    Capacitor.VoltageRating = 63;
end

ReferenceLife = 2000;   % hours
ReferenceTemp = 105;    % deg C
OperatingTemp = Input.AmbientTemperature + 15;
Capacitor.EstimatedLife = ReferenceLife * 2^((ReferenceTemp-OperatingTemp)/10);

Capacitor.ChargeTime = 5 * Capacitor.TimeConstant;
Capacitor.DischargeTime = Capacitor.TimeConstant;

if Capacitor.ActualRipple <= MaximumRippleVoltage
    RippleStatus = 'PASS';
else
    RippleStatus = 'FAIL';
end
if Capacitor.PowerLoss < 2
    ESRStatus = 'PASS';
else
    ESRStatus = 'FAIL';
end

if strcmp(RippleStatus,'PASS') && strcmp(ESRStatus,'PASS')
    Capacitor.Status = 'PASS';
else
    Capacitor.Status = 'FAIL';
end

fprintf('\n-----------------------------------------------\n');
fprintf('Capacitor Module Completed\n');
fprintf('-----------------------------------------------\n');
fprintf('Ripple Frequency        : %.2f Hz\n', Capacitor.RippleFrequency);
fprintf('Required Capacitance    : %.0f uF\n', Capacitor.RequiredCapacitance);
fprintf('Recommended Capacitor   : %.0f uF\n', Capacitor.RecommendedCapacitance);
fprintf('Actual Ripple Voltage   : %.2f Vpp\n', Capacitor.ActualRipple);
fprintf('Ripple Current          : %.2f A\n', Capacitor.RippleCurrent);
fprintf('ESR                     : %.3f Ohm\n', Capacitor.ESR);
fprintf('Capacitor Loss          : %.3f W\n', Capacitor.PowerLoss);
fprintf('Stored Energy           : %.3f J\n', Capacitor.StoredEnergy);
fprintf('Time Constant           : %.3f s\n', Capacitor.TimeConstant);
fprintf('Charge Time             : %.3f s\n', Capacitor.ChargeTime);
fprintf('Discharge Time          : %.3f s\n', Capacitor.DischargeTime);
fprintf('Voltage Rating          : %d V\n', Capacitor.VoltageRating);
fprintf('Estimated Life          : %.0f hours\n', Capacitor.EstimatedLife);
fprintf('Status                  : %s\n', Capacitor.Status);
fprintf('-----------------------------------------------\n');
end