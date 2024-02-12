%   This example code illustrates how to access and visualize LP DAAC MODIS
% TERRA 13Q1 Sinusoidal Grid file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run without .m at the end as follows.
%
% $matlab -nosplash -nodesktop -r MOD13Q1_A2012353_h12v12_005_2013009144505_hdf
%
% Tested under: MATLAB R2012a
% Last updated: 2013-11-20

clear


clear

% Open the HDF-EOS2 Sinusoidal Grid file.
FILE_NAME='MOD13Q1.A2012353.h12v12.005.2013009144505.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='MODIS_Grid_16DAY_250m_500m_VI';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='250m 16 days NDVI';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Copy the data for type conversion.
data=data1;

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
data=data';

% This file contains coordinate variables that will not properly plot. 
% To properly display the data, the latitude/longitude must be remapped.

[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the Grid.

hdfgd('detach', grid_id);

% Close the file.

hdfgd('close', file_id);

% The file contains SINSOID projection. We need to use eosdump to generate 1D 
% lat and lon and then convert them to 2D lat and lon accordingly.
% For example, run command as follows to get SOM projectoin lat/lon in ASCII.
%
% eos2dump -c1 MOD13Q1.A2012353.h12v12.005.2013009144505.hdf  > lat_MOD13Q1.A2012353.h12v12.005.2013009144505.output
% eos2dump -c2 MOD13Q1.A2012353.h12v12.005.2013009144505.hdf  > lon_MOD13Q1.A2012353.h12v12.005.2013009144505.output
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check [1].

lat1D = load('lat_MOD13Q1.A2012353.h12v12.005.2013009144505.output');
lon1D = load('lon_MOD13Q1.A2012353.h12v12.005.2013009144505.output');

lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

% Read attributes from the data field.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

% Read fill value from the data field.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Read units from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read scale_factor from the data field.
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

% Read add_offset from the data field.
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

% Read long_name from the data field.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Terminate the access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Multiply scale and adding offset. The equation is scale *(data-offset).
data = (data-offset) / scale;

% Set the limits for the plot.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=min(min(data));
max_data=max(max(data));

f=figure('Name', FILE_NAME, 'visible', 'off');

% Create the plot.
axesm('MapProjection','sinusoid','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelLocation',lonlim,'PLabelLocation',latlim)
coast = load('coast.mat');

surfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min_data:granule:max_data);

plotm(coast.lat,coast.long,'k')

title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
      'FontSize',12,'FontWeight','bold');
set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight', ...
                   'bold');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;

% References
% [1] http://hdfeos.org/software/eosdump.php
