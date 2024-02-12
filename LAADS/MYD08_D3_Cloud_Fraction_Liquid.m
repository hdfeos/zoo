%   This example code illustrates how to access and visualize LAADS
%  MYD08 Grid file in MATLAB. 
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

% Tested under: MATLAB R2011b
% Last updated: 2011-11-04

clear

% Identify the HDF-EOS2 data file.
FILE_NAME='MYD08_D3.A2009001.005.2009048010832.hdf';

% Identify the HDF-EOS2 data grid.
GRID_NAME='mod08';

% Open the HDF-EOS2 Grid File.
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Attach to the data grid.
grid_id = hdfgd('attach', file_id, GRID_NAME);

% Identify the Data Field to read.
DATAFIELD_NAME='Cloud_Fraction_Liquid';

% Read data from the HDF-EOS2 Grid data field.
[data, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Read lat and lon geolocation data fields.
[lon, status] = hdfgd('readfield', grid_id, 'XDim', [], [], []);
[lat, status] = hdfgd('readfield', grid_id, 'YDim', [], [], []);

% Detach from the grid object.
hdfgd('detach', grid_id);

% Close the HDF-EOS2 grid data file.
hdfgd('close', file_id);

% Transpose the data to match the map projection.
data=data';

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Read attributes from the data field.
FILE_NAME='MYD08_D3.A2009001.005.2009048010832.hdf';

% Initialize the HDF SD Interface to the data file.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='Cloud_Fraction_Liquid';

% Identify the SD data field.
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

% Select the SD data field.
sds_id = hdfsd('select',SD_id, sds_index);


% Read fill value from the data field.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Get the long name attribute from the data field.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Read units from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Reading scale_factor from the data field.
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

% Read offset from the data field.
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

% Read the valid data range from the data field.
valid_range_index = hdfsd('findattr', sds_id, 'valid_range');
[valid_range, status] = hdfsd('readattr',sds_id, valid_range_index);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Mask values outside of valid_range
data(data < valid_range(1)) = NaN;
data(data > valid_range(2)) = NaN;

% Multiply scale and adding offset, the equation is "scale * (data-offset)".
data = scale*(data-offset);

% Plot the data using contourfm and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

% Create the graphics figure.
f=figure('Name', FILE_NAME, 'visible','off');
axesm('MapProjection','eqdcylin','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on');
% Load the coastlines data file
coast = load('coast.mat');

% surfm is faster than contourfm, but produces lower-quality plot
% contourfm(lat, lon, data, 'LineStyle','none');
surfm(lat, lon, data);
% Draw the coastlines in color black ('k').
plotm(coast.lat,coast.long,'k')

% Put color bar.
colormap('Jet');
h=colorbar();
set(get(h, 'title'), 'string', units);

% Put title. The name is very long so we use 12 size fonts.
tstring = {FILE_NAME;long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 12, ...
      'FontWeight','bold');

% Save the figure as JPEG image.
% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');
% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f,['MYD08_D3.A2009001.005.2009048010832_Cloud_Fraction_Liquid.m.jpg']);
exit;

