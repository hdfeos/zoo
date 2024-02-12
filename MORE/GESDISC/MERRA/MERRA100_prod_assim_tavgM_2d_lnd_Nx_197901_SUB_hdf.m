%
%  This example code illustrates how to access and visualize
% GESDISC MERRA HDF4 subset file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  #matlab -nosplash -nodesktop -r MERRA100_prod_assim_tavgM_2d_lnd_Nx_197901_SUB_hdf
%
% Tested under: MATLAB R2015a
% Last updated: 2015-9-4

% Open the HDF4 File.
FILE_NAME = 'MERRA100.prod.assim.tavgM_2d_lnd_Nx.197901.SUB.hdf';
SD_id = hdfsd('start', FILE_NAME, 'rdonly');

% Read data to plot.
datafield_name='lai';
sds_index = hdfsd('nametoindex', SD_id, datafield_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Read units attribute.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);
hdfsd('endaccess', sds_id);

% Read missing_value attribute.
mv_index = hdfsd('findattr', sds_id, 'missing_value');
[mv, status] = hdfsd('readattr',sds_id, mv_index);
hdfsd('endaccess', sds_id);

% Read long_name attribute.
ln_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, ln_index);
hdfsd('endaccess', sds_id);

% Read lat/lon information.
lat_name='latitude';
sds_index = hdfsd('nametoindex', SD_id, lat_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

lon_name='longitude';
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
data=double(data1');

%Replacing the missing value with NaN
data(data==mv) = NaN;

lon=double(lon);
lat=double(lat);

% Plot the data using contourfm and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


f = figure('Name', FILE_NAME, 'visible', 'off');
%      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
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
tstring = {FILE_NAME;long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.png']);
exit;
