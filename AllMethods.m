% Sound Simulation and Localization

%% Initialization
close all
clear
clc

%% Setup
%%% Linear Microphone Array
N = 8;              % Number of elements
R = 0.042;          % Spacing (m)
microphone = phased.OmnidirectionalMicrophoneElement('FrequencyRange',[20 20e3]);
sphArray = phased.ULA(N,R,'Element',microphone);

%%% Settings
fc = 1e9;                          % Operating frequency
fs = 8000;                          % Sampling frequency (Hz)
c = 343;       % Sound velocity (m/s)

%% Sound Simulation
t = (0:1/fs:1).';
s1 = cos(2*pi*t*300);
s2 = cos(2*pi*t*600);

%%% Signal 1
sig1 = collectPlaneWave(sphArray,[s1 s2],[-45 0; 45 0]',fc);
noise1 = 0.1*(randn(size(sig1)) + 1i*randn(size(sig1)));

signal1 = sig1 + noise1;

%%% Signal 2
sig2 = collectPlaneWave(sphArray,[s1 s2],[30 0; 60 0]',fc);
noise2 = 0.1*(randn(size(sig2)) + 1i*randn(size(sig2)));

signal2 = sig2 + noise2;

%%% Signal 3
sig3 = collectPlaneWave(sphArray,[s1 s2],[65 0; 80 0]',fc);
noise3 = 0.1*(randn(size(sig3)) + 1i*randn(size(sig3)));

signal3 = sig3 + noise3;

%%% Signal 4
sig4 = collectPlaneWave(sphArray,[s1 s2],[10 0; 15 0]',fc);
noise4 = 0.1*(randn(size(sig4)) + 1i*randn(size(sig4)));

signal4 = sig4 + noise4;

%% Sound Localization
signal_to_localize = signal1;
num_of_signals = 2;

%%% Root MUSIC Method
rootmusicangle = phased.RootMUSICEstimator('SensorArray',sphArray,...
            'OperatingFrequency',fc,...
            'NumSignalsSource','Property','NumSignals',num_of_signals,'ForwardBackwardAveraging',true);
ROOTMUSICdoas = rootmusicangle(signal_to_localize);
ROOTMUSICdoas = broadside2az(sort(ROOTMUSICdoas),[0 0])

%%% MUSIC Method
musicangle = phased.MUSICEstimator('SensorArray',sphArray,...
             'OperatingFrequency',fc,'ForwardBackwardAveraging',true,...
             'NumSignalsSource','Property','NumSignals',num_of_signals,...
             'DOAOutputPort',true);

[y2,MUSICdoas] = musicangle(signal_to_localize);
MUSICdoas = broadside2az(sort(MUSICdoas),[0 0])

%%% Root WSF Method
rootwsfangle = phased.RootWSFEstimator('SensorArray',sphArray,...
          'OperatingFrequency',fc,'MaximumIterationCount',2);
ROOTWSFdoas = rootwsfangle(signal_to_localize);
%ROOTWSFdoas = broadside2az(sort(ROOTWSFdoas),[0 0])

%%% ESPRIT Method
espritangle = phased.ESPRITEstimator('SensorArray',sphArray,...
             'OperatingFrequency',fc,'ForwardBackwardAveraging',true,...
             'NumSignalsSource','Property','NumSignals',num_of_signals);
ESPRITdoas = espritangle(signal_to_localize);
ESPRITdoas = broadside2az(sort(ESPRITdoas),[0 0])

%%% Beamspace ESPRIT Method
beamspaceespritangle = phased.BeamspaceESPRITEstimator('SensorArray',sphArray, ...
    'OperatingFrequency',fc,'NumSignalsSource','Property','NumSignals',num_of_signals);
bsESPRITdoas = beamspaceespritangle(signal_to_localize);
%bsESPRITdoas = broadside2az(sort(bsESPRITdoas),[0 0])

%%% Beamscan Method
beamscanangle = phased.BeamscanEstimator('SensorArray',sphArray,...
            'OperatingFrequency',fc,'ScanAngles',-90:90,...
            'DOAOutputPort',true,'NumSignals',num_of_signals);    
[y3,BSdoas] = beamscanangle(signal_to_localize);
%BSdoas = broadside2az(sort(BSdoas),[0 0])

%%% MVDR Method
mvdrangle = phased.MVDREstimator('SensorArray',sphArray,...
        'OperatingFrequency',fc,'ScanAngles',-90:90,...
        'DOAOutputPort',true,'NumSignals',num_of_signals);
[y4,MVDRdoas] = mvdrangle(signal_to_localize);
%MVDRdoas = broadside2az(sort(MVDRdoas),[0 0])

%% Plot

%figure(4)
%plotSpectrum(mvdrangle,'NormalizeResponse', true)

%figure(3)
%plotSpectrum(beamscanangle,'NormalizeResponse',true)

figure(1)
plotSpectrum(musicangle,'NormalizeResponse',true)

%figure(1)
%viewArray(sphArray,'ShowIndex','All','ShowNormals',true,'Title','Uniform Linear Array (ULA)')
%view(0,90)





