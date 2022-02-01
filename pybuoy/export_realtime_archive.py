# -*- coding: utf-8 -*-
"""
Created on Thu Jan 27 11:01:14 2022

@author: 00084142
"""

#%% import modules
import glob
import os
import numpy as np
import pandas as pd
from datetime import datetime, timedelta

#%% 
sp = r'I:\Active_Projects\CUTTLER_wawaves\Data\wawaves\Tantabiddi\text_archive'
files = glob.glob(os.path.join(sp,'**','*.csv'),recursive=True)

for i, file in enumerate(files):
    dum = pd.read_csv(file)
    if i == 0:
        data = dum
    else:
        data = data.append(dum)
    
data = data.reset_index(drop=True).set_index('Time (UNIX/UTC)')

outpath = r'I:\Active_Projects\CUTTLER_wawaves\Data\DataExports_for_Users'
data.to_csv(os.path.join(outpath,'Tantabiddi.csv'))
