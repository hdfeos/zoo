%  This example code illustrates how to access and visualize PO.DAAC
%  AVHRR Grid HDF4 file in MATLAB. 
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
% Last updated: 2011-10-31

clear

% Open the HDF4 file.
FILE_NAME='2006001-2006005.s0454pfrt-bsst.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from the data field.
DATAFIELD_NAME='bsst';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes, data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Read scale factor from the data field.
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
scale = double(scale);

% Read offset from the data field.
offset_index = hdfsd('findattr', sds_id, 'add_off');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = double(offset);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Read lat information from a data field.
DATAFIELD_NAME_LAT='lat';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME_LAT);
sds_id = hdfsd('select', SD_id, sds_index);
[name, rank, dimsizes, data_type, nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Read lon information from a data field.
DATAFIELD_NAME_LON='lon';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME_LON);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes, data_type, nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

%Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Transpose the data to match the map projection.
data=data';

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Set fillvalue by examining the data field directly using HDFView.
fillvalue = 0;

% Replace the fill value 0 with NaN
data(data == fillvalue) = NaN;

% Multiply scale and add offset.
data = data*scale + offset ;

% Plot the data using surfm(or contourfm) and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on',...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

% surfm is faster than contourfm.
%contourfm(lat,lon,data);
surfm(lat,lon,data);
plotm(coast.lat,coast.long,'k')

% Put colorbar.
colormap('Jet');
h = colorbar();

% Set unit's title manually.
units = 'degrees-C';
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 16, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME; ['Sea Surface Temperature (' DATAFIELD_NAME ')']};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');

% Save the figure as JPEG image.
% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f,'2006001-2006005.s0454pfrt-bsst_bsst.m.jpg');
exit;
