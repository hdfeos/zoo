% This example code illustrates how to access and visualize AADS MODIS Swath
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
% $matlab -nosplash -nodesktop -r MOD06_L2_A2010001_0000_061_2017308133515_hdf
%
% Tested under: MATLAB R2023b
% Last updated: 2024-06-14

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Read lat and lon data from geo-location file.
GEO_FILE_NAME='MOD03.A2010001.0000.061.2017255193343.hdf';
SWATH_NAME='MODIS_Swath_Type_GEO';

% Open the HDF-EOS2 swath geo-location file.
file_id = sw.open(GEO_FILE_NAME, 'rdonly');

% Open swath.
swath_id = sw.attach(file_id, SWATH_NAME);

% Read lat and lon.
lon = sw.readField(swath_id, 'Longitude', [], [], []);
lat = sw.readField(swath_id, 'Latitude', [], [], []);

% Detach from swath.
sw.detach(swath_id);
sw.close(file_id);

lon=double(lon);
lat=double(lat);

% Set file name and dataset name.
FILE_NAME = 'MOD06_L2.A2010001.0000.061.2017308133515.hdf';
DATAFIELD_NAME = 'Cloud_Optical_Thickness';

% Read data.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read attributes from data field.
data1 = sd.readData(sds_id);

% Read fill value attribute.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Read add_offset attribute.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);
offset = double(offset);

% Read long name attribute.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Read scale_factor attribute.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);
scale = double(scale);

% Read units attribute.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read valid_range attribute.
range_index = sd.findAttr(sds_id, 'valid_range');
range = sd.readAttr(sds_id, range_index);

% Terminate access.
sd.endAccess(sds_id);

% Close file.
sd.close(SD_id);

data = double(data1);
% Replace fill value with NaN.
data(data == fillvalue) = NaN;
data(data > double(range(2))) = NaN;
data(data < double(range(1))) = NaN;

% Apply scale and offset.
data = scale*(data-offset);

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

% Load the coastlines data file.                                
coast = load('coastlines.mat');

% Plot coastlines in black color.                                
plotm(coast.coastlat, coast.coastlon, 'k')

colormap('Jet');
h = colorbar();
set(get(h, 'title'), 'string', units);

% Set title using long_name.
str1 = extractBefore(long_name, 82);
strr = extractAfter(long_name, 81);
str2 = extractBefore(strr, 73);
str3 = extractAfter(strr, 72);
title({FILE_NAME; ...
      str1; str2 ; str3}, ...
      'interpreter', 'none', 'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


