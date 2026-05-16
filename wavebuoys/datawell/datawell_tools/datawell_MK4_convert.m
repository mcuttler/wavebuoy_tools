%Datawell_MK4_convert.m
%Convert Datawell Waverider Mk4 binary BVA files to csv files.
%Requires Datawell executables from libdatawell
clear; close all; clc;
%addpath(genpath('C:\Program Files\libdatawell 0.36.0'));
pth='X:\CUTTLER_wawaves\Data\wawaves\Winderbandi\delayedmode\Winderbandi_deploy20260319_retrieve20260404_74089\';
cd(pth)
files=dir((fullfile(pth,'*.BVA'))); 

exe1 = ['p:\HANSEN_UWA-UNSW_Linkage\Data\Waves_WaterLevels\DOT_waves\libdatawell_0.36.1\bin\bva_to_hva'];
exe2 = ['p:\HANSEN_UWA-UNSW_Linkage\Data\Waves_WaterLevels\DOT_waves\libdatawell_0.36.1\bin\decode_hva'];

if ~exist([pth,'CSV_export'])
    disp(['Making directory: ',pth,'CSV_export'])
    mkdir([pth,'CSV_export'])
end

for jj=1:size(files,1)
    yr=files(jj).name(1:4);
    mm=files(jj).name(5:6);
    dd=files(jj).name(7:8);
    fname=[pth files(jj).name];
    f_out=[pth 'CSV_export\' yr '_' mm '_' dd ];
    %
    %bva_to_hva fname.bva | decode_hva -fcsv -o fname-%s.csv
    dos([exe1 ' '  fname ' | ' exe2 ' -fcsv -o ' f_out '-%s.csv'])
end

