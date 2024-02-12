%
%   This example code illustrates how to access and visualize LP DAAC
% MYD09GQ version 6 HDF-EOS2 Sinusoidal Grid file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this
% example, please use the HDF-EOS Forum  (http://hdfeos.org/forums). 

%   If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the 
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r MYD09A1_A2007273_h03v07_006_2015167083229_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-05-04

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Define file name, grid name, and data field.
FILE_NAME='MYD09GQ.A2012246.h35v10.006.2015248145541.hdf';
GRID_NAME='MODIS_Grid_2D';
DATAFIELD_NAME='sur_refl_b01_1';

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

% The file contains SINSOID projection. To properly display the
% data, the latitude/longitude must be remapped.
%
%  We used eos2dump to generate 1D lat and lon and then convert
%  them to 2D lat and lon accordingly. For example,
%
% #eos2dump -c1 MYD09GQ.A2012246.h35v10.006.2015248145541.hdf > lat_MYD09GQ.A2012246.h35v10.006.2015248145541.output
% #eos2dump -c2 MYD09GQ.A2012246.h35v10.006.2015248145541.hdf > lon_MYD09GQ.A2012246.h35v10.006.2015248145541.output
%
% For information on how to obtain the lat/lon data, check [1].
lat1D = load('lat_MYD09GQ.A2012246.h35v10.006.2015248145541.output');
lon1D = load('lon_MYD09GQ.A2012246.h35v10.006.2015248145541.output');

% Convert 1D to 2D.
lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

%   Please note that this Grid data field covers the area near 180 longitude, 
% which results -180 for min value and 180 for max value  although
% the data field doesn't cover the entire longitude [-180, 180].
% Thus, unlike other MATLAB examples, we need to adjust map limits carefully.
% To achieve the goal of plotting correctly, we added 360 for
% longitude that is less than 0.
% Then, you can plot a zoomed image correctly by setting limits for min / max 
% values later.
lon(lon < 0) = lon(lon < 0) + 360;

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

% Read offset from the data field.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);

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
data = (data - offset) / scale;

% Plot the data using contourfm and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=min(min(data));
max_data=max(max(data));

% Create the graphics figure -- 'visible'->'off' = off-screen rendering.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% We need finer grid spacing since the image is zoomed in.
% MLineLocation and PLineLocation controls the grid spacing.
axesm('MapProjection','sinusoid','Frame','on','Grid','on',...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelLocation', 5, 'PLabelLocation', 5)
coast = load('coast.mat');
surfm(lat,lon,data);
colormap('Jet');
tightmap;
h=colorbar();
set (get(h, 'title'), 'string', units);

% Set the title using long_name.
title({FILE_NAME; long_name}, ...
      'interpreter', 'none', 'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

% Reference
%
% [1] http://hdfeos.org/zoo/note_non_geographic.php

