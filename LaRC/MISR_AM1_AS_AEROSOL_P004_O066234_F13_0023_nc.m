%
% This example code illustrates how to access and visualize LaRC MISR 
% AM1 AS AEROSOL netCDF-4 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MISR_AM1_AS_AEROSOL_P004_O066234_F13_0023_nc
%
% Tested under: MATLAB R2017a
% Last updated: 2018-09-07


clear

import matlab.io.hdf5.*

% Open file.
FILE_NAME='MISR_AM1_AS_AEROSOL_P004_O066234_F13_0023.nc';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Read data.
data_NAME='4.4_KM_PRODUCTS/Aerosol_Optical_Depth';
data_id=H5D.open(file_id, data_NAME);
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read the fill value attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue=H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');

% Read units attribute.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read long_name attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read latitude.
Lat_NAME='4.4_KM_PRODUCTS/Latitude';
lat_id=H5D.open(file_id, Lat_NAME);
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read longitude.
Lon_NAME='4.4_KM_PRODUCTS/Longitude';
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

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');
axesm('MapProjection','eqdcylin', 'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south');
% Load the coastlines data file.
coast = load('coast.mat');

% Plot coastlines in color black ('k').
plotm(coast.lat,coast.long,'k');

tightmap;

% Plot data.
surfm(lat, lon, data);

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
