%
%   This example code illustrates how to access and visualize LP DAAC
%  MEaSUREs WELD CONUS Albers Grid file in MATLAB.
%
%   If you have any questions, suggestions, comments on this
% example, please use the HDF-EOS Forum  (http://hdfeos.org/forums). 
%
%   If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the 
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r CONUS_annual_2012_h01v06_doy007to356_v1_5_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-05-08

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Set the data file name.
FILE_NAME='CONUS.annual.2012.h01v06.doy007to356.v1.5.hdf';

% Set the grid name.
GRID_NAME='WELD_GRID';

% Set the data field name.
DATAFIELD_NAME='NDVI_TOA';

% Open the HDF-EOS2 Grid file.
file_id = gd.open(FILE_NAME, 'rdonly');

% Attach to the grid.
grid_id = gd.attach(file_id, GRID_NAME);

% Read data from the field.
data = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% This file contains coordinate variables that will not properly plot.
% To properly display the data, the latitude/longitude must be
% remapped.
[xdimsize, ydimsize, upleft,lowright] = gd.gridInfo(grid_id);

% Detach from the grid object.
gd.detach(grid_id);

% Close the hdfgd() interface.
gd.close(file_id);


% The file contains Albers projection. We need to use an external program
% to generate 1D lat and lon and then convert them to 2D lat and lon
% accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL
% http://hdfeos.org/zoo/note_non_geographic.php

lat1D = load(['lat_',FILE_NAME,'.output']);
lon1D = load(['lon_',FILE_NAME,'.output']);

lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Read attributes from the data field using hdfsd() interface.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read _FillValue attribute.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Read units attribute.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale_factor attribute.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);

% Convert scale to double.
scale = double(scale);

% Read valid_range attribute.
range_index = sd.findAttr(sds_id, 'valid_range');
range = sd.readAttr(sds_id, range_index);

% Terminate access to the data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Handle _FillValue.
data(data == fillvalue) = NaN;

% Handle valid_range.
data( (data < range(1)) | (data > range(2))  ) = NaN;

% Apply scale factor.
data = scale*data;

% This product doesn't have long_name attribute so we use the
% datafield name for labeling the plot.
long_name = DATAFIELD_NAME;

% Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=min(min(data));
max_data=max(max(data));
data_range=max_data-min_data;


% Create the figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% World map.
% axesm('MapProjection','eqdcylin','Frame','on','Grid','on');

% Zoomed image.
axesm('MapProjection','sinusoid','Frame','on','Grid','on',...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south', ...
      'FontSize', 8, ...      
      'MLabelLocation', 1, 'PLabelLocation', 1, ...
      'MLineLocation', 1, 'PLineLocation', 1);

surfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

coast = load('coast.mat');
plotm(coast.lat,coast.long,'k');

h = colorbar();
set (get(h, 'title'), 'string', units)
tightmap;


title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
    'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
