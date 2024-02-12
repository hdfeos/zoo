%  This example code illustrates how to access and visualize CALIPSO Lidar L2 
% Profile HDF4 file in MATLAB. 
%
% This example will subset India region (0-40N and 60E-100E).
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r CAL_LID_L2_05kmAPro_Prov_V3_30_2013_03_01T00_56_26ZD_hdf
%
%
% Tested under: MATLAB R2015a
% Last updated: 2016-03-28

clear

% Open the HDF-EOS2 Swath File.
FILE_NAME = 'CAL_LID_L2_05kmAPro-Prov-V3-30.2013-03-01T00-56-26ZD.hdf';
SD_id = hdfsd('start', FILE_NAME, 'rdonly');

% Read data.
datafield_name='Column_Optical_Depth_Cloud_532';
sds_index = hdfsd('nametoindex', SD_id, datafield_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes, data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Read lat.
lat_name='Latitude';
sds_index = hdfsd('nametoindex', SD_id, lat_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Read lon.
lon_name='Longitude';
sds_index = hdfsd('nametoindex', SD_id, lon_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Convert data to double type for plot.
data=double(data(1,:));
lon=double(lon(1,:))
lat=double(lat(1,:));

% This product doesn't have data near India region. 
% Please comment out the following lines if you'd like to subset
% data over the India region.

% Find indexes for India region along longitude.
% lon_india = (lon > 60.0 & lon < 100.0);
% i = find(lon_india,1,'first');
% j = find(lon_india,1,'last');

% Subset data using the above indices.
%  lat = lat(i:j);
% lon = lon(i:j);
% data = data(i:j);


% Find indexes for India region along latitude.
% lat_india = (lat > 0.0 & lat < 40.0);
% i = find(lat_india,1,'first');
% j = find(lat_india,1,'last');

% Subset data using the above indices.
% lat = lat(i:j);
% lon = lon(i:j);
% data = data(i:j);

% Draw plot.
f=figure('Name', FILE_NAME, 'visible', 'off');
tstring = {FILE_NAME;datafield_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

% Plot the satellite path in blue.
plotm(lat, lon, 'b')

% Plot world map coast line.
plotm(coast.lat, coast.long, 'k');

% Annotate the starting point of the path.
textm(lat(1), lon(1), '+', 'FontSize', 16, 'FontWeight','bold', ...
      'Color', 'red');

% Put title.
title('Trajectory of Satellite Path (+:starting point)',...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.png']);
exit;


