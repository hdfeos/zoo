%  This example code illustrates how to access and visualize
% GESDISC MERRA HDF-EOS2 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Open the HDF-EOS2 Grid file.
FILE_NAME='MERRA300.prod.assim.tavg3_3d_chm_Nv.20021201.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='EOSGRID';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='MFYC';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Convert 4-D data to 2-D data.
data=squeeze(data1(:,:,43,5));

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
data=data';
 
% Read longitude data.
DATAFIELD_NAME='XDim';
[lon, status] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
lon=double(lon);

% Read latitude data.
DATAFIELD_NAME='YDim';
[lat, status] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);
lat=double(lat);

% Detach from the grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% Read attributes from the data field using SDS interface.
SD_id = hdfsd('start', FILE_NAME, 'rdonly');
DATAFIELD_NAME='MFYC';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);

% Read fillvalue and missing value from the data field.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

missingvalue_index = hdfsd('findattr', sds_id, 'missing_value');
[missingvalue, status] = hdfsd('readattr',sds_id, missingvalue_index);

% Read long_name from the data field.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Read units from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read scale_factor from a data field.
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

% Read offset from a data field
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Convert to double type for plot.
scale = double(scale);
offset = double(offset);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Replace the missing value with NaN.
data(data==missingvalue) = NaN;

% Apply scale and offset.
data = data*scale + offset;

% Plot the data using contourfm and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


f = figure('Name', 'MERRA300.prod.assim.inst3_3d_chm_Ne.20021201_PLE_TIME1_Height72','visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

surfacem(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = floor((max_data - min_data) / ntickmarks);

h=colorbar('YTick', min_data:granule:max_data);

plotm(coast.lat,coast.long,'k')

title({FILE_NAME; ...
       [long_name  [' at TIME=4 and Height=42']]}, ...
       'Interpreter', 'None', 'FontSize', 16,'FontWeight','bold');

set(get(h, 'title'), 'string', units, 'FontSize', 16,'FontWeight','bold');

% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];

set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f, ...
       'MERRA300.prod.assim.tavg3_3d_chm_Nv.20021201_MFYC_TIME4_Height42.m.jpg');

