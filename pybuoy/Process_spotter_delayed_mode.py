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
    M. Cuttler      | 30 Novemeber 2020 | 2.0

"""
#%% import required modules
import numpy as np
import pandas as pd
import os
import shutil 
import xarray as xr
import glob 
from datetime import datetime, timedelta
from matplotlib import pyplot as plt
import scipy.io

#%% set up data paths and output directories
#path for python parser script
parserpath = r'G:\Active_Projects\LOWE_IMOS_WaveBuoys\Data\SofarSpotter\SofarParser\parser_v1.12.0'
parser = 'parser_v1.12.0.py'

dpath = r'G:\Active_Projects\CUTTLER_wawaves\Data\wawaves'
site = 'TorbayWest'

#get list of delayed mode data to process
folders = os.listdir(os.path.join(dpath,site,'delayedmode'))

#spotters to process
buoyID = []
for folder in folders:
    buoyID.append(folder[-8:])

#%% sofar date parser
def sofar_date_parser(x1,x2,x3,x4,x5,x6,x7):
    t = datetime(int(x1),int(x2),int(x3),int(x4),int(x5),int(x6))+timedelta(seconds=float(x7)/1000)
    return t

#%% go through each buoy 
for f, buoy in enumerate(buoyID):
    outpath = os.path.join(dpath,site,'delayedmode',folders[f])
    datapath = os.path.join(outpath,'Raw')  
    files = os.listdir(datapath)
    dum = []
    [dum.append(i[0:4]) for i in files]
    file_nums = np.unique(np.array(dum))
    chunk_size= 10

    #Create tmp directory for moving files to process
    tmp_path = os.path.join(datapath, 'tmp')
    os.mkdir(tmp_path)
    shutil.copyfile(os.path.join(parserpath, parser), os.path.join(tmp_path,parser))

    #### change directory and run parser
    os.chdir(tmp_path)
    for i in range(0, len(file_nums), chunk_size):
        print('Processing files ' + str(i) + ' to ' + str(i+chunk_size) + ' out of ' + str(len(file_nums)))
        chunk = file_nums[i:i+chunk_size]
        #move files in chunk to temp folder
        for j in chunk:      
            for k in files:
                if k[0:4]==j:
                    shutil.copyfile(os.path.join(datapath, k), os.path.join(tmp_path, k))
        #now process
        try:
            runfile(os.path.join(tmp_path,parser))
            if os.path.exists('error.txt'):
                flag=0
            else:
                flag=1
        except:
            flag=0        
        
        if flag == 1:
            #check whether parser generated subdirectories or not
            if os.path.exists('bulkparameters.csv')==False:
                ff = os.listdir(tmp_path)
                for checkfile in ff:
                    if os.path.isdir(checkfile)==True:
                        
                        dumblk = pd.read_csv(os.path.join(tmp_path, checkfile,'bulkparameters.csv'),
                                     parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
    
                        dumdisp = pd.read_csv(os.path.join(tmp_path, checkfile,'displacement.csv'),
                                      parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                
                        dumloc = pd.read_csv(os.path.join(tmp_path, checkfile, 'location.csv'),
                                     parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser) 
                        duma1 = pd.read_csv(os.path.join(tmp_path,checkfile,'a1.csv'),
                                    parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                        duma2 = pd.read_csv(os.path.join(tmp_path,checkfile,'a2.csv'),
                                    parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                        dumb1 = pd.read_csv(os.path.join(tmp_path,checkfile,'b1.csv'),
                                    parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                        dumb2 = pd.read_csv(os.path.join(tmp_path,checkfile,'b2.csv'),
                                    parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                        dumSxx = pd.read_csv(os.path.join(tmp_path,checkfile,'Sxx.csv'),
                                     parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                        dumSyy = pd.read_csv(os.path.join(tmp_path,checkfile,'Syy.csv'),
                                     parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                        dumSzz = pd.read_csv(os.path.join(tmp_path,checkfile,'Szz.csv'),
                                     parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                        if os.path.exists('sst.csv'):
                            dumsst = pd.read_csv(os.path.join(tmp_path,checkfile,'sst.csv'),
                                     parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)                                                      
            else:
                dumblk = pd.read_csv('bulkparameters.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)          
                dumdisp = pd.read_csv('displacement.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)            
                dumloc = pd.read_csv('location.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)    
                duma1 = pd.read_csv('a1.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                duma2 = pd.read_csv('a2.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                dumb1 = pd.read_csv('b1.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                dumb2 = pd.read_csv('b2.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                dumSxx = pd.read_csv('Sxx.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                dumSyy = pd.read_csv('Syy.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                dumSzz = pd.read_csv('Szz.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)
                if os.path.exists('sst.csv'):
                    dumsst = pd.read_csv('sst.csv',parse_dates=[[0,1,2,3,4,5,6]],date_parser=sofar_date_parser)              
    
            try:
                bulkparams = pd.concat([bulkparams,dumblk],ignore_index=True)
                displacements = pd.concat([displacements,dumdisp],ignore_index=True)
                locations = pd.concat([locations,dumloc],ignore_index=True)
                a1 = pd.concat([a1,duma1],ignore_index=True)
                a2 = pd.concat([a2,duma2],ignore_index=True)
                b1 = pd.concat([b1,dumb1],ignore_index=True)
                b2 = pd.concat([b2,dumb2],ignore_index=True)
                Sxx = pd.concat([Sxx,dumSxx],ignore_index=True)
                Syy = pd.concat([Syy,dumSyy],ignore_index=True)
                Szz = pd.concat([Szz,dumSzz],ignore_index=True)
                if os.path.exists('sst.csv'):
                    sst = pd.concat([sst,dumsst],ignore_index=True) 
              
            except:
                bulkparams = dumblk
                displacements = dumdisp
                locations = dumloc
                a1 = duma1
                a2 = duma2
                b1 = dumb1
                b2 = dumb2
                Sxx = dumSxx
                Syy = dumSyy
                Szz = dumSzz
                if os.path.exists('sst.csv'):
                    sst = dumsst                           
      
        #delete files from tmp directory
        for l in os.listdir(tmp_path):
            if l[-3:]=='csv':
                os.remove(l)
            elif l[-3:]=='CSV':
                os.remove(l)
            elif os.path.isdir(l):
                shutil.rmtree(l)   
            elif l[-3:]=='txt':
                os.remove(l)
    
    #delete tmp directory if last file      
    print('Finished processing ' + folders[f] + ' --- now exporting')

    #clean up for export
    os.chdir(outpath)
    shutil.rmtree(tmp_path)
    ############# BULKPARAMS ###############################################
    bulkparams = bulkparams.rename(columns={bulkparams.columns[0]:'time'})
    bulkparams = bulkparams.set_index('time').tz_localize(tz='UTC')
    # bulkparams.to_csv(os.path.join(outpath,buoy+'_bulkparams_test.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    bulkparams.to_csv(os.path.join(outpath,buoy+'_bulkparams.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del bulkparams
    ########### DISPLACEMENTS ################################################
    displacements = displacements.rename(columns={displacements.columns[0]:'time'})
    displacements = displacements.set_index('time').tz_localize(tz='UTC')
    displacements.to_csv(os.path.join(outpath,buoy+'_displacements.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del displacements
    ########### LOCATIONS ######################################################
    locations = locations.rename(columns={locations.columns[0]:'time'})
    locations = locations.set_index('time').tz_localize(tz='UTC')
    locations.to_csv(os.path.join(outpath,buoy+'_locations.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del locations
    ############ A1 ###########################################################
    a1 = a1.rename(columns={a1.columns[0]:'time'})
    a1 = a1.set_index('time').tz_localize(tz='UTC')
    a1.to_csv(os.path.join(outpath,buoy+'_a1.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del a1
    ############ A2 ###########################################################
    a2 = a2.rename(columns={a2.columns[0]:'time'})
    a2 = a2.set_index('time').tz_localize(tz='UTC')
    a2.to_csv(os.path.join(outpath,buoy+'_a2.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del a2
    ############ b1 ###########################################################
    b1 = b1.rename(columns={b1.columns[0]:'time'})
    b1 = b1.set_index('time').tz_localize(tz='UTC')
    b1.to_csv(os.path.join(outpath,buoy+'_b1.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del b1
    ############ b2 ###########################################################
    b2 = b2.rename(columns={b2.columns[0]:'time'})
    b2 = b2.set_index('time').tz_localize(tz='UTC')
    b2.to_csv(os.path.join(outpath,buoy+'_b2.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del b2
    ############ Sxx ###########################################################
    Sxx = Sxx.rename(columns={Sxx.columns[0]:'time'})
    Sxx = Sxx.set_index('time').tz_localize(tz='UTC')
    Sxx.to_csv(os.path.join(outpath,buoy+'_Sxx.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del Sxx
    ############ Syy ###########################################################
    Syy = Syy.rename(columns={Syy.columns[0]:'time'})
    Syy = Syy.set_index('time').tz_localize(tz='UTC')
    Syy.to_csv(os.path.join(outpath,buoy+'_Syy.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del Syy
    ############ Szz ###########################################################
    Szz = Szz.rename(columns={Szz.columns[0]:'time'})
    Szz = Szz.set_index('time').tz_localize(tz='UTC')
    Szz.to_csv(os.path.join(outpath,buoy+'_Szz.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
    del Szz
    ############ SST ###########################################################
    try:
        sst = sst.rename(columns={sst.columns[0]:'time'})
        sst = sst.set_index('time').tz_localize(tz='UTC')
        sst.to_csv(os.path.join(outpath,buoy+'_sst.csv'),date_format='%Y-%m-%d %H:%M:%S.%f%z')
        del sst
    except:
        continue

    
#%% quality control 
       
#%% now output dictionaries to netCDF   
# ds_bulk = xr.Dataset()    
# for key, val in bulkparams.items():
#     x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("obstime"), name=key)
#     ds_bulk = xr.merge([ds_bulk, x])

# ds_disp = xr.Dataset()    
# for key, val in displacements.items():
#     x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("obstime"), name=key)
#     ds_disp = xr.merge([ds_disp, x])

# ds_locs = xr.Dataset()    
# for key, val in locations.items():
#     x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("obstime"), name=key)
#     ds_locs = xr.merge([ds_locs, x])

# ds_spec = xr.Dataset()
# for key, val in spec.items():
#     if key == 'time':       
#         x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("obstime"), name=key)    
#     elif key == 'freq':
#         x = xr.DataArray(val, coords=[list(range(0, len(val)))], dims=("frequency"), name=key)
#     else:
#         time = spec['time']
#         freq = spec['freq']
#         x = xr.DataArray(val, coords=[time, freq], dims=("obstime", "frequency"), name=key)
        
    

                
    
