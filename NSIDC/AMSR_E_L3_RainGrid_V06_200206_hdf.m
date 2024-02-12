%
%  This example code illustrates how to access and visualize NSIDC
%  AMSR_E L3 Rain version 6 HDF-EOS2 Grid file in MATLAB.
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
%  $matlab -nosplash -nodesktop -r AMSR_E_L3_RainGrid_V06_200206_hdf
%
% Tested under: MATLAB R2018b
% Last updated: 2019-01-11

import matlab.io.hdfeos.*

% Open the HDF-EOS2 Grid file.
FILE_NAME = 'AMSR_E_L3_RainGrid_V06_200206.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a grid field.
GRID_NAME = 'MonthlyRainTotal_GeoGrid';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME='TbOceanRain';
[data1, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME);

% Convert the data to double type for plot.
data=double(data1);

% Detach grid.
gd.detach(grid_id);

% Close file.
gd.close(file_id);

% Replace fill value with NaN.
data(data==-1) = NaN;

f = figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], 'visible','off');
axesm('MapProjection','eqdcylin','Frame','on','Grid','on',...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south')
coast = load('coast.mat');
surfm(lat, lon, data, 'LineStyle', 'none');
colormap('Jet');
h = colorbar();
plotm(coast.lat,coast.long,'k')
title({FILE_NAME; 'TbOceanRain'}, 'Interpreter', 'None', ...
      'FontSize',12,'FontWeight','bold');
set (get(h, 'title'), 'string', 'mm', 'FontSize', 12, 'FontWeight', 'bold');
tightmap;
saveas(f,[FILE_NAME '.m.png']);
exit;
