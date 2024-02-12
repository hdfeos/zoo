%
%  This example code illustrates how to access and visualize an
%  OBPG S-NPP VIIRS Swath netCDF-4 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r V2013335181200_L2_SNPP_OC_nc
%
% Tested under: MATLAB R2019b
% Last updated: 2020-01-02

% Open the netCDF-4 file.
FILE_NAME='V2013335181200.L2_SNPP_OC.nc';

% Read data from a data field.
DATAFIELD_NAME='geophysical_data/chlor_a';
data = ncread(FILE_NAME, DATAFIELD_NAME);

% Read units.
units = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'units');

% Read long_name.
long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'long_name');

% Read fill value.
fill_value = ncreadatt(FILE_NAME, DATAFIELD_NAME, '_FillValue');

% Read latitude data.
DATAFIELD_NAME='navigation_data/latitude';
lat = ncread(FILE_NAME, DATAFIELD_NAME);

% Read longitude data.
DATAFIELD_NAME='navigation_data/longitude';
lon = ncread(FILE_NAME, DATAFIELD_NAME);

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
Z(data == fill_value) = 0;

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
