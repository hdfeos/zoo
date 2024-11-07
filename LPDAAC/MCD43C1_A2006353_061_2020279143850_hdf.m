%
% This example code illustrates how to access and visualize LP_DAAC
% MCD43C1 Grid file in MATLAB.
%
% If you have any questions, suggestions, comments  on this
% example, please use the HDF-EOS Forum
% (http://hdfeos.org/forums).
%
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo),
% feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r MCD43C1_A2006353_061_2020279143850_hdf
%
% Tested under: MATLAB R2023b
% Last updated: 2024-11-07

import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Open the HDF-EOS2 grid file.
FILE_NAME = 'MCD43C1.A2006353.061.2020279143850.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME = 'MCD_CMG_BRDF_0.05Deg';
grid_id = gd.attach(file_id, GRID_NAME);


% The following code throws an error on MATLAB 2021a.
DATAFIELD_NAME = 'Percent_Snow';
[data1, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

lat = lat * 3600;
lon = lon * 3600;

% Convert the data to double type for plot.
data=double(data1);

% Convert the data to double type for plot
data=double(data);


% Detach from the HDF-EOS2 Grid object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);

% Read attributes from the data field using HDF4 interface.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read fill value attribute from the data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Read units attribute from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read long_name attribute from the data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Terminate access to the data field.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Replace fill value with NaN.
data(data==fillvalue) = NaN;

f=figure('Name', FILE_NAME, ...
         'Position', [0,0,800,600], ...
         'Renderer', 'zbuffer', 'visible', 'off');
axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'FontSize', 5, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south');
surfm(lat, lon, data);
colormap('Jet');
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k')
title({FILE_NAME;DATAFIELD_NAME}, 'Interpreter', 'None', ...
      'FontSize', 12, 'FontWeight', 'bold');
h = colorbar();
set (get(h, 'title'), 'string', units);
saveas(f, [FILE_NAME '.m.png']);
exit;
