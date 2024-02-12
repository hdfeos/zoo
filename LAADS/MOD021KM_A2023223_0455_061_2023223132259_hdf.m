% This example code illustrates how to access and visualize LAADS MODIS Swath
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
% $matlab -nosplash -nodesktop -r MOD021KM_A2023223_0455_061_2023223132259_hdf
%
% Tested under: MATLAB R2023a
% Last updated: 2023-08-16

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Read data field.
FILE_NAME = 'MOD021KM.A2023223.0455.061.2023223132259.hdf';
SWATH_NAME = 'MODIS_SWATH_Type_L1B';

% Get file info.
field_info = hdfinfo(FILE_NAME, 'eos');

% Open HDF-EOS2 swath file.
file_id = sw.open(FILE_NAME, 'rdonly');

% Open swath.
swath_id = sw.attach(file_id, SWATH_NAME);

% Set data field.
DATAFIELD_NAME='EV_1KM_Emissive';

% Read data field.
data1 = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);

% Detach from swath.
sw.detach(swath_id);
sw.close(file_id);

% Read lat and lon data.
GEO_FILE_NAME='MOD03.A2023223.0455.061.2023223112127.hdf';
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

% Subset Band 21 and convert the data to double type for plot.
data=double(squeeze(data1(:,:,2)));
lon=double(lon);
lat=double(lat);

% Read attributes from data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read fill value attribute.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Get long name attribute.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Read units attribute.
units_index = sd.findAttr(sds_id, 'radiance_units');
units = sd.readAttr(sds_id, units_index);

% Read scale factor attribute.
scale_index = sd.findAttr(sds_id, 'radiance_scales');
scale = sd.readAttr(sds_id, scale_index);
scale = double(scale);

% Read offset attribute.
offset_index = sd.findAttr(sds_id, 'radiance_offsets');
offset = sd.readAttr(sds_id, offset_index);
offset = double(offset);

% Read valid_range attribute.
range_index = sd.findAttr(sds_id, 'valid_range');
range = sd.readAttr(sds_id, range_index);

% Terminate access.
sd.endAccess(sds_id);

% Close file.
sd.close(SD_id);

% Replace fill value with NaN.
data(data == fillvalue) = NaN;
data(data > range(2)) = NaN;

% Multiply scale and apply offset, the equation is scale*(data-offset).
data = scale(2) * (data - offset(2));

% Create figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% Set the map parameters.
lon_c = mean(mean(lon));
lat_c = mean(mean(lat));
latlim=ceil(max(max(lat))) - floor(min(min(lat)));

% FlatLimit will give us a zoom-in effect in Ortho projection.
axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'FLatLimit', [-Inf, latlim], ...
       'origin', [lat_c, lon_c])
mlabel('equator')
plabel(0); 
plabel('fontweight','bold')

% Load the coastlines data file.
coast = load('coastlines.mat');

% Plot coastlines in black color.
surfm(lat, lon, data);
plotm(coast.coastlat,coast.coastlon, 'k')

colormap('Jet');
h=colorbar();
set (get(h, 'title'), 'string', strcat('UNITS: ',units));

% Set the title using long name attribute.
title({FILE_NAME; ...
      ['FIELD: Band 21 Radiance from ', long_name ]; 
      [strrep(field_info.Swath.DataFields(3).Dims(1).Name,'_','\_'), '=2' ]}, ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


