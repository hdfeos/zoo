%  This example code illustrates how to access and visualize
% GESDISC TOMS HDF-EOS2 Grid file in MATLAB. 
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
FILE_NAME='TOMS-EP_L3-TOMSEPL3_2000m0101_v8.HDF';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='TOMS Level 3';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='Ozone';

[data, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);


% Transpose the data to match the map projection.
data=data';

% Detach from the Grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% Start the HDF4 SDS interface to read attributes.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Select data field.
DATAFIELD_NAME='Ozone';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);

% Read fill value attribute from the data field.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Read units attributes from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read long_name from the data field.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Terminate access to the data set.
hdfsd('endaccess', sds_id);

% Read latitude data.
DATAFIELD_NAME='YDim:TOMS Level 3';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Read longitude data.
DATAFIELD_NAME='XDim:TOMS Level 3';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Finish SDS interface.
hdfsd('end', SD_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace fill value with NaN
data(data==fillvalue) = NaN;

f = figure('Name','TOMS-EP_L3-TOMSEPL3_2000m0101_v8_Ozone', ...
           'visible','off');

% Plot the data using axesm, surfm and plotm.
if isempty(ver('map'))
    warning('Mapping Toolbox not present.')
	pcolor(lon,lat,double(data)); shading flat
else
    latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
    lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

    coast = load('coast.mat');
    axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
          'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
          'MeridianLabel','on','ParallelLabel','on');
    surfm(lat,lon,double(data));
    plotm(coast.lat,coast.long,'k');
end

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
min_data = floor(min(min(data)));
max_data = ceil(max(max(data)));
caxis([min_data max_data]); 
granule = (max_data - min_data) / ntickmarks;
h=colorbar('YTick', min_data:granule:max_data);

set(get(h, 'title'), 'string', units, ...
                  'FontSize', 16, 'FontWeight','bold');
tstring = {FILE_NAME; long_name};
title(tstring, 'Interpreter', 'None', 'FontSize', 16,'FontWeight','bold');

% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f,'TOMS-EP_L3-TOMSEPL3_2000m0101_v8_Ozone.m.jpg');
