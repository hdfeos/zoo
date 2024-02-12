%  This example code illustrates how to access and visualize
% LaRC CALIPSO Lidar Level 2 Aerosol Profile Version 4.21 file in MATLAB. 
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
% Usage: save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r CAL_LID_L2_05kmAPro_Standard_V4_21_2021_12_23T05_45_29ZD_hdf
%
% Tested under: MATLAB R2023a
% Last updated: 2023-06-09

import matlab.io.hdf4.*

% Open the HDF4 File.
FILE_NAME = 'CAL_LID_L2_05kmAPro-Standard-V4-21.2021-12-23T05-45-29ZD.hdf';
SD_id = sd.start(FILE_NAME, 'rdonly');

% Read data.
datafield_name='Extinction_Coefficient_532';
sds_index = sd.nameToIndex(SD_id, datafield_name);
sds_id = sd.select(SD_id, sds_index);
data  = sd.readData(sds_id);

% Read units from the Altitude.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

sd.endAccess(sds_id);

% Read lat.
lat_name='Latitude';
sds_index = sd.nameToIndex(SD_id, lat_name);
sds_id = sd.select(SD_id, sds_index);
lat = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read lon.
lon_name='Longitude';
sds_index = sd.nameToIndex(SD_id, lon_name);
sds_id = sd.select(SD_id, sds_index);
lon = sd.readData(sds_id);
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Convert data to double type for plot.
data = double(data);
lon = double(squeeze(lon(1,:)));
lat = double(squeeze(lat(1,:)));

% Handle fill value.
fill_value = -9999.0;
data(data==fill_value) = NaN;

% Subset data at profile index 380.
profile_index = 380;
data = squeeze(data(profile_index,:));
data = data';
lat = lat';
lon = lon';

% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');


% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south')

% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];
geoshow(coast.lat, coast.long, 'Color', 'k');

cm = colormap('Jet');
scatterm(lat, lon, 1, data);

h = colorbar();
set (get(h, 'title'), 'string', units, 'Interpreter', 'None')

% Put title.
tstring = {FILE_NAME; 'Extinction_Coefficient_532 at Profile = 380'};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;
