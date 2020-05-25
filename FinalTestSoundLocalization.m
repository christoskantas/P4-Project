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
s3 = cos(2*pi*t*400);
s4 = cos(2*pi*t*500);
s5 = cos(2*pi*t*200);

%%% Signal 1
sig1 = collectPlaneWave(sphArray,[s1],[10 0]',fc);
noise1 = 0.1*(randn(size(sig1)) + 1i*randn(size(sig1)));

signal1 = sig1 + noise1;

%%% Signal 2
sig2 = collectPlaneWave(sphArray,[s1 s2],[5 0; 50 0]',fc);
noise2 = 0.1*(randn(size(sig2)) + 1i*randn(size(sig2)));

signal2 = sig2 + noise2;

%%% Signal 3
sig3 = collectPlaneWave(sphArray,[s1 s2 s3],[-40 0; -10 0; 20 0]',fc);
noise3 = 0.1*(randn(size(sig3)) + 1i*randn(size(sig3)));

signal3 = sig3 + noise3;

%%% Signal 4
sig4 = collectPlaneWave(sphArray,[s1 s2 s3 s4],[-65 0; -55 0; 35 0; 70 0]',fc);
noise4 = 0.1*(randn(size(sig4)) + 1i*randn(size(sig4)));

signal4 = sig4 + noise4;

%% Signal 5
sig5 = collectPlaneWave(sphArray,[s1 s2 s3 s4 s5],[-80 0; -70 0; 0 0; 25 0; 45 0]',fc);
noise5 = 0.1*(randn(size(sig5)) + 1i*randn(size(sig5)));

signal5 = sig5 + noise5;

%% Sound Localization
signal_to_localize = signal5;

%%% Root MUSIC Method
rootmusicangle = phased.RootMUSICEstimator('SensorArray',sphArray,...
            'OperatingFrequency',fc,...
            'NumSignalsMethod','AIC','ForwardBackwardAveraging',true);
ROOTMUSICdoas = rootmusicangle(signal_to_localize)
ROOTMUSICdoas = broadside2az(ROOTMUSICdoas)
