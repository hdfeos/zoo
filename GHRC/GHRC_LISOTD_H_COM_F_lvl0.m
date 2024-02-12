%  This example code illustrates how to access and visualize
% GHRC HDF4 file in MATLAB. 
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

% Set file name.
FILE_NAME='LISOTD_HRAC_V2.2.hdf';

% Open the file.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from a data Field
DATAFIELD_NAME='HRAC_COM_FR';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert 3-D data to 2-D data.
data=squeeze(data1(1,:,:));

% Transpose the data to match the map projection.
data=data';

% Read fill value from the data field.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Read units from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read long_name from the data field.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Terminate access to the data field.
hdfsd('endaccess', sds_id);

% Read latitude data field.
LATNAME='Latitude';
sds_index = hdfsd('nametoindex', SD_id, LATNAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes, data_type, nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);


% The first lat needs to be handled carefully. It's actually the last one.
lat = lat - 90;
lat(1) = lat(1) + 180;

temp  = lat;
lat = temp(2:360);
lat(360) = temp (1);

% Terminate access to the latitude data field.
hdfsd('endaccess', sds_id);

% Read lon data field.
LON_NAME='Longitude';
sds_index = hdfsd('nametoindex', SD_id, LON_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% The first lon needs to be handled carefully. It's actually the last one.
lon = lon - 180;
lon(1) = lon(1) + 360;
temp  = lon;
lon = temp(2:720);
lon(720) = temp (1);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% We need to change the order of data to be consistent with new lat and lon.
temp = data;
data(1,:) = temp(360,:);
data(360,:) = temp(1,:);
temp = data;
data(:,1) = temp(:, 720);
data(:,720) = temp(:, 1);

% Plot the data using surfacem and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=min(min(data));
max_data=max(max(data));

f = figure('Name', FILE_NAME, 'visible', 'off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ..., 
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');
surfacem(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;

h = colorbar('YTick', min_data:granule:max_data);
set (get(h, 'title'), 'string', units,'FontSize', 16, 'FontWeight','bold');

plotm(coast.lat,coast.long,'k')

title({strrep(FILE_NAME,'_','\_');...
       strrep(long_name,'_','\_');...
       'at Day of year=0'},...
      'FontSize', 16, 'FontWeight','bold');


% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f, ...
       'LISOTD_HRAC_V2.2_v8_HRAC_COM_FR_Day_of_year0.m.jpg');
