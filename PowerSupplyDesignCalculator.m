%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PROGRAM 1 : PowerSupplyDesignCalculator.m   (MAIN PROGRAM)
%  COMMERCIAL BRIDGE RECTIFIER POWER SUPPLY DESIGN CALCULATOR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear; close all;

fprintf('\n=============================================================\n');
fprintf(' COMMERCIAL POWER SUPPLY DESIGN CALCULATOR\n');
fprintf('=============================================================\n\n');

%% ------------- INPUT PARAMETERS -------------
fprintf('------------- INPUT PARAMETERS ----------------\n\n');
Input.Vac              = input('Transformer Secondary Voltage (VAC RMS) : ');
Input.RequiredDC        = input('Required DC Output Voltage (V) : ');
Input.LoadCurrent       = input('Load Current (A) : ');
Input.Frequency          = input('AC Supply Frequency (Hz) : ');
Input.AllowedRipple     = input('Allowable Ripple Voltage (Vpp) : ');
fprintf('\n');

fprintf('------------- LED PARAMETERS -------------------\n\n');
Input.LEDVoltage = input('LED Forward Voltage (V) : ');
Input.LEDCurrent = input('LED Current (mA) : ');
Input.LEDCurrent = Input.LEDCurrent / 1000;   % mA -> A
fprintf('\n');

fprintf('------------- THERMAL PARAMETERS ---------------\n\n');
Input.AmbientTemperature = input('Ambient Temperature (deg C) : ');
Input.ThermalResistance   = input('Bridge Thermal Resistance (deg C/W) : ');
fprintf('\n');

fprintf('------------- DIODE PARAMETERS -----------------\n\n');
Input.DiodeForwardVoltage = input('Forward Voltage per Diode (V) : ');
fprintf('\n');

fprintf('------------- TRANSFORMER ----------------------\n\n');
Input.TransformerEfficiency = input('Transformer Efficiency (%) : ');
fprintf('\n');

fprintf('------------- CAPACITOR ------------------------\n\n');
Input.CapacitorESR = input('Capacitor ESR (Ohm) : ');
fprintf('\n');

fprintf('------------- PCB PARAMETERS -------------------\n\n');
Input.TraceWidth      = input('PCB Copper Trace Width (mm) : ');
Input.CopperThickness = 0.035;   % mm, 1 oz copper (fixed process value)

%% ------------- INPUT VALIDATION -------------
if Input.Vac <= 0,            error('AC Voltage must be greater than zero'); end
if Input.RequiredDC <= 0,     error('Output Voltage must be greater than zero'); end
if Input.LoadCurrent <= 0,    error('Load Current must be greater than zero'); end
if Input.Frequency <= 0,      error('Frequency must be greater than zero'); end
if Input.AllowedRipple <= 0,  error('Ripple Voltage must be greater than zero'); end

%% ------------- CALL ENGINEERING MODULES -------------
fprintf('\nPerforming Engineering Calculations...\n\n');

Transformer = TransformerModule(Input);
Bridge      = BridgeRectifierModule(Input,Transformer);
Capacitor   = CapacitorModule(Input,Bridge);
LED         = LEDResistorModule(Input,Transformer);
Power       = PowerAnalysisModule(Input,Transformer,Bridge,Capacitor,LED);
Voltage     = VoltageRegulationModule(Input,Transformer,Bridge,Capacitor);
Thermal     = ThermalAnalysisModule(Input,Transformer,Bridge,Capacitor,LED);
Components  = ComponentSelectionModule(Input,Transformer,Bridge,Capacitor,LED);

%% ------------- DISPLAY SUMMARY -------------
fprintf('\n=============================================================\n');
fprintf(' DESIGN SUMMARY\n');
fprintf('=============================================================\n\n');
fprintf('Required DC Voltage       : %.2f V\n', Input.RequiredDC);
fprintf('Estimated DC Voltage      : %.2f V\n', Transformer.EstimatedDC);
fprintf('Transformer VA Rating     : %.2f VA\n', Transformer.VA);
fprintf('Bridge Power Loss         : %.2f W\n', Bridge.PowerLoss);
fprintf('Required Capacitor        : %.0f uF\n', Capacitor.RequiredCapacitance);
fprintf('Recommended Capacitor     : %.0f uF\n', Components.Capacitor.Value);
fprintf('LED Resistor              : %.0f Ohm\n', Components.Resistor.Value);
fprintf('Efficiency                : %.2f %%\n', Power.Efficiency);
fprintf('Voltage Regulation        : %.2f %%\n', Voltage.Regulation);
fprintf('Bridge Junction Temp      : %.2f deg C\n', Thermal.JunctionTemperature);
fprintf('\n');

%% ------------- DESIGN STATUS -------------
fprintf('=============================================================\n');
fprintf('DESIGN STATUS\n');
fprintf('=============================================================\n\n');
fprintf('Transformer       : %s\n', Transformer.Status);
fprintf('Bridge Rectifier  : %s\n', Bridge.Status);
fprintf('Capacitor         : %s\n', Capacitor.Status);
fprintf('LED Circuit       : %s\n', LED.Status);
fprintf('Thermal           : %s\n', Thermal.Status);
fprintf('\n');
fprintf('=============================================================\n');
fprintf('Commercial Power Supply Design Completed Successfully.\n');
fprintf('=============================================================\n\n');








































