# -*- coding: utf-8 -*-
"""
Created on Tue May 25 12:30:42 2021

Compare Tantabiddi DoT (Datawell) with Tantabiddi UWA (Spotter)

@author: 00084142
"""
#%% import packages
import os
os.chdir(r'G:\CUTTLER_GitHub\wavebuoy_tools\pybuoy')
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from matplotlib import gridspec
from datetime import datetime
from toolsMC import buoy_data
from toolsMC import buoy_tools
#%% pull in Tantabiddi DoT
datapath = r'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\Datawell\Raw\Tantabiddi data UWA\Wave Parameters'
dot = buoy_data.import_WA_DoT(datapath)
#assume dot in local time? 
dot_time = [datetime.strptime(t,'%d/%m/%Y %H:%M') for t in dot.iloc[:,0]]
dot['datetime']=dot_time


#%% pull in Tantabiddi UWA
datapath = r'Y:\CUTTLER_wawaves\Data\realtime_archive_backup'
uwa = buoy_data.load_buoy_text_archive('Tantabiddi',datapath)
#convert to local time - without defining TZ this takes computer's local time
uwa_time = [datetime.fromtimestamp(t) for t in uwa.iloc[:,0]]
uwa['datetime']=uwa_time
uwa = uwa.reset_index(drop=True)

#%% get corresponding times
ind = buoy_tools.match_times(uwa_time, dot_time)
dot = dot.iloc[ind,:]
dot = dot.reset_index(drop=True)

#%% plot Hsig

fig = plt.figure(figsize=(12,6))
spec = gridspec.GridSpec(ncols=2, nrows=2, width_ratios=[2,1])
ax0 = fig.add_subplot(spec[0,0])
ax0.plot(dot['datetime'],dot['Hs(m)'],'b-')
ax0.plot(uwa['datetime'][uwa[' QF_waves']==1],uwa[' Hsig (m)'][uwa[' QF_waves']==1],'r-')
ax0.grid('on')
ax0.set(xlabel = 'Time', ylabel = 'H_sig (m)')
ax0.legend(['DoT Datawell', 'UWA Spotter'])
ax0.text(0.05, 0.95, '(a)', horizontalalignment='center', verticalalignment='center', transform=ax0.transAxes)

ax1 = fig.add_subplot(spec[0,1])
ax1.plot(dot['Hs(m)'][uwa[' QF_waves']==1], uwa[' Hsig (m)'][uwa[' QF_waves']==1],'k.')
ax1.grid('on')
ax1.plot([0, 3.5],[0, 3.5],'c-')
ax1.set(xlabel = 'Datawell H_sig (m)',ylabel='Spotter H_sig (m)',xlim=(0,3.5),ylim=(0,3.5))
ax1.text(0.05, 0.95, '(b)', horizontalalignment='center', verticalalignment='center', transform=ax1.transAxes)

ax2 = fig.add_subplot(spec[1,0])
ax2.plot(dot['datetime'],dot['oC'],'b-')
ax2.plot(uwa['datetime'][uwa[' QF_sst']==1],uwa[' SST (degC)'][uwa[' QF_sst']==1],'r-')
ax2.grid('on')
ax2.set(xlabel ='Time', ylabel = 'Surface Temp (degC)',ylim=(22,31))
ax2.text(0.02, 0.95, '(c)', horizontalalignment='center', verticalalignment='center', transform=ax2.transAxes)

ax3 = fig.add_subplot(spec[1,1])
ax3.plot(dot['oC'][uwa[' QF_sst']==1], uwa[' SST (degC)'][uwa[' QF_sst']==1],'k.')
ax3.grid('on')
ax3.plot([22, 31],[22, 31],'c-')
ax3.set(xlabel = 'Datawell SST (degC)',ylabel='Spotter SST (degC)',xlim=(22,31),ylim=(22,31))
ax3.text(0.05, 0.95, '(d)', horizontalalignment='center', verticalalignment='center', transform=ax3.transAxes)

figpath = r'E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\Datawell\Figures'
fig.savefig(os.path.join(figpath,'Tantabiddi_test.png'),format='png',dpi=120, )
