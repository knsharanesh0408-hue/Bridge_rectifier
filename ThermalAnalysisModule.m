function Thermal = ThermalAnalysisModule(Input,Transformer,Bridge,Capacitor,LED)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAM 8 : ThermalAnalysisModule.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tamb = Input.AmbientTemperature;
MaxJunction = 125;
MaxCapTemp = 105;
MaxLEDTemp = 85;
MaxResistorTemp = 155;

ThetaTransformer = 12;
ThetaBridge = Input.ThermalResistance;
ThetaCapacitor = 18;
ThetaLED = 200;
ThetaResistor = 120;

Thermal.TransformerRise = Transformer.PowerLoss * ThetaTransformer;
Thermal.TransformerTemp = Tamb + Thermal.TransformerRise;

Thermal.BridgeRise = Bridge.PowerLoss * ThetaBridge;
Thermal.BridgeTemp = Tamb + Thermal.BridgeRise;

Thermal.JunctionTemperature = Thermal.BridgeTemp;

Thermal.CapacitorRise = Capacitor.PowerLoss * ThetaCapacitor;
Thermal.CapacitorTemp = Tamb + Thermal.CapacitorRise;

Thermal.LEDRise = LED.Power * ThetaLED;
Thermal.LEDTemp = Tamb + Thermal.LEDRise;

Thermal.ResistorRise = LED.ResistorPower * ThetaResistor;
Thermal.ResistorTemp = Tamb + Thermal.ResistorRise;

Thermal.TotalHeat = Transformer.PowerLoss + Bridge.PowerLoss + Capacitor.PowerLoss ...
    + LED.ResistorPower + LED.Power;

Thermal.MaximumPCBTemperature = max([Thermal.TransformerTemp Thermal.BridgeTemp ...
    Thermal.CapacitorTemp Thermal.LEDTemp Thermal.ResistorTemp]);

Thermal.TransformerMargin = MaxJunction - Thermal.TransformerTemp;
Thermal.BridgeMargin = MaxJunction - Thermal.BridgeTemp;
Thermal.CapacitorMargin = MaxCapTemp - Thermal.CapacitorTemp;
Thermal.LEDMargin = MaxLEDTemp - Thermal.LEDTemp;
Thermal.ResistorMargin = MaxResistorTemp - Thermal.ResistorTemp;

TransformerOK = Thermal.TransformerTemp < MaxJunction;
BridgeOK = Thermal.BridgeTemp < MaxJunction;
CapacitorOK = Thermal.CapacitorTemp < MaxCapTemp;
LEDOK = Thermal.LEDTemp < MaxLEDTemp;
ResistorOK = Thermal.ResistorTemp < MaxResistorTemp;

if Thermal.MaximumPCBTemperature < 60
    Thermal.Cooling = 'Natural Air Cooling';
elseif Thermal.MaximumPCBTemperature < 85
    Thermal.Cooling = 'Ventilated Enclosure';
elseif Thermal.MaximumPCBTemperature < 100
    Thermal.Cooling = 'Heat Sink Recommended';
else
    Thermal.Cooling = 'Forced Air Cooling Required';
end

if Thermal.MaximumPCBTemperature < 70
    Thermal.Derating = 100;
elseif Thermal.MaximumPCBTemperature < 90
    Thermal.Derating = 90;
elseif Thermal.MaximumPCBTemperature < 110
    Thermal.Derating = 80;
else
    Thermal.Derating = 60;
end

if TransformerOK && BridgeOK && CapacitorOK && LEDOK && ResistorOK
    Thermal.Status = 'PASS';
else
    Thermal.Status = 'FAIL';
end

fprintf('\n-----------------------------------------------\n');
fprintf('Thermal Analysis Module Completed\n');
fprintf('-----------------------------------------------\n');
fprintf('Transformer Temp     : %.2f C\n', Thermal.TransformerTemp);
fprintf('Bridge Temp          : %.2f C\n', Thermal.BridgeTemp);
fprintf('Capacitor Temp       : %.2f C\n', Thermal.CapacitorTemp);
fprintf('LED Temp             : %.2f C\n', Thermal.LEDTemp);
fprintf('Resistor Temp        : %.2f C\n', Thermal.ResistorTemp);
fprintf('Max PCB Temp         : %.2f C\n', Thermal.MaximumPCBTemperature);
fprintf('Cooling Needed       : %s\n', Thermal.Cooling);
fprintf('PCB Derating         : %d %%\n', Thermal.Derating);
fprintf('Status               : %s\n', Thermal.Status);
fprintf('-----------------------------------------------\n');
end