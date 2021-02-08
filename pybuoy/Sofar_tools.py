# -*- coding: utf-8 -*-
"""
Created on Thu Feb  4 20:39:43 2021

@author: 00084142
"""

#%% Tools for Sofar wave buoys
import requests
import json 


#%% 

def get_spotter_realtime(buoy_info):
    """    
    Parameters
    ----------
    buoy_info : dict
        contains meta-data on buoy of interest. including serial (SpotterID), and 
        parameters to include for GET request

    Returns
    -------
    SpotData : disct
        most recent data from Sofar API for buoy of interest.

    """
    head={'token': buoy_info['token'],'spotterId': buoy_info['SpotterID']}
    parameters = {'limit': buoy_info['limit'],'includeWaves':buoy_info['includeWaves'],
                  'includeWindData':buoy_info['includeWindData'],
                  'includeSurfaceTempData':buoy_info['includeSurfaceTempData']}
    response = requests.get('https://api.sofarocean.com/api/wave-data?spotterId='+buoy_info['SpotterID'], 
                            headers=head, params=parameters)
    
    #extract JSON string to dictionary
    raw_json = response.json()
    dumdata = raw_json['data']
    
    #loop through and build into numpy arrays
    
    
    return SpotData 
