%  This example code illustrates how to access and visualize OBPG
%  SeaWiFS HDF4 Swath file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2011b
% Last updated: 2011-10-28

clear

% Open the HDF4 file.
FILE_NAME='S1997247162631.L2_MLAC_OC.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from the  data field.
DATAFIELD_NAME='Rrs_412';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Read long name from the data field attribute.
longname_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id,longname_index);

% Read units attribute from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read scale factor attribute from the data field.
scale_index = hdfsd('findattr', sds_id, 'slope');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
scale = double(scale);

% Read offset attribute from the data field.
offset_index = hdfsd('findattr', sds_id, 'intercept');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = double(offset);

% Terminate access to the data set.
hdfsd('endaccess', sds_id);

% Read lat information from a data field.
DATAFIELD_NAME='latitude';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the data set.
hdfsd('endaccess', sds_id);

% Read lon information from the data field.
DATAFIELD_NAME='longitude';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Set fill value by reading the data field.
fillvalue = -32767;

% Replace the fill value with NaN
data(data == fillvalue) = NaN;

% Multiply scale and add offset.
data = data*scale + offset ;

% Set limits for zoomed effect.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

% Plot the data using surfm(or contourfm) and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');
axesm('MapProjection','eqdcylin','Frame','on','Grid','on',...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelLocation',lonlim,'PLabelLocation',latlim)
coast = load('coast.mat');

% surfm is faster than contourfm.
% contourfm(lat,lon,data);
surfm(lat,lon,data);
plotm(coast.lat,coast.long,'k')

% Put colorbar.
% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
min_data=min(min(data));
max_data=max(max(data));
granule = (max_data - min_data) / ntickmarks;
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:granule:max_data);

set(get(h, 'title'), 'string', units, ...
                  'FontSize', 16, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME; long_name};
title(tstring, 'Interpreter', 'none', 'FontSize',16,'FontWeight','bold');

% Save the figure as JPEG image.
% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f,'S1997247162631.L2_MLAC_OC_Rrs_412_zoom.m.jpg');
exit;
