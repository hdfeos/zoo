%
%  This example code illustrates how to access and visualize TRMM version 7
% 2A12 HDF4 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r TRMM_2A12_20140308_92894_7_HDF
%
% Acknowledgement
%
%  Part of this example code is provided by
%  Kelly Luekemeyer, Mapping Toolbox Development, MathWorks, Inc.
%
% Tested under: MATLAB R2014a
% Last updated: 2014-4-1

clear

% Open the HDF4 File
file_name='2A12.20140308.92894.7.HDF';
sd_id = hdfsd('start',file_name, 'rdonly');

% Read data.
datafield_name='surfaceRain';
sds_index = hdfsd('nametoindex', sd_id, datafield_name);
sds_id = hdfsd('select',sd_id, sds_index);
[name, rank, dimsizes, data_type, nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), ...
                       dimsizes);
% Read units attribute.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);
hdfsd('endaccess', sds_id);

% Read latitude.
geo_name='Latitude';
sds_index = hdfsd('nametoindex', sd_id, geo_name);
sds_id = hdfsd('select',sd_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Read longitude.
geo_name='Longitude';
sds_index = hdfsd('nametoindex', sd_id, geo_name);
sds_id = hdfsd('select',sd_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', sd_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Plot the data using surfacem and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=min(min(data));
max_data=max(max(data));

% Create a set of level ranges to be used in converting the data to a
% geolocated image that has a color assigned to each range.
levels = [0.0, 0.1, 1.0, 10.0 30.0];

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
Z (data < 0.0) = 0;

% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];

f = figure('Name', file_name, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto', ...
    'Colormap', jet(2048));

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on')
tightmap
colormap(cmap)

% Use geoshow to plot the data as a geolocated indexed image.
geoshow(lat, lon, uint8(Z), cmap, 'd','image')
geoshow(coast.lat, coast.long, 'Color', 'k')

% Create a colorbar. The colorbar can be moved to the right side of the
% plot by setting 'Location' to 'vertical'.
caxis auto
clevels =  cellstr(num2str(levels'));
clevels = ['missing'; clevels]';

h = lcolorbar(clevels, 'Location', 'horizontal');
set(get(h, 'title'), 'string', units, ...
    'Interpreter', 'none', ...
    'FontSize', 16, 'FontWeight','bold');

% Put title.
tstring = {file_name; datafield_name; ''};
title(tstring, 'Interpreter', 'none', 'FontSize', 16,'FontWeight','bold');
saveas(f, [file_name '.m.png']);

exit;
