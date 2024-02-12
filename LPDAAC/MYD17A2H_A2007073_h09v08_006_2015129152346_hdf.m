%
% This example code illustrates how to access and visualize 
% LP DAAC MYD17A2H v6 HDF-EOS2 Grid file using MATLAB.
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
% $matlab -nosplash -nodesktop -r MYD17A2H_A2007073_h09v08_006_2015129152346_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-05-07

import matlab.io.hdfeos.*
import matlab.io.hdf4.*


FILE_NAME='MYD17A2H.A2007073.h09v08.006.2015129152346.hdf';
GRID_NAME='MOD_Grid_MOD17A2H';
DATAFIELD_NAME='Gpp_500m';

% Open the HDF-EOS2 Grid file.
file_id = gd.open(FILE_NAME, 'rdonly');

% Attach to the grid.
grid_id = gd.attach(file_id, GRID_NAME);

% Read the dataset.
data = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Read grid information.
[xdimsize, ydimsize, upleft,lowright] = gd.gridInfo(grid_id);

% Detach Grid object.
gd.detach(grid_id);
gd.close(file_id);

% Convert the data to double type for plot
data=double(data);

% Transpose the data to match the map projection
data=data';

% The file contains SINSOID projection. 
% We need to use eosdump to generate lat and lon in ASCII
% and then convert them to 2D lat and lon to match the shape of data
%
% For information on how to obtain the lat/lon data, 
% check this URL http://hdfeos.org/zoo/note_non_geographic.php

% Use the following command to generate latitude values in ASCII.
% $eos2dump -c1 MYD17A2H.A2007073.h09v08.006.2015129152346.hdf > lat_MYD17A2H.A2007073.h09v08.006.2015129152346.output
lat1D = load('lat_MYD17A2H.A2007073.h09v08.006.2015129152346.output');

% Use the following command to generate longitude values in ASCII.
% $eos2dump -c2 MYD17A2H.A2007073.h09v08.006.2015129152346.hdf > lon_MYD17A2H.A2007073.h09v08.006.2015129152346.output
lon1D = load('lon_MYD17A2H.A2007073.h09v08.006.2015129152346.output');


lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

% Read attributes using SD interface.
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

% Read valid_range from the data field.
range_index = sd.findAttr(sds_id, 'valid_range');
range = sd.readAttr(sds_id, range_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Handle fill value.
data(data==fillvalue) = NaN;

% Handle valid range.
data(data < range(1)) = NaN;
data(data > range(2)) = NaN;


% Apply scale factor.
data = data * scale;

% create the graphics figure -- 'visible'->'off' = off-screen rendering
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','eqdcylin', ...
      'MapLatLimit', latlim, 'MapLonLimit',lonlim, ...      
      'MLineLocation', 5, 'PLineLocation', 5, ...      
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
set (get(h, 'title'), 'string', units, 'interpreter', 'none');

% Set the title using long_name.
title({FILE_NAME; long_name}, ...
      'interpreter', 'none', 'FontSize', 8,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
