%
% This example code illustrates how to access and visualize LAADS
% MOD08_D3 v6 HDF-EOS2 Grid file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MOD08_D3_A2010001_006_2015041224130_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-02-16


clear

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Read data field
FILE_NAME='MOD08_D3.A2010001.006.2015041224130.hdf';
GRID_NAME='mod08';

% Opening the HDF-EOS2 Grid File
file_id = gd.open(FILE_NAME, 'rdonly');

% Open Grid
grid_id = gd.attach(file_id, GRID_NAME);

% Define the Data Field
DATAFIELD_NAME='Cloud_Fraction_Mean';


% Read the dataset.
data = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Read lat and lon dataset.
lon = gd.readField(grid_id, 'XDim', [], [], []);
lat = gd.readField(grid_id, 'YDim', [], [], []);

% Detach Grid object.
gd.detach(grid_id);
gd.close(file_id);

% Transpose the data to match the map projection.
data=data';

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read _FillValue from data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Get the long name from data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Read units from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale_factor from the data field.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);
scale = double(scale);

% Read add_offset from the data field.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);
offset = double(offset);

% Read valid_range from the data field.
range_index = sd.findAttr(sds_id, 'valid_range');
range = sd.readAttr(sds_id, range_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;
data(data > double(range(2))) = NaN;
data(data < double(range(1))) = NaN;

% Multiply scale and add offset, the equation is scale *(data-offset).
data = scale*(data-offset);

% create the graphics figure -- 'visible'->'off' = off-screen rendering
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');
axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'FontSize', 5, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south');      


% surfm() is faster than controufm.
surfm(lat, lon, data);

% Load the coastlines data file.
coast = load('coast.mat');

% Plot coastlines in color black ('k').
plotm(coast.lat,coast.long,'k')
tightmap;

% Put colormap.
colormap('Jet');
h=colorbar();
set (get(h, 'title'), 'string', units);

% Set the title using long_name.
title({FILE_NAME; long_name}, ...
      'interpreter', 'none', 'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

