%
%  This example code illustrates how to access and visualize NSIDC
%  MOD29 Level 2 HDF-EOS2 Swath file in MATLAB.
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
%  $matlab -nosplash -nodesktop -r MOD29_A2013196_1250_061_2021233075404_hdf
%
% Tested under: MATLAB R2023b
% Last updated: 2024-08-07

import matlab.io.hdfeos.*
import matlab.io.hdf4.*


% Set file name.
FILE_NAME = 'MOD29.A2013196.1250.061.2021233075404.hdf';

% Open the HDF-EOS2 swath file.
file_id = sw.open(FILE_NAME, 'rdonly');

% Set swath name.   
SWATH_NAME = 'MOD_Swath_Sea_Ice';
   
% Open swath.
swath_id = sw.attach(file_id, SWATH_NAME);

% Read data from a data field.
DATAFIELD_NAME = 'Ice_Surface_Temperature';

% Read the dataset.
data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);

% Detach from the swath object.
sw.detach(swath_id);
sw.close(file_id);

% Read lat and lon data from the matching geo-location file.
GEO_FILE_NAME='MOD03.A2013196.1250.061.2017299150213.hdf';
SWATH_NAME='MODIS_Swath_Type_GEO';

% Open the HDF-EOS2 swath file.
file_id = sw.open(GEO_FILE_NAME, 'rdonly');

% Open swath.
swath_id = sw.attach(file_id, SWATH_NAME);

% Read lat and lon.
lon = sw.readField(swath_id, 'Longitude', [], [], []);
lat = sw.readField(swath_id, 'Latitude', [], [], []);

% Detach swath.
sw.detach(swath_id);
sw.close(file_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
DATAFIELD_NAME = 'Ice_Surface_Temperature';
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read fill value attribute.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Read long_name attribute.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Read valid range.
valid_range_index = sd.findAttr(sds_id, 'valid_range');
valid_range = sd.readAttr(sds_id, valid_range_index);

% Read units.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale_factor.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);
scale = double(scale);

% Read add_offset.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset= sd.readAttr(sds_id, offset_index);
offset = double(offset);

% Terminate access to the dataset.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);


% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Replace values outside of the valid_range with NaN.
data(data<valid_range(1)) = NaN;
data(data>valid_range(2)) = NaN;

% Multiply scale and add offset.
data = scale*data + offset;

% Plot data.
pole=[-90 0 0];
latlim=[-90, ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f = figure('Name', FILE_NAME, 'visible', 'off');

axesm('MapProjection','stereo', ...
      'MapLatLimit', latlim, 'MapLonLimit', lonlim, ...
      'Origin', pole, 'Frame', 'on', 'Grid', 'on', ...
      'MeridianLabel', 'on', 'ParallelLabel', 'on')
   
surfm(lat, lon, data);
colormap('Jet');
h = colorbar();

% Plot coast lines.
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k')

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
    'FontSize', 10, 'FontWeight', 'bold');

set (get(h, 'title'), 'string', units, 'Interpreter', 'None', ...
                   'FontSize',10,'FontWeight','bold');
saveas(f,[FILE_NAME '.m.png']);
exit;
