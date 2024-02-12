%
%  This example code illustrates how to access and visualize LaRC POAM3
% Level 2 HDF4 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r poam3_ver4_sh_199808_hdf
%
% Tested under: MATLAB R2021a
% Last updated: 2022-04-19

import matlab.io.hdf4.*
  
% Open the HDF4 File.
FILE_NAME = 'poam3_ver4_sh_199808.hdf';
SD_id = sd.start(FILE_NAME, 'rdonly');

% Read data.
datafield_name='ozone';
sds_index = sd.nameToIndex(SD_id, datafield_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
data = sd.readData(sds_id);
% Read units from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);
% Get the long name from data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);
sd.endAccess(sds_id);

% Read lat.
lat_name='lat';
sds_index = sd.nameToIndex(SD_id, lat_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
lat = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read lon.
lon_name='lon';
sds_index = sd.nameToIndex(SD_id, lon_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
[m, n] = size(dimsizes);
lon = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read Altitude.
alt_name='z_ozone';
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
lon=double(lon);
lat=double(lat);
alt_index = 56;
data = squeeze(data(:,alt_index));


% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');
% Put title.
var_name = sprintf(' at Altitude=%d', alt(alt_index));
tstring = {FILE_NAME; [long_name, var_name, units_alt]};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% Create the plot.
axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south');
scatterm(lat(:), lon(:), 1, data(:));
h = colorbar();
set (get(h, 'title'), 'string', units, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');

% Plot world map coast line.
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k');
tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;
