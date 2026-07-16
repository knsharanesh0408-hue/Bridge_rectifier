%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bridge Rectifier Power Supply Design Calculator
%
% Calculates:
% 1. Transformer Parameters
% 2. Bridge Rectifier Parameters
% 3. Filter Capacitor Parameters
% 4. LED Resistor Parameters
% 5. LED Parameters
%
% Author : K N SHARANESH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

fprintf('\n');
fprintf('===============================================\n');
fprintf('     BRIDGE RECTIFIER POWER SUPPLY DESIGN TOOL\n');
fprintf('===============================================\n\n');

%% ===========================
% USER INPUT
%% ===========================

Vac = input('Enter Transformer AC Voltage (VAC RMS) = ');
Vdc_required = input('Enter Required DC Output Voltage (V) = ');
Iload = input('Enter Load Current (A) = ');
Frequency = input('Enter AC Frequency (Hz) = ');

fprintf('\nLED PARAMETERS\n');
Vled = input('LED Forward Voltage (V) = ');
Iled = input('LED Current (mA) = ');

Iled = Iled/1000;        % Convert mA to A

Ripple = input('Allowable Ripple Voltage (Vpp) = ');

fprintf('\n');

%% ==================================================
% STEP 1 : TRANSFORMER PARAMETERS
%% ==================================================

Vpeak = Vac*sqrt(2);

BridgeDrop = 2*0.7;

EstimatedDC = Vpeak - BridgeDrop;

RequiredTransformerVAC = (Vdc_required + BridgeDrop)/sqrt(2);

%% ==================================================
% STEP 2 : DIODE PARAMETERS
%% ==================================================

PIV = Vpeak;

RecommendedPIV = max(100,ceil(PIV/100)*100);

ForwardVoltage = 0.7;

BridgePower = BridgeDrop*Iload;

DiodeCurrent = Iload;

%% ==================================================
% STEP 3 : FILTER CAPACITOR
%% ==================================================

RippleFrequency = 2*Frequency;

Capacitance = Iload/(RippleFrequency*Ripple);

Capacitance_uF = Capacitance*1e6;

% Recommended Standard Capacitor

StandardCaps = [470 1000 2200 3300 4700 6800 10000 15000];

Difference = abs(StandardCaps-Capacitance_uF);

[~,Index] = min(Difference);

RecommendedCap = StandardCaps(Index);

RippleActual = Iload/(RippleFrequency*(RecommendedCap/1e6));

%% ==================================================
% STEP 4 : LED RESISTOR
%% ==================================================

Resistor = (EstimatedDC - Vled)/Iled;

StandardResistors = [220 330 470 680 820 1000 1200 1500 1800 ...
                     2200 2700 3300 3900 4700 5600 6800 ...
                     8200 10000];

Difference = abs(StandardResistors-Resistor);

[~,Index] = min(Difference);

RecommendedResistor = StandardResistors(Index);

ResistorPower = Iled^2*RecommendedResistor;

%% ==================================================
% STEP 5 : LED PARAMETERS
%% ==================================================

LEDPower = Vled*Iled;

%% ==================================================
% OUTPUT
%% ==================================================

fprintf('\n');
fprintf('===========================================================\n');
fprintf('             POWER SUPPLY DESIGN SUMMARY\n');
fprintf('===========================================================\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n');
fprintf('1. TRANSFORMER PARAMETERS\n');
fprintf('-----------------------------------------------------------\n');

fprintf('Input AC Voltage              : %.2f VAC\n',Vac);
fprintf('Frequency                     : %.2f Hz\n',Frequency);
fprintf('Peak Secondary Voltage        : %.2f V\n',Vpeak);
fprintf('Bridge Rectifier Drop         : %.2f V\n',BridgeDrop);
fprintf('Estimated DC Output           : %.2f V\n',EstimatedDC);
fprintf('Required Transformer Voltage  : %.2f VAC\n',RequiredTransformerVAC);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n');
fprintf('2. DIODE PARAMETERS\n');
fprintf('-----------------------------------------------------------\n');

fprintf('Forward Voltage/Diode         : %.2f V\n',ForwardVoltage);
fprintf('Total Bridge Drop             : %.2f V\n',BridgeDrop);
fprintf('Diode Current Rating          : %.2f A minimum\n',DiodeCurrent);
fprintf('Minimum PIV                   : %.2f V\n',PIV);
fprintf('Recommended PIV              : %d V\n',RecommendedPIV);
fprintf('Bridge Power Dissipation      : %.2f W\n',BridgePower);

if RecommendedPIV<=100
    fprintf('Recommended Diode             : 1N4002\n');
elseif RecommendedPIV<=400
    fprintf('Recommended Diode             : 1N4004\n');
else
    fprintf('Recommended Diode             : 1N4007\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n');
fprintf('3. FILTER CAPACITOR PARAMETERS\n');
fprintf('-----------------------------------------------------------\n');

fprintf('Ripple Frequency              : %.2f Hz\n',RippleFrequency);
fprintf('Required Capacitance          : %.0f uF\n',Capacitance_uF);
fprintf('Recommended Capacitor         : %d uF\n',RecommendedCap);
fprintf('Capacitor Voltage Rating      : 25 V minimum\n');
fprintf('Estimated Ripple              : %.2f Vpp\n',RippleActual);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n');
fprintf('4. RESISTOR PARAMETERS\n');
fprintf('-----------------------------------------------------------\n');

fprintf('Calculated LED Resistor       : %.0f Ohms\n',Resistor);
fprintf('Recommended Standard Value    : %d Ohms\n',RecommendedResistor);
fprintf('Resistor Power                : %.3f W\n',ResistorPower);

if ResistorPower<=0.25
    fprintf('Recommended Resistor Rating   : 1/4 W\n');
elseif ResistorPower<=0.5
    fprintf('Recommended Resistor Rating   : 1/2 W\n');
else
    fprintf('Recommended Resistor Rating   : 1 W\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n');
fprintf('5. LED PARAMETERS\n');
fprintf('-----------------------------------------------------------\n');

fprintf('LED Forward Voltage           : %.2f V\n',Vled);
fprintf('LED Current                   : %.2f mA\n',Iled*1000);
fprintf('LED Power                     : %.3f W\n',LEDPower);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n');
fprintf('===========================================================\n');
fprintf('DESIGN COMPLETE\n');
fprintf('===========================================================\n');