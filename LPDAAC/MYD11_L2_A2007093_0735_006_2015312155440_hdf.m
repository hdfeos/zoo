%
% This example code illustrates how to access and visualize LP DAAC MYD11_L2 v6
% HDF-EOS2 Swath file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MYD11_L2_A2007093_0735_006_2015312155440_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-04-20

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Open file.
FILE_NAME='MYD11_L2.A2007093.0735.006.2015312155440.hdf';
file_id = sw.open(FILE_NAME, 'rdonly');

% Open swath.
SWATH_NAME='MOD_Swath_LST';
swath_id = sw.attach(file_id, SWATH_NAME);

% Read the dataset.
DATAFIELD_NAME='LST';
data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);

% Detach Swath object.
sw.detach(swath_id);

% Close file.
sw.close(file_id);

% Open geo-location file.
GEO_FILE_NAME='MYD03.A2007093.0735.006.2012073162442.hdf';
file_id = sw.open(GEO_FILE_NAME, 'rdonly');

% Open swath.
SWATH_NAME='MODIS_Swath_Type_GEO';
swath_id = sw.attach(file_id, SWATH_NAME);

% Read lat and lon dataset.
lon = sw.readField(swath_id, 'Longitude', [], [], []);
lat = sw.readField(swath_id, 'Latitude', [], [], []);

% Detach Swath object.
sw.detach(swath_id);

% Close file.
sw.close(file_id);

% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read _FillValue from data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Get the long name from data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Read units from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale_factor from the data field.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);
scale = double(scale(1));

% Read add_offset from the data field.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);
offset = double(offset(1));

% Read valid_range from the data field.
range_index = sd.findAttr(sds_id, 'valid_range');
range = sd.readAttr(sds_id, range_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);


% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;
data(data > double(range(2))) = NaN;
data(data < double(range(1))) = NaN;

% Multiply scale and add offset, the equation is scale *(data-offset).
data = scale*(data-offset);

% Set the map parameters.
lon_c = mean(mean(lon));
lat_c = mean(mean(lat));
latlim=ceil(max(max(lat))) - floor(min(min(lat)));

% create the graphics figure -- 'visible'->'off' = off-screen rendering
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','eqdcylin', ...
      'MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelLocation',4,'PLabelLocation',2)

% Load the coastlines data file.
coast = load('coast.mat');

% Plot coastlines in color black ('k').
plotm(coast.lat,coast.long,'k');

% surfm() is faster than controufm.
surfm(lat, lon, data);

% Put colormap.
colormap('Jet');
h=colorbar();
set (get(h, 'title'), 'string', units);

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
