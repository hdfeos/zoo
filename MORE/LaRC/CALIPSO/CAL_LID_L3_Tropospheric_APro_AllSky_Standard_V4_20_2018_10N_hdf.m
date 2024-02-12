%
%  This example code illustrates how to access and visualize LaRC CALIPSO Lidar
% Level 3 Version 4 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS  Comprehensive Examples 
% page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum 
% (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r CAL_LID_L3_Tropospheric_APro_AllSky_Standard_V4_20_2018_10N_hdf
%
% Tested under: MATLAB R2021a
% Last updated: 2022-04-28

import matlab.io.hdf4.*
  
% Open the HDF4 File.
FILE_NAME = 'CAL_LID_L3_Tropospheric_APro_AllSky-Standard-V4-20.2018-10N.hdf';
SD_id = sd.start(FILE_NAME, 'rdonly');

% Read data.
datafield_name = 'Temperature_Mean';
sds_index = sd.nameToIndex(SD_id, datafield_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
data = sd.readData(sds_id);

% Read units from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

sd.endAccess(sds_id);

% Read lat.
lat_name = 'Latitude_Midpoint';
sds_index = sd.nameToIndex(SD_id, lat_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
lat = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read lon.
lon_name = 'Longitude_Midpoint';
sds_index = sd.nameToIndex(SD_id, lon_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
lon = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read Altitude.
alt_name='Altitude_Midpoint';
sds_index = sd.nameToIndex(SD_id, alt_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
alt = sd.readData(sds_id);
% Read units from the Altitude.
units_index = sd.findAttr(sds_id, 'units');
units_alt = sd.readAttr(sds_id, units_index);
sd.endAccess(sds_id);


% Close the file.
sd.close(SD_id);

% Convert data to double type for plot.
data=double(data);
fill_value = -9999.0;
data(data==fill_value) = NaN;
lon=double(lon);
lat=double(lat);
alt_index = 208;
data = squeeze(data(alt_index,:,:));
data = data';
% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'Visible', 'off', ...
           'PaperPositionMode', 'auto');

% Put title.
var_name = sprintf(' at Altitude=%d', alt(alt_index));
tstring = {FILE_NAME; [datafield_name, var_name, units_alt]};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% Plot the data using axesm and surfm.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize', 8)
surfm(lat, lon, data);
colormap('Jet');
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k');
h = colorbar();
set (get(h, 'title'), 'string', units, 'Interpreter', 'None')
tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;
