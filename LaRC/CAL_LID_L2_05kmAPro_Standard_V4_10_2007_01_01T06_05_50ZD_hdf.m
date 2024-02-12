%
%  This example code illustrates how to access and visualize LaRC CALIPSO Lidar
% Level 2 Aerosol Profile Version 4 file in MATLAB. 
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
% #matlab -nosplash -nodesktop -r CAL_LID_L2_05kmAPro_Standard_V4_10_2007_01_01T06_05_50ZD_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2017-6-22
clear

% Open the HDF4 File.
FILE_NAME = 'CAL_LID_L2_05kmAPro-Standard-V4-10.2007-01-01T06-05-50ZD.hdf';
SD_id = hdfsd('start', FILE_NAME, 'rdonly');

% Read data.
datafield_name='Extinction_Coefficient_532';
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
data=double(data);
lon=double(squeeze(lon(1,:)));
lat=double(squeeze(lat(1,:)));


% Subset data at profile index 200.
profile_index = 200;
data = squeeze(data(profile_index,:));
data = data';
lat = lat';
lon = lon';

% Find indexes for a region of interest along longitude.
lon_india = (lon < 100.0 & lon > 60.0);
i = find(lon_india,1,'first');
j = find(lon_india,1,'last');

% Subset data using the above indices.
lat = lat(i:j);
lon = lon(i:j);
data = data(i:j);

% Find indexes for a region of interest along latitude.
lat_india = (lat < 40.0 & lat > 0.0);
i = find(lat_india,1,'first');
j = find(lat_india,1,'last');

% Subset data using the above indices.
lat = lat(i:j);
lon = lon(i:j);
data = data(i:j);

% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');



% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south')

geoshow(coast.lat, coast.long, 'Color', 'k');
tightmap;

% Compute data min/max for colorbar.
% All data are fill value so we add 1 to plot lat/lon location only.
min_data=min(min(data))
max_data=max(max(data))+1


% Plot the dataset value on map.
cm = colormap('Jet');
caxis([min_data max_data]); 
k = size(data);
[count, n] = size(cm);
hold on
for i=1:k
    if isnan(data(i))
    else        
        c = floor(((data(i) - min_data) / (max_data - min_data)) * ...
              (count-1));
        plotm(lat(i), lon(i), 'color', cm(c+1, :), 'Marker', 's', ...
              'MarkerSize', 1, 'LineWidth', 2.0);
    end
end

tstring = {FILE_NAME;'Extinction_Coefficient_532 at Profile = 200'};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


hold off;
saveas(f, [FILE_NAME '.m.png']);
exit;


