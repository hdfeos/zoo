%
%   This example code illustrates how to access and visualize LAADS
% NPP VIIRS Sinusoidal Grid file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this
% example, please use the HDF-EOS Forum  (http://hdfeos.org/forums). 

%   If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the 
% HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2012a
% Last updated: 2012-10-12

clear

% Define file name, grid name, and data field.
FILE_NAME='NPP_D16BRDF3_L3D.A2012241.h20v03.C1_03001.2012258151353.hdf';
[PATHSTR, BASE_NAME, EXT]=fileparts(FILE_NAME);
GRID_NAME='NPP_Grid_BRDF';
DATAFIELD_NAME='Albedo_BSA_Band1';

% Open the HDF-EOS2 Grid file.
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
grid_id = hdfgd('attach', file_id, GRID_NAME);


[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Convert the data to double type for plot.
data2=double(data1);


% This file contains coordinate variables that will not properly plot. 
% To properly display the data, the latitude/longitude must be remapped.

[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the grid object.
hdfgd('detach', grid_id);

% Close the File.
hdfgd('close', file_id);

% The file contains SINUSOIDAL projection. We need to use eosdump to
% generate 1D lat and lon and then convert them to 2D lat and lon accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check [1].
lat1D = load(['lat_' BASE_NAME '.output']);
lon1D = load(['lon_' BASE_NAME '.output']);

lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

% Read attributes from the data field.
SD_id = hdfsd('start', FILE_NAME, 'rdonly');

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

% Read filledValue from the data field.
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

% Read valid_range from the data field.
valid_range_index = hdfsd('findattr', sds_id, 'valid_range');
[valid_range, status] = hdfsd('readattr',sds_id, valid_range_index);


% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);
% Close the file.
hdfsd('end', SD_id);

% Replace the filled value with NaN.
data2(data2 == fillvalue) = NaN;

% Process valid_range.
data2(data2 < valid_range(1)) = NaN;
data2(data2 > valid_range(2)) = NaN;

% Apply scale factor and offset.
data2 = data2 * scale + offset;

% Transpose the data to match the map projection.
data=data2';

% Plot the data using contourfm and axesm.
min_data=min(min(data));
max_data=max(max(data));

% Create the figure.
f=figure('Name', FILE_NAME, 'visible', 'off');

% We need finer grid spacing since the image is zoomed in.
% MLineLocation and PLineLocation controls the grid spacing.
axesm('MapProjection','sinusoid','Frame','on','Grid','on',...
      'MeridianLabel','off','ParallelLabel','on')

coast = load('coast.mat');

surfacem(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min_data:granule:max_data);

set (get(h, 'title'), 'string', units, 'FontSize', 12,'FontWeight','bold');

plotm(coast.lat,coast.long,'k')

title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
    'FontSize',16,'FontWeight','bold');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large. (cf. scrsz = get(0,'ScreenSize');)
scrsz = [1 1 800 600];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f, [FILE_NAME '.m.jpg']);

exit;
% Reference
%
% [1] http://hdfeos.org/zoo/note_non_geographic.php
