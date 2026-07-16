function Components = ComponentSelectionModule(Input,Transformer,Bridge,Capacitor,LED)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAM 9 : ComponentSelectionModule.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Components.Transformer.PartNumber = sprintf('TR-%dVA-%dVAC', Transformer.RecommendedVA, round(Input.Vac));
Components.Transformer.RatingVA = Transformer.RecommendedVA;
Components.Transformer.SecondaryVoltage = round(Input.Vac);
Components.Transformer.Current = Transformer.RecommendedCurrent;
Components.Transformer.Package = Transformer.RecommendedType;

Components.Bridge.PartNumber = Bridge.RecommendedPart;
Components.Bridge.CurrentRating = Bridge.RecommendedCurrent;
Components.Bridge.PIV = Bridge.RecommendedPIV;
Components.Bridge.Package = 'Through Hole';

Components.Capacitor.Value = Capacitor.RecommendedCapacitance;
Components.Capacitor.Voltage = Capacitor.VoltageRating;
Components.Capacitor.Type = 'Aluminium Electrolytic';
Components.Capacitor.Package = 'Radial';

Components.LED.Color = 'Green';
Components.LED.Size = '5 mm';
Components.LED.ForwardVoltage = Input.LEDVoltage;
Components.LED.Current = LED.ActualCurrent;

Components.Resistor.Value = LED.RecommendedResistance;
Components.Resistor.Power = LED.ResistorRating;
Components.Resistor.Type = 'Metal Film';
Components.Resistor.Package = 'Axial';

if Input.LoadCurrent <= 1
    Components.PCB.Copper = '1 oz';
elseif Input.LoadCurrent <= 3
    Components.PCB.Copper = '2 oz';
else
    Components.PCB.Copper = '3 oz';
end
Components.PCB.Material = 'FR4';
Components.PCB.BoardThickness = '1.6 mm';

if Input.LoadCurrent <= 2
    Components.Connector = '2-Pin 5.08 mm Screw Terminal';
else
    Components.Connector = '5A Screw Terminal';
end

Components.Fuse.Current = ceil(Input.LoadCurrent*1.5);
Components.Fuse.Type = 'Slow Blow';

CostTransformer=12; CostBridge=1; CostCapacitor=0.75; CostLED=0.10;
CostResistor=0.05; CostPCB=4; CostConnector=0.50; CostFuse=0.30;
Components.EstimatedCost = CostTransformer+CostBridge+CostCapacitor+CostLED+ ...
    CostResistor+CostPCB+CostConnector+CostFuse;

Components.Availability = 'Standard Components';

fprintf('\n-----------------------------------------------\n');
fprintf('Component Selection Module Completed\n');
fprintf('-----------------------------------------------\n');
fprintf('Transformer  : %s\n', Components.Transformer.PartNumber);
fprintf('Bridge       : %s\n', Components.Bridge.PartNumber);
fprintf('Capacitor    : %.0f uF / %d V\n', Components.Capacitor.Value, Components.Capacitor.Voltage);
fprintf('LED          : %s, %s\n', Components.LED.Color, Components.LED.Size);
fprintf('Resistor     : %.0f Ohm, %.2f W\n', Components.Resistor.Value, Components.Resistor.Power);
fprintf('Fuse         : %d A, %s\n', Components.Fuse.Current, Components.Fuse.Type);
fprintf('Connector    : %s\n', Components.Connector);
fprintf('Estimated Cost : %.2f\n', Components.EstimatedCost);
fprintf('-----------------------------------------------\n');
Components.Status = 'PASS';
end