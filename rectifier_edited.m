%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bridge Rectifier Power Supply Design Calculator
% (Modified: units labeled on every variable + FB2027 T11.1.2 voltage
%  compliance check added. All original formulas/logic unchanged.)
%
% Calculates:
% 1. Transformer Parameters
% 2. Bridge Rectifier Parameters
% 3. Filter Capacitor Parameters
% 4. LED Resistor Parameters
% 5. LED Parameters
% 6. FB2027 Rulebook Voltage Compliance Check (NEW)
%
% Author : ChatGPT
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

Vac = input('Enter Transformer AC Voltage (VAC RMS) = ');           % [VAC RMS]
Vdc_required = input('Enter Required DC Output Voltage (V) = ');    % [V DC]
Iload = input('Enter Load Current (A) = ');                          % [A]
Frequency = input('Enter AC Frequency (Hz) = ');                     % [Hz]

fprintf('\nLED PARAMETERS\n');
Vled = input('LED Forward Voltage (V) = ');                          % [V]
Iled = input('LED Current (mA) = ');                                 % [mA]

Iled = Iled/1000;        % Convert mA to A                            % [A]

Ripple = input('Allowable Ripple Voltage (Vpp) = ');                 % [Vpp]

fprintf('\n');

%% ==================================================
% STEP 1 : TRANSFORMER PARAMETERS
%% ==================================================

Vpeak = Vac*sqrt(2);                                                  % [V] peak secondary voltage

BridgeDrop = 2*0.7;                                                   % [V] total drop across 2 conducting diodes

EstimatedDC = Vpeak - BridgeDrop;                                     % [V DC] estimated unregulated DC output

RequiredTransformerVAC = (Vdc_required + BridgeDrop)/sqrt(2);         % [VAC RMS] transformer rating needed

%% ==================================================
% STEP 2 : DIODE PARAMETERS
%% ==================================================

PIV = Vpeak;                                                          % [V] Peak Inverse Voltage

RecommendedPIV = max(100,ceil(PIV/100)*100);                          % [V] rounded standard PIV rating

ForwardVoltage = 0.7;                                                 % [V] per diode

BridgePower = BridgeDrop*Iload;                                       % [W] power dissipated in bridge

DiodeCurrent = Iload;                                                 % [A] diode current rating

%% ==================================================
% STEP 3 : FILTER CAPACITOR
%% ==================================================

RippleFrequency = 2*Frequency;                                        % [Hz] full-wave ripple frequency

Capacitance = Iload/(RippleFrequency*Ripple);                         % [F] required capacitance

Capacitance_uF = Capacitance*1e6;                                     % [uF]

% Recommended Standard Capacitor

StandardCaps = [470 1000 2200 3300 4700 6800 10000 15000];            % [uF] standard catalog values

Difference = abs(StandardCaps-Capacitance_uF);                        % [uF]

[~,Index] = min(Difference);

RecommendedCap = StandardCaps(Index);                                 % [uF]

RippleActual = Iload/(RippleFrequency*(RecommendedCap/1e6));          % [Vpp] actual ripple with standard cap

%% ==================================================
% STEP 4 : LED RESISTOR
%% ==================================================

Resistor = (EstimatedDC - Vled)/Iled;                                 % [Ohm] calculated current-limiting resistor

StandardResistors = [220 330 470 680 820 1000 1200 1500 1800 ...      % [Ohm] standard catalog values
                     2200 2700 3300 3900 4700 5600 6800 ...
                     8200 10000];

Difference = abs(StandardResistors-Resistor);                         % [Ohm]

[~,Index] = min(Difference);

RecommendedResistor = StandardResistors(Index);                       % [Ohm]

ResistorPower = Iled^2*RecommendedResistor;                           % [W]

%% ==================================================
% STEP 5 : LED PARAMETERS
%% ==================================================

LEDPower = Vled*Iled;                                                 % [W]

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
% 6. FB2027 RULEBOOK VOLTAGE COMPLIANCE CHECK  (NEW SECTION)
% Rule T11.1.2 : Max permitted LVS voltage between any two
% electrical connections = 60 VDC or 50 VAC RMS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n');
fprintf('6. FB2027 RULEBOOK VOLTAGE COMPLIANCE CHECK (T11.1.2)\n');
fprintf('-----------------------------------------------------------\n');

MaxLVS_AC = 50;   % [VAC RMS] limit per T11.1.2
MaxLVS_DC = 60;   % [VDC]     limit per T11.1.2

if Vac <= MaxLVS_AC
    fprintf('Input AC Voltage (%.2f VAC)     : PASS (limit %.0f VAC RMS)\n', Vac, MaxLVS_AC);
else
    fprintf('Input AC Voltage (%.2f VAC)     : FAIL - exceeds %.0f VAC RMS limit\n', Vac, MaxLVS_AC);
end

if EstimatedDC <= MaxLVS_DC
    fprintf('Estimated DC Output (%.2f VDC)  : PASS (limit %.0f VDC)\n', EstimatedDC, MaxLVS_DC);
else
    fprintf('Estimated DC Output (%.2f VDC)  : FAIL - exceeds %.0f VDC limit\n', EstimatedDC, MaxLVS_DC);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\n');
fprintf('===========================================================\n');
fprintf('DESIGN COMPLETE\n');
fprintf('===========================================================\n');