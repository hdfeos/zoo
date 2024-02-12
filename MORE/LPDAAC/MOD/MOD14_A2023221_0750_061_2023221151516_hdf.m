% This example code illustrates how to access and visualize LP DAAC MODIS Swath
% file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r MOD14_A2023221_0750_061_2023221151516_hdf
%
% Tested under: MATLAB R2023a
% Last updated: 2023-08-17

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Read lat and lon data.
GEO_FILE_NAME='MOD03.A2023221.0750.061.2023221131337.hdf';
SWATH_NAME='MODIS_Swath_Type_GEO';

% Open the HDF-EOS2 swath File
file_id = sw.open(GEO_FILE_NAME, 'rdonly');

% Open swath.
swath_id = sw.attach(file_id, SWATH_NAME);

% Read lat and lon data.
lon = sw.readField(swath_id, 'Longitude', [], [], []);
lat = sw.readField(swath_id, 'Latitude', [], [], []);

% Detach from swath.
sw.detach(swath_id);
sw.close(file_id);

lon=double(lon);
lat=double(lat);

% Set file name and dataset name.
FILE_NAME = 'MOD14.A2023221.0750.061.2023221151516.hdf';
DATAFIELD_NAME = 'fire mask';

% Read data.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read attributes from data field.
data1 = sd.readData(sds_id);

% Get legend attribute.
long_name_index = sd.findAttr(sds_id, 'legend');
long_name = sd.readAttr(sds_id, long_name_index);

% Read valid_range attribute.
range_index = sd.findAttr(sds_id, 'valid_range');
range = sd.readAttr(sds_id, range_index);

% Terminate access.
sd.endAccess(sds_id);

% Close file.
sd.close(SD_id);

data = double(data1);

% Replace fill value with NaN.
data(data > range(2)) = NaN;


% Create figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible', 'off');

% Set the map parameters.
lon_c = mean(mean(lon));
lat_c = mean(mean(lat));
latlim = ceil(max(max(lat))) - floor(min(min(lat)));

% FlatLimit will give us a zoom-in effect in Ortho projection.
axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'FLatLimit', [-Inf, latlim], ...
       'origin', [lat_c, lon_c])
mlabel('equator')
plabel(0); 
plabel('fontweight','bold')
surfm(lat, lon, data);

% Highlight fire data.
idx = (data > 6);
scatterm(lat(idx), lon(idx), 3, data(idx));

% Load the coastlines data file.                                
coast = load('coastlines.mat');

% Plot coastlines in black color.                                
plotm(coast.coastlat,coast.coastlon, 'k')

colormap('Jet');
h = colorbar();
set(get(h, 'title'), 'string', long_name(length(long_name)-76:end));

% Set the title using long name attribute.
title({FILE_NAME; ...
      ['FIELD: ', DATAFIELD_NAME ]}, ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


