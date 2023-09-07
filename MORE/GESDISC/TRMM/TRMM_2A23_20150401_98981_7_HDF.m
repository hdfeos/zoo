%
%  This example code illustrates how to access and visualize TRMM version 7
% 2A23 HDF4 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r TRMM_2A23_20150401_98981_7_HDF
%
% Tested under: MATLAB R2023a
% Last updated: 2023-09-06
%
% Acknowledgement
%
%  Part of this example code is provided by
%  Kelly Luekemeyer, Mapping Toolbox Development, MathWorks, Inc.
import matlab.io.hdf4.*

% Open the HDF4 File
file_name='2A23.20150401.98981.7.HDF';
sd_id = sd.start(file_name, 'rdonly');

% Read data.
datafield_name='rainType';
sds_index = sd.nameToIndex(sd_id, datafield_name);
sds_id = sd.select(sd_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
data = sd.readData(sds_id);
sd.endAccess(sds_id);
   
% Read latitude.
geo_name='Latitude';
sds_index = sd.nameToIndex(sd_id, geo_name);
sds_id = sd.select(sd_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
lat = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read longitude.
geo_name='Longitude';
sds_index = sd.nameToIndex(sd_id, geo_name);
sds_id = sd.select(sd_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
lon = sd.readData(sds_id);
sd.endAccess(sds_id);

% Close the file.
sd.close(sd_id);

% Convert the data to double type for plot.
data = double(data);
lon = double(lon);
lat = double(lat);

% Plot the data using surfacem and axesm.
latlim = [floor(min(min(lat))), ceil(max(max(lat)))];
lonlim = [floor(min(min(lon))), ceil(max(max(lon)))];
min_data = min(min(data));
max_data = max(max(data));

% Create a set of level ranges to be used in converting the data to a
% geolocated image that has a color assigned to each range.
levels = [100.0, 200.0, 300.0];

% Create a custom color map for 4 different key values.
cmap=[                       %  Key            R   G   B
      [1.00 1.00 1.00];  ... %  1=missing     [255,255,255]
      [0.00 0.00 1.00];  ... %  2=stratiform  [000,000,255]
      [0.00 1.00 0.00];  ... %  3=convective  [000,255,000]
      [0.50 0.50 0.50];  ... %  4=others      [128,128,128]
     ];     

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
    'Position', [0, 0, 800, 600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto', ...
    'Colormap', jet(2048));

axesm('MapProjection', 'eqdcylin', 'Frame', 'on', 'Grid', 'on', ...
      'MeridianLabel', 'on', 'ParallelLabel', 'on', ...
      'MLabelParallel', 'south')
tightmap
colormap(cmap)

% Use geoshow to plot the data as a geolocated indexed image.
geoshow(lat, lon, uint8(Z), cmap, 'd','image')
geoshow(coast.lat, coast.long, 'Color', 'k')

% Create a colorbar. The colorbar can be moved to the right side of the
% plot by setting 'Location' to 'vertical'.
caxis auto
clevels = {'missing', 'strati.', 'convec.', 'others '};
h = lcolorbar(clevels, 'Location', 'horizontal');

% Put title.
tstring = {file_name; datafield_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight', 'bold');
saveas(f, [file_name '.m.png']);

exit;
