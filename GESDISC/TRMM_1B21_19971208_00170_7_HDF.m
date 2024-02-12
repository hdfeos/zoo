%
%  This example code illustrates how to access and visualize GESDISC TRMM
% version 7 HDF4 Level 2 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS  Comprehensive Examples 
% page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum 
% (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  #matlab -nosplash -nodesktop -r TRMM_1B21_19971208_00170_7_HDF
%
% Tested under: MATLAB R2012a
% Last updated: 2013-6-12
clear

% Open the HDF4 File.
FILE_NAME = '1B21.19971208.00170.7.HDF';
SD_id = hdfsd('start', FILE_NAME, 'rdonly');

% Read data to plot.
datafield_name='binDIDHmean';
sds_index = hdfsd('nametoindex', SD_id, datafield_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Copy the data.
data=data1;

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Read lat/lon information.
lat_name='Latitude';
sds_index = hdfsd('nametoindex', SD_id, lat_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

lon_name='Longitude';
sds_index = hdfsd('nametoindex', SD_id, lon_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Plot the data using contourfm and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


f = figure('Name', FILE_NAME, 'visible', 'off');

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

% surfm is faster than contourfm.
surfm(lat, lon, data);
colormap('Jet');
h=colorbar();
plotm(coast.lat,coast.long,'k')

% Draw unit.
set(get(h, 'title'), 'string', 'None', ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME;datafield_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;
