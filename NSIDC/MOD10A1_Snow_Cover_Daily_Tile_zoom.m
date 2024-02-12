% This example code illustrates how to access and visualize NSIDC
% MODIS Grid file in Matlab. This Grid file uses Sinusoidal projection.
%
% If you have any questions, suggestions, comments on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Open the HDF-EOS2 Grid file.
FILE_NAME='MOD10A1.A2000065.h00v08.005.2008237034422.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='MOD_Grid_Snow_500m';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='Snow_Cover_Daily_Tile';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Copy the data.
data=data1;

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
data=data';

% This file contains coordinate variables that will not properly plot. 
% To properly display the data, the latitude/longitude must be remapped.

[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the Grid Object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% The file contains SINSOID projection. We need to use eosdump to
% generate 1D lat and lon.
% For information on how to obtain the lat/lon data, 
% check [1]. 

lat1D = load('lat_MOD10A1.A2000065.h00v08.005.2008237034422.output');
lon1D = load('lon_MOD10A1.A2000065.h00v08.005.2008237034422.output');


lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

lon(lon<0) = lon(lon<0) + 360;

% Read attributes from the data field.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='Snow_Cover_Daily_Tile';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);


% Read units from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read long_name from the data field.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);




% The following will return 4 keys used in the dataset.
z = unique(data);
num_levels = size(z);
k = double(num_levels(1));
% Create an array for tick label.
y = zeros(num_levels, 'double');

% There are k different boxes in the colorbar 
% and the value starts from 1 to m.
% Thus, we should increment by (k-1)/k to position
% labels properly starting form ((k-1)/k)/2.
x = 1 + ((k-1)/k)/2;

for m = 1:num_levels(1)
    y(m) = x;
    data(data == z(m)) = double(m);
    x = x + (k-1)/k;    
end

f = figure('Name', 'MOD10A1.A2000065.h00v08.005.2008237034422_Snow_Cover_Daily_Tile', 'visible','off');

% Plot the data using surfacem and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

%axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
%      'MeridianLabel','on','ParallelLabel','on')
axesm('sinusoid', 'Frame', 'on', 'Grid', 'on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelLocation', 5,'PLabelLocation', 5);
coast = load('coast.mat');

surfacem(lat,lon,data);

% Construct color table based on the following assignment:
%
% Key  R  G   B    Name
% 0   255 255 255  white
% 1   184 184 184
% 11  225 225 150
% 25  0   255 0
% 37  35  35  117
% 39  35  35  117
% 50  100 200 255
% 100 255 176 255
% 153 0   0   0
% 193 0   0   0
% 200 255 0   0
% 233 0   0   0
% 254 0   0   0
% 255 0   0   0  black
%
% The above assignment is close to "Image Gallery" of NSIDC [2].
%
% We picked grey to make fill values visible.
% You can use (0,0,0) for the first entry to hide fill value.
%
% Here is the color map used by the MODIS group for the Browse images
cmap=[                       %  Key         R   G   B
      [1.00 1.00 1.00];  ... %  0=missing [255,255,255],    
      [0.00 1.00 0.00];  ... %  25=land   [000,255,000],
      [0.14 0.14 0.76];  ... %  39=ocean  [035,035,117],
      [0.00 0.00 0.00]];     %  255=fill  [0,000,000],

colormap(cmap);
caxis([1 m]); 
h = colorbar('YTickLabel', {'missing', 'no snow', 'ocean', 'fill'}, ...
             'YTick', y);

plotm(coast.lat,coast.long,'k')

title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
      'FontSize',12,'FontWeight','bold');

% Save image.
set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f, ...
       'MOD10A1.A2000065.h00v08.005.2008237034422_Snow_Cover_Daily_Tile_zoom.m.jpg');

% Reference
%
% [1] http://hdfeos.org/zoo/note_non_geographic.php
% [2] http://nsidc.org/data/modis/gallery/index.html