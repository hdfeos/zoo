%
%    This example code illustrates how to access and visualize LaRC
%  CERES SSF NPP VIIRS HDF4 file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this
%  example, please use the HDF-EOS Forum
%  (http://hdfeos.org/forums). 
%
%    If you would like to see an  example of any other NASA
%  HDF/HDF-EOS data product that is not listed in the HDF-EOS
%  Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org  or
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r CER_SSF1deg_Month_NPP_VIIRS_Edition2A_200203_201909_hdf
%
% Tested under: MATLAB R2021a
% Last updated: 2022-11-07

import matlab.io.hdf4.*

% Open the HDF4 Grid file.
FILE_NAME='CER_SSF1deg-Month_NPP-VIIRS_Edition2A_200203.201909.hdf';
DATAFIELD_NAME='clr_toa_lw_reg';

SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);
data = sd.readData(sds_id);

% Read _FillValue from data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Get the long name from data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Read units from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Read lat.
sds_index = sd.nameToIndex(SD_id, 'latitude');
sds_id = sd.select(SD_id, sds_index);
lat = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read lon.
sds_index = sd.nameToIndex(SD_id, 'longitude');
sds_id = sd.select(SD_id, sds_index);
lon = sd.readData(sds_id);
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Plot the data using surfm and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'FontSize', 8, ...
      'MeridianLabel','on','ParallelLabel','on',...
      'MLabelParallel','south');

coast = load('coastlines.mat');
surfm(lat, lon, data.');
plotm(coast.coastlat, coast.coastlon,'k');

% Put color bar.
colormap('Jet');
h=colorbar();

% Set unit.
set (get(h, 'title'), 'string', units);
tightmap;

% Put title. 
tstring = {FILE_NAME;long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 10, ...
      'FontWeight','bold');
saveas(f,[FILE_NAME '.m.png']);
exit;
