%
% This example code illustrates how to access and visualize
% GES DISC AIRS Grid in MATLAB. 
%
% If you have any questions, suggestions, comments  on this
% example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r AIRS_2024_01_19_L3_RetStd_IR001_v7_0_7_0_G24022205217_hdf
%
% Tested under: MATLAB R2023b
% Last updated: 2024-02-19

import matlab.io.hdfeos.*

% Open the HDF-EOS2 Grid File.
FILE_NAME = 'AIRS.2024.01.19.L3.RetStd_IR001.v7.0.7.0.G24022205217.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read Data from a Data Field.
GRID_NAME = 'ascending';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME = 'Temperature_A';

[data1, fail] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Convert 3-D data to 2-D data.
data = squeeze(data1(:,:,1));

% Convert the data to double type for plot.
data = double(data);

% Read filledValue from a Data Field.
fillvalue = gd.getFillValue(grid_id, DATAFIELD_NAME);

% Replace the filled value with NaN.
data(data == fillvalue) = NaN;

% Detach from the Grid Object.
gd.detach(grid_id);

% Attach Grid to read Lat and Lon Data.
GRID_NAME = 'location';
grid_id = gd.attach(file_id, GRID_NAME);

% Read Lat Data.
LAT_NAME = 'Latitude';
[lat, status] = gd.readField(grid_id, LAT_NAME, [], [], []);
lat = double(lat);

% Read Lon Data.
LON_NAME = 'Longitude';
[lon, status] = gd.readField(grid_id, LON_NAME, [], [], []);
lon = double(lon);

% Detach from the Grid Object.
gd.detach(grid_id);

% Close the File.
gd.close(file_id);

f = figure('Name', FILE_NAME, 'visible','off');
axesm('MapProjection', 'eqdcylin', 'Frame', 'on', 'Grid', 'on', ...
      'MeridianLabel', 'on', 'ParallelLabel', 'on', 'MLabelParallel', ...
      'south')
colormap('Jet');
surfm(lat, lon, data);
% scatterm(lat(:), lon(:), 1, data(:));
h = colorbar();
coast = load('coastlines.mat');
plotm(coast.coastlat,coast.coastlon,'k')
tightmap;

units = 'K';
title({FILE_NAME; [DATAFIELD_NAME ' at StdPressureLev=0']}, ...
      'Interpreter', 'None');
set (get(h, 'title'), 'string', units);

saveas(f, [FILE_NAME '.m.png']);
exit;
