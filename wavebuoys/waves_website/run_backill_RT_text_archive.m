%run backfill
clear; clc;
site = 'BremerCanyon_Drifting'; 
data_path = 'E:\wawaves'; 
backfill_RT_text_archive(data_path, site); 
%%