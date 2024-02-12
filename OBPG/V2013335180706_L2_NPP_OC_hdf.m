%
%  This example code illustrates how to access and visualize OBPG
%  VIIRS HDF4 Swath file in MATLAB.
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
% Acknowledgement
%
%  Part of this example code is provided by
%  Kelly Luekemeyer, Mapping Toolbox Development, MathWorks, Inc.

% Tested under: MATLAB R2012a
% Last updated: 2013-12-20

clear

% Open the HDF4 file.
FILE_NAME='V2013335180706.L2_NPP_OC.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from a data field.
DATAFIELD_NAME='chlor_a';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[~, ~, dimsizes] = hdfsd('getinfo', sds_id);
[~, n] = size(dimsizes);
data = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Read long name attribute from the data field.
longname_index = hdfsd('findattr', sds_id, 'long_name');
long_name = hdfsd('readattr',sds_id,longname_index);

% Read units attribute from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
units = hdfsd('readattr',sds_id, units_index);

% Read bad_value_scaled attribute from the data field.
fill_value_index = hdfsd('findattr', sds_id, 'bad_value_scaled');
fill_value = hdfsd('readattr',sds_id, fill_value_index);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Read lat information from a data field.
DATAFIELD_NAME='latitude';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[~, ~, dimsizes] = hdfsd('getinfo', sds_id);
[~, n] = size(dimsizes);
lat = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Read lon information from a data field.
DATAFIELD_NAME='longitude';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Create a set of level ranges to be used in converting the data to a
% geolocated image that has a color assigned to each range.
levels = [0.0 0.1 0.2 0.3 0.4 0.5 1.0 2.0 4.0 8.0 16.0 32.0];

% Create a color map.
cmap =jet(length(levels) + 1);

% Set the first entry of colormap as white, which will be used for
% fill value.
cmap(1, :,:) = [1 1 1];

% Convert the data to an geolcated image by setting a color for each level
% range.
Z = data;

% Clamp the min and max values to the level index.
Z(Z < levels(1)) = 1;
Z(Z > levels(end)) = length(levels);

% Assign Z as an indexed image with the index value corresponding to the
% level range.
for k = 1:length(levels) - 1
    Z(data >= levels(k) & data < levels(k+1)) = double(k) ;
end

% Set the fill region to the index corresponding the the color white (the
% lowest color value)
Z (data == fill_value) = 0;

% Compute latitude and longitude limits for the map.
latlim = double([min(min(lat)),max(max(lat))]);
lonlim = double([min(min(lon)),max(max(lon))]);

% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];

% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto', ...
    'Colormap', jet(2048));

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
    'MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on', ...
    'MLabelLocation', 5, 'PLabelLocation', 5, ...
    'MLineLocation',  5, 'PlineLocation', 5, ...
    'MlabelParallel', min(latlim))
tightmap

colormap(cmap)

% Use geoshow to plot the data as a geolocated indexed image.
geoshow(lat, lon, uint8(Z), cmap, 'd','image')
geoshow(coast.lat, coast.long, 'Color', 'k')

% Create a colorbar. The colorbar can be moved to the right side of the
% plot by setting 'Location' to 'vertical'.
caxis auto
clevels =  cellstr(num2str(levels'));
clevels{1} =   ['<= ', num2str(levels(1))];
clevels{end} = ['>= ', num2str(levels(end))];
clevels = ['fill'; clevels]';

h = lcolorbar(clevels, 'Location', 'horizontal');
set(get(h, 'title'), 'string', units, ...
    'Interpreter', 'none', ...
    'FontSize', 16, 'FontWeight','bold');

% Put title.
tstring = {FILE_NAME; long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);

exit;