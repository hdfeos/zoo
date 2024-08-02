%
% This example code illustrates how to access and visualize LAADS
% VNP14IMG v2 NetCDF-4/HDF5 Swath file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r VNP14IMG_A2018064_1200_002_2024079084304_nc
%
% Tested under: MATLAB R2023b
% Last updated: 2024-08-01


clear

import matlab.io.hdfeos.*
import matlab.io.hdf5.*

% Open file.
FILE_NAME='VNP14IMG.A2018064.1200.002.2024079084304.nc';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Read data.
data_NAME='FP_T5';
data_id=H5D.open(file_id, data_NAME);
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read units attribute.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read long_name attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read latitude.
Lat_NAME='FP_latitude';
lat_id=H5D.open(file_id, Lat_NAME);
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read longitude.
Lon_NAME='FP_longitude';
lon_id=H5D.open(file_id, Lon_NAME);
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Close ids.
H5A.close (attr_id)
H5D.close(data_id);
H5D.close(lat_id);
H5D.close(lon_id);
H5F.close(file_id);

% Convert type.
lat = double(lat);
lon = double(lon);
data = double(data);

% Set center lat/lon point for Ortho map.
[xdimsize, ydimsize] = size(data);
% xdimsize is odd number - 8375.
lon_c = lon((xdimsize+1)/2);
lat_c = lat((xdimsize+1)/2);

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');


% Use Ortho global map.
% FlatLimit will give us a zoom-in effect in Ortho projection.
axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'origin', [lat_c, lon_c]);
mlabel('equator');
plabel(0); 
plabel('fontweight','bold');

% Load the coastlines data file.
coast = load('coastlines.mat');

% Plot coastlines in color black ('k').
plotm(coast.coastlat, coast.coastlon, 'k');

% Plot data.
scatterm(lat, lon, 1, data);

% Put colormap.
colormap('Jet');
h=colorbar();
units_str = sprintf('%s', char(units));
set (get(h, 'title'), 'string', units_str);

long_name_str = sprintf('%s', char(long_name));

% Set the title using long_name.
title({FILE_NAME;long_name_str}, 'Interpreter', 'none', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
