# -*- coding: utf-8 -*-
"""
%%  Process Sofar Spotter Data (delayed mode)
% This script processes Sofar Spotter data stored on the SD card (i.e. processes data after retrieval of buoy). 
% This requires the Sofar parser script (Python), accessible here: https://www.sofarocean.com/posts/parsing-script
% 
% The parser script will process all available data files (_FLT, _LOC, _SYS) available in a folder, however, due to computer memory issues, 
% this code chunks the data files into temporary folders and then concatenates results at the end. 
% 
% Final output files include: 
%     -bulkparameters.csv : CSV file containing wave parameters (Hs, Tp, Dp, etc.)
%     -displacements.csv: CSV file containin the raw displacements
%
% Example usage
%     MC to fill when finished
%     
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     --------------------------------------------------------
%     M. Cuttler     | 07 Sept 2020 | 1.0                      | Initial creation

"""
#%% import required modules
import numpy as np
import os
import csv
import shutil 
import xarray as xr
import netCDF4
from datetime import datetime as dt
from matplotlib import pyplot as plt

#%% set up data paths and output directories

#path for python parser script
parserpath = os.path.abspath('E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\SofarParser\parser_v1.10.0')
datapath = os.path.abspath('E:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\Data_for_testing')

#initiate utput directries 

#meta data about spotter
SpotterID = 'SPOT0171'
DeployLoc = 'Torbay'


#%% determine number of unique file numbers for chunking data into management number of files

files = os.listdir(datapath)
dum = []
[dum.append(i[0:4]) for i in files]
file_nums = np.unique(np.array(dum))

chunk_size= 10
#%% Create tmp directory for moving files to process
tmp_path = os.path.join(datapath, 'tmp')
os.mkdir(tmp_path)
shutil.copyfile(os.path.join(parserpath, 'parser_v1.10.0.py'), os.path.join(tmp_path,'parser_v1.10.0.py'))
os.chdir(tmp_path)
bulkparams = {'time':[],'hs':[],'tm':[],'tp':[],'dm':[],'dp':[],
              'meanspr':[],'pkspr':[]}
displacements = {'time':[],'x':[],'y':[],'z':[]}
locations = {'time':[],'lat':[],'lon':[]}
spec = {'time':[],'a1':np.array([]),'b1':[],'a2':[],'b2':[],
              'Sxx':[],'Syy':[],'Szz':[],'freq':[]}
#%%
for i in range(0, len(file_nums), chunk_size):
    print('Processing files ' + str(i) + ' to ' + str(i+chunk_size) + ' out of ' + str(len(file_nums)))
    chunk = file_nums[i:i+chunk_size]
    #move files in chunk to temp folder
    for j in chunk:      
        for k in files:
            if k[0:4]==j:
                shutil.copyfile(os.path.join(datapath, k), os.path.join(tmp_path, k))
    #now process
    runfile('parser_v1.10.0.py')
    
    #check whether parser generated subdirectories or not
    if os.path.exists('bulkparameters.csv')==False:
        ff = os.listdir(tmp_path)
        for checkfile in ff:
            if os.path.isdir(checkfile)==True:
                
                dum = np.loadtxt(os.path.join(tmp_path, checkfile,'bulkparameters.csv'),delimiter=',',skiprows=1)
                for j in dum:
                    bulkparams['time'].append(dt(int(j[0]),int(j[1]),int(j[2]),
                                                 int(j[3]),int(j[4]),int(j[5])))
                    bulkparams['hs'].append(j[7])
                    bulkparams['tm'].append(j[8])
                    bulkparams['tp'].append(j[9])
                    bulkparams['dm'].append(j[10])
                    bulkparams['dp'].append(j[11])
                    bulkparams['meanspr'].append(j[12])
                    bulkparams['pkspr'].append(j[13])
    
                dum = np.loadtxt(os.path.join(tmp_path, checkfile,'displacement.csv'),delimiter=',',skiprows=1)
                for j in dum:
                    displacements['time'].append(dt(int(j[0]),int(j[1]),int(j[2]),
                                            int(j[3]),int(j[4]),int(j[5])))
                    displacements['x'].append(j[7])
                    displacements['y'].append(j[8])
                    displacements['z'].append(j[9])
    
                dum = np.loadtxt(os.path.join(tmp_path, checkfile, 'location.csv'),delimiter=',',skiprows=1)
                for j in dum:
                    locations['time'].append(dt(int(j[0]),int(j[1]),int(j[2]),
                                        int(j[3]),int(j[4]),int(j[5])))
                    locations['lat'].append(j[7])
                    locations['lon'].append(j[8])    
    
                filenames = ['a1','a2','b1','b2','Sxx','Syy','Szz']
                for j,file in enumerate(filenames):
                    if j==0:            
                        f = csv.DictReader(os.path.join(tmp_path, checkfile,file+'.csv'))
                        spec['freq'] = [float(i) for i in f.fieldnames[8:]]
                        dum = np.loadtxt(os.path.join(tmp_path, checkfile,file+'.csv'),delimiter=',',skiprows=1)
                
                        for j in dum: 
                            spec['time'].append(dt(int(j[0]),int(j[1]),int(j[2]),
                                                   int(j[3]),int(j[4]),int(j[5])))
                            spec[file].append(np.array(dum[:,8:]))
            
                    else:
                        dum = np.loadtxt(os.path.join(tmp_path, checkfile,file+'.csv'),delimiter=',',skiprows=1)
                        for j,row in enumerate(dum):                            
                            spec[file] = np.append(spec[file],row[8:])
           
                        spec[file] = np.array(dum[:,8:])                                        
        
    else:
        dum = np.loadtxt('bulkparameters.csv',delimiter=',',skiprows=1)
        for j in dum:
            bulkparams['time'].append(dt(int(j[0]),int(j[1]),int(j[2]),
                                         int(j[3]),int(j[4]),int(j[5])))
            bulkparams['hs'].append(j[7])
            bulkparams['tm'].append(j[8])
            bulkparams['tp'].append(j[9])
            bulkparams['dm'].append(j[10])
            bulkparams['dp'].append(j[11])
            bulkparams['meanspr'].append(j[12])
            bulkparams['pkspr'].append(j[13])
    
        dum = np.loadtxt('displacement.csv',delimiter=',',skiprows=1)
        for j in dum:
            displacements['time'].append(dt(int(j[0]),int(j[1]),int(j[2]),
                                            int(j[3]),int(j[4]),int(j[5])))
            displacements['x'].append(j[7])
            displacements['y'].append(j[8])
            displacements['z'].append(j[9])
    
        dum = np.loadtxt('location.csv',delimiter=',',skiprows=1)
        for j in dum:
            locations['time'].append(dt(int(j[0]),int(j[1]),int(j[2]),
                                        int(j[3]),int(j[4]),int(j[5])))
            locations['lat'].append(j[7])
            locations['lon'].append(j[8])    
    
        filenames = ['a1','a2','b1','b2','Sxx','Syy','Szz']
        for j,file in enumerate(filenames):
            if j==0:            
                f = csv.DictReader(file+'.csv')
                spec['freq'] = [float(i) for i in f.fieldnames[8:]]
                dum = np.loadtxt(file+'.csv',delimiter=',',skiprows=1)
                
                for j in dum: 
                    spec['time'].append(dt(int(j[0]),int(j[1]),int(j[2]),
                                            int(j[3]),int(j[4]),int(j[5])))
                spec[file] = np.array(dum[:,8:])
            
            else:
                dum = np.loadtxt(file+'.csv',delimiter=',',skiprows=1)
                spec[file].append(dum[:,8:])
        
      
    #delete files from tmp directory
    for i in os.listdir(tmp_path):
        if i[-3:]=='csv':
            os.remove(i)
        elif i[-3:]=='CSV':
            os.remove(i)
        elif os.path.isdir(i):
            shutil.rmtree(i)
    
    %clear  
    
#delete tmp directory if last file      
print('Finished processing ' + SpotterID)
os.chdir(datapath)
shutil.rmtree(tmp_path)     

#%% quality control 
       
#%% now output dictionaries to netCDF   
ds_bulk = xr.Dataset()    
for key, val in bulkparams.items():
    x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("obstime"), name=key)
    ds_bulk = xr.merge([ds_bulk, x])

ds_disp = xr.Dataset()    
for key, val in displacements.items():
    x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("obstime"), name=key)
    ds_disp = xr.merge([ds_disp, x])

ds_locs = xr.Dataset()    
for key, val in locations.items():
    x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("obstime"), name=key)
    ds_locs = xr.merge([ds_locs, x])

ds_spec = xr.Dataset()
for key, val in spec.items():
    if key == 'time':       
        x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("obstime"), name=key)    
    elif key == 'freq':
        x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("frequency"), name=key)
    else:
        time = spec['time']
        freq = spec['freq']
        x = xr.DataArray(val, coords=[time, freq], dims=("obstime", "frequency"), name=key)
        
    

                
    
