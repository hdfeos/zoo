%
%  This example code illustrates how to access and visualize LaRC CALIPSO Lidar
% Level 2 Aerosol Profile Version 4.10 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r CAL_LID_L2_05kmAPro_Standard_V4_10_2017_04_01T19_34_57ZN_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-05-02
clear

% Open the HDF4 File.
FILE_NAME = 'CAL_LID_L2_05kmAPro-Standard-V4-10.2017-04-01T19-34-57ZN.hdf';
SD_id = hdfsd('start', FILE_NAME, 'rdonly');

% Read data.
datafield_name='Extinction_Coefficient_532';
sds_index = hdfsd('nametoindex', SD_id, datafield_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes, data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), ...
                       dimsizes);
% Read fill value attribute.
fillvalue_index = hdfsd('findattr', sds_id, 'fillvalue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);
% Read units from the data field.
units_index = hdfsd('findattr',sds_id, 'units');
[units, status]  = hdfsd('readattr', sds_id, units_index);

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

% Read Pressure.
alt_name='Pressure';
sds_index = hdfsd('nametoindex', SD_id, alt_name);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[alt, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), ...
                      dimsizes);
% Read units.
units_index = hdfsd('findattr',sds_id, 'units');
[units_pr, status]  = hdfsd('readattr', sds_id, units_index);

hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Convert data to double type for plot.
data=double(data);
lon=double(squeeze(lon(1,:)));
lat=double(squeeze(lat(1,:)));
alt=double(squeeze(alt(1,:)));

% Subset data at profile index 200.
profile_index = 200;
data = squeeze(data(profile_index,:));
data = data';
lat = lat';
lon = lon';
alt = alt';

% Find indexes for a region of interest along longitude.
% lon_india = (lon < 100.0 & lon > 60.0);
% i = find(lon_india,1,'first');
% j = find(lon_india,1,'last');

% Subset data using the above indices.
% lat = lat(i:j);
% lon = lon(i:j);
% alt = alt(i:j);
% data = data(i:j);

% Find indexes for a region of interest along latitude.
% lat_india = (lat < 40.0 & lat > 0.0);
% i = find(lat_india,1,'first');
% j = find(lat_india,1,'last');

% Subset data using the above indices.
% lat = lat(i:j);
% lon = lon(i:j);
% alt = alt(i:j);
% data = data(i:j);

% Handle fill value.
data(data==fillvalue) = NaN;

% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');


subplot(2,1,1);
% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'FontSize', 5, ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south')

% Plot the dataset value on map.
cm = colormap('Jet');
scatterm(lat, lon, 1, data);

% Annotate the starting point of the path.
textm(lat(1), lon(1), '+', 'FontSize', 10, 'FontWeight','bold', ...
      'Color', 'red');

geoshow(coast.lat, coast.long, 'Color', 'k');
h = colorbar();
set (get(h, 'title'), 'string', units, 'FontSize', 5);

tstring = {FILE_NAME;'Extinction_Coefficient_532 at Profile = 200'};
title(tstring, 'Interpreter', 'none', 'FontSize', 10, ...
      'FontWeight','bold');
tightmap;
subplot(2,1,2);

% Plot altitude.
plot(alt, '-');
grid on;
axis square;
ylabel(['Pressure (' units_pr  ')']);

hold off;
saveas(f, [FILE_NAME '.m.png']);
exit;

% See page 78 of [1] for Profile Vertical resolution and the meaning of 399
% dimensions.
% [1] https://www-calipso.larc.nasa.gov/products/CALIPSO_DPC_Rev4x20.pdf

