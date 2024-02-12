%
%  This example code illustrates how to access and visualize NSIDC
%  AMSR_E 5-day snow version 9 L3 HDF-EOS2 Grid file in MATLAB.
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
%  $matlab -nosplash -nodesktop -r AMSR_E_L3_5DaySnow_V09_20050126_hdf
%
% Tested under: MATLAB R2018b
% Last updated: 2019-01-15

import matlab.io.hdfeos.*
   
% Opening the HDF-EOS2 Grid File
FILE_NAME = 'AMSR_E_L3_5DaySnow_V09_20050126.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Reading Data from a Data Field
GRID_NAME = 'Northern Hemisphere';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME = 'SWE_NorthernPentad';
[data1, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME);

% Convert the data to double type for plot
data = double(data1);

% Get information about the spatial extents of the grid.
[xdimsize, ydimsize, upleft, lowright] = gd.gridInfo(grid_id);

% Detach Grid object.
gd.detach(grid_id);
gd.close(file_id);

% Handle fill value.
data(data > 240) = NaN;

scale = 2.0;

% Apply scale factor.
data = data*scale;

f = figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], 'visible', 'off');
pole=[90 0 0];
axesm('MapProjection','stereo', ...
      'Origin', pole ,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');
surfacem(lat,lon,data);
colormap('Jet');
h = colorbar();
plotm(coast.lat,coast.long,'k')
   title({FILE_NAME; 'Northern Hemisphere 5-day Snow Water Equivalent'; ['(' DATAFIELD_NAME ')']}, 'Interpreter', 'None', ...
      'FontSize', 12,'FontWeight','bold');
units = 'mm';
set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');
saveas(f,[FILE_NAME '.m.png']);
exit;

