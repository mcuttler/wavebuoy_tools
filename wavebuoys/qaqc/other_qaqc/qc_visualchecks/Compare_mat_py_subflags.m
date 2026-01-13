
%load and compare subflag values from Matlab and Python delayed mode
%procesing

close all
clear all

% load py subflags temperature

cd('Y:\CUTTLER_wawaves\Data\wawaves\OceanBeach\delayedmode\OceanBeach_deploy20240701_retrieve20241205_SPOT-31395C\processed_py')

py_temp_subflags = readtable('temp_qc_subflags.csv');
py_bulk_subflags = readtable('bulk_qc_subflags.csv');


% load mat subflags temperature


cd('C:\Users\00104893\LocalDocuments\Projects\Wave buoys\Spotters\data\OceanBeach_deploy20240701_retrieve20241205_SPOT31395C\processed')

mat_temp_subflags = readtable('temp_qc_subflags.csv');
mat_bulk_subflags = readtable('bulk_qc_subflags.csv');

pyvarnames=py_temp_subflags.Properties.VariableNames;
matvarnames=mat_temp_subflags.Properties.VariableNames;


% plot difference in primary wave flag py to mat




% PLOT TEMPS

figure()
subplot(4,1,1)
scatter(py_temp_subflags.TIME_TEMP,py_temp_subflags.TEMP)
hold on
scatter(mat_temp_subflags.TIME_TEMP,mat_temp_subflags.TEMP,'k.')
title('temperature')
xlabel('time')
ylabel ('temp degC')
legend('py','mat')

subplot(4,1,2)
scatter(py_temp_subflags.TIME_TEMP,py_temp_subflags.TEMP_quality_control)
hold on
scatter(mat_temp_subflags.TIME_TEMP,mat_temp_subflags.TEMP_quality_control,'k.')
title(string(matvarnames(3)))
xlabel('time')
ylabel ('flag value')
ylim([0 5])
legend('py','mat')

subplot(4,1,3)
scatter(py_temp_subflags.TIME_TEMP,py_temp_subflags.TEMP_QC_TEMP_gross_range_test)
hold on
scatter(mat_temp_subflags.TIME_TEMP,mat_temp_subflags.TEMP_QC_TEMP_gross_range_test,'k.')
title(string(matvarnames(4)))
xlabel('time')
ylabel ('flag value')
ylim([0 5])
legend('py','mat')

subplot(4,1,4)
scatter(py_temp_subflags.TIME_TEMP,py_temp_subflags.TEMP_QC_TEMP_rate_of_change_test)
hold on
scatter(mat_temp_subflags.TIME_TEMP,mat_temp_subflags.TEMP_QC_TEMP_rate_of_change_test,'k.')
title(string(matvarnames(5)))
xlabel('time')
ylabel ('flag value')
ylim([0 5])
legend('py','mat')

figure()
subplot(3,1,1)
scatter(py_temp_subflags.TIME_TEMP,py_temp_subflags.TEMP_QC_TEMP_flat_line_test)
hold on
scatter(mat_temp_subflags.TIME_TEMP,mat_temp_subflags.TEMP_QC_TEMP_flat_line_test,'k.')
title(string(matvarnames(6)))
xlabel('time')
ylabel ('flag value')
ylim([0 5])
legend('py','mat')


subplot(3,1,2)
scatter(py_temp_subflags.TIME_TEMP,py_temp_subflags.TEMP_QC_TEMP_mean_std_test)
hold on
scatter(mat_temp_subflags.TIME_TEMP,mat_temp_subflags.TEMP_QC_TEMP_mean_std_test,'k.')
title(string(matvarnames(7)))
xlabel('time')
ylabel ('flag value')
ylim([0 5])
legend('py','mat')


subplot(3,1,3)
scatter(py_temp_subflags.TIME_TEMP,py_temp_subflags.TEMP_QC_TEMP_spike_test)
hold on
scatter(mat_temp_subflags.TIME_TEMP,mat_temp_subflags.TEMP_QC_TEMP_spike_test,'k.')
title(string(matvarnames(8)))
xlabel('time')
ylabel ('flag value')
ylim([0 5])
legend('py','mat')


% bulkparameter plots

% var names from the CSV's
pyvarnames=py_bulk_subflags.Properties.VariableNames;
matvarnames=mat_bulk_subflags.Properties.VariableNames;

% plots of DATA 
figure()
subplot(4,1,1)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WSSH)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WSSH,'k.')
title(matvarnames(2))
xlabel('time')
ylabel ('hs [m]')
legend('py','mat')

subplot(4,1,2)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WPFM)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WPFM,'k.')
title(matvarnames(3))
xlabel('time')
ylabel ('mean period [s]')
legend('py','mat')



subplot(4,1,3)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WPPE)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WPPE,'k.')
title(matvarnames(4))
xlabel('time')
ylabel ('peak period [s]')
legend('py','mat')


subplot(4,1,4)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.SSWMD)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.SSWMD,'k.')
title(matvarnames(5))
xlabel('time')
ylabel ('mean direction [deg]')
legend('py','mat')

% new figures
%plots of data and primary flag

figure()
subplot(4,1,1)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WPDI)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WPDI,'k.')
title(matvarnames(6))
xlabel('time')
ylabel ('peak dired [deg]')
legend('py','mat')

subplot(4,1,2)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WMDS)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WMDS,'k.')
title(matvarnames(7))
xlabel('time')
ylabel ('mead direc spread [deg]')
legend('py','mat')



subplot(4,1,3)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WPDS)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WPDS,'k.')
title(matvarnames(8))
xlabel('time')
ylabel ('peak direc spread [deg]')
legend('py','mat')


subplot(4,1,4)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_quality_control)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_quality_control,'k.')
title(matvarnames(11))
xlabel('time')
ylabel ('WAVE QC primary flag [flag value]')
legend('py','mat')


% new figures
%PLOTS of WSSH subflags

figure()
subplot(4,1,1)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WSSH_gross_range_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WSSH_gross_range_test,'k.')
title(matvarnames(12))
xlabel('time')
ylabel('flag value')
legend('py','mat')

subplot(4,1,2)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WSSH_rate_of_change_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WSSH_rate_of_change_test,'k.')
title(matvarnames(13))
xlabel('time')
ylabel ('flag value')
legend('py','mat')

subplot(4,1,3)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WSSH_mean_std_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WSSH_mean_std_test,'k.')
title(matvarnames(14))
xlabel('time')
ylabel ('flag value')
legend('py','mat')

subplot(4,1,4)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WSSH_spike_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WSSH_spike_test,'k.')
title(matvarnames(15))
xlabel('time')
ylabel ('flag value')
legend('py','mat')



% new figures
% PLOTS of WPPE subflags

figure()
subplot(4,1,1)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WPPE_gross_range_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WPPE_gross_range_test,'k.')
title(matvarnames(16))
xlabel('time')
ylabel('flag value')
legend('py','mat')

subplot(4,1,2)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WPPE_rate_of_change_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WPPE_rate_of_change_test,'k.')
title(matvarnames(17))
xlabel('time')
ylabel ('flag value')
legend('py','mat')

subplot(4,1,3)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WPPE_mean_std_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WPPE_mean_std_test,'k.')
title(matvarnames(18))
xlabel('time')
ylabel ('flag value')
legend('py','mat')

subplot(4,1,4)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WPPE_spike_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WPPE_spike_test,'k.')
title(matvarnames(19))
xlabel('time')
ylabel ('flag value')
legend('py','mat')

% new figures
% PLOTS of WPDI subflags

figure()
subplot(4,1,1)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WPDI_gross_range_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WPDI_gross_range_test,'k.')
title(matvarnames(20))
xlabel('time')
ylabel('flag value')
legend('py','mat')

subplot(4,1,2)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WPDI_rate_of_change_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WPDI_rate_of_change_test,'k.')
title(matvarnames(21))
xlabel('time')
ylabel ('flag value')
legend('py','mat')

subplot(4,1,3)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WPDI_mean_std_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WPDI_mean_std_test,'k.')
title(matvarnames(22))
xlabel('time')
ylabel ('flag value')
legend('py','mat')

subplot(4,1,4)
scatter(py_bulk_subflags.TIME,py_bulk_subflags.WAVE_QC_WPDI_spike_test)
hold on
scatter(mat_bulk_subflags.TIME,mat_bulk_subflags.WAVE_QC_WPDI_spike_test,'k.')
title(matvarnames(23))
xlabel('time')
ylabel ('flag value')
legend('py','mat')

