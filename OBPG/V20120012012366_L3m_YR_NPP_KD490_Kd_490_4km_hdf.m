%
%  This example code illustrates how to access and visualize OBPG
%  VIIRS HDF4 Grid file in MATLAB. 
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
%
% Tested under: MATLAB R2012a
% Last updated: 2013-12-20

clear

% Open the HDF4 file.
FILE_NAME='V20120012012366.L3m_YR_NPP_KD490_Kd_490_4km.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from a data field.
DATAFIELD_NAME='l3m_data';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[~,~, dimsizes] = hdfsd('getinfo', sds_id);
[~, n] = size(dimsizes);
data = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Transpose the data to match the map projection
data=data';


% The lat and lon should be calculated using lat and lon of southwest point.
% Then we need number of lines and columns to calculate the lat and lon
% step. Assume even space between lat and lon points to get all lat and lon
% data.
smlat_index = hdfsd('findattr', SD_id, 'SW Point Latitude');
[smlat, status] = hdfsd('readattr',SD_id, smlat_index);

wmlon_index = hdfsd('findattr', SD_id, 'SW Point Longitude');
[wmlon, status] = hdfsd('readattr',SD_id, wmlon_index);

nlat_index = hdfsd('findattr', SD_id, 'Number of Lines');
[nlat, status] = hdfsd('readattr',SD_id, nlat_index);

nlon_index = hdfsd('findattr', SD_id, 'Number of Columns');
[nlon, status] = hdfsd('readattr',SD_id, nlon_index);

latstep_index = hdfsd('findattr', SD_id, 'Latitude Step');
[latstep, status] = hdfsd('readattr',SD_id, latstep_index);

lonstep_index = hdfsd('findattr', SD_id, 'Longitude Step');
[lonstep, status] = hdfsd('readattr',SD_id, lonstep_index);

% Read units and parameter attributes.
% In this product, the "units" and "long_name" is stored as the file attribute
% rather than SDS attribute.
units_index = hdfsd('findattr', SD_id, 'Units');
[units, status] = hdfsd('readattr',SD_id, units_index);

long_name_index = hdfsd('findattr', SD_id, 'Parameter');
[long_name, status] = hdfsd('readattr',SD_id, long_name_index);

% Calculate lat/lon.
smlat = double(smlat); wmlon = double(wmlon); nlat = double(nlat);
nlon = double(nlon); latstep = double(latstep); lonstep = double(lonstep);

nmlat = smlat + (nlat-1)*latstep;
emlon = wmlon + (nlon-1)*lonstep;

lat = nmlat : (-latstep) : smlat;
lon = wmlon : (lonstep) : emlon;


% Read fill value from the data field attribute.
% We will skip reading scale and offset because they are 1.0 and 0.0.
fill_index = hdfsd('findattr', sds_id, 'Fill');
[fill_value, status] = hdfsd('readattr',sds_id, fill_index);
fill_value = double(fill_value);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Create a set of level ranges to be used in converting the data to a
% geolocated image that has a color assigned to each range.
levels = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 7];

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

% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];

f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto', ...
    'Colormap', jet(2048));

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on')
tightmap
colormap(cmap)

% Geoshow requires 2-D lat/lon.
lat = kron(lat, ones(nlon, 1));
lat = lat';
lon = kron(lon, ones(nlat, 1));

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
tstring = {FILE_NAME; long_name; ''};
title(tstring, 'Interpreter', 'none', 'FontSize', 16,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);

exit;
