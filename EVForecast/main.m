clear all;
clc;
close all;
pass = pwd;
y_pred = getEVModel([pwd,'\','10. VST_YYYYMMDDHHMM.csv'],...
                        [pwd,'\','11. VFP_YYYYMMDDHHMM.csv'],...
                        [pwd,'\','ResultData.csv'])