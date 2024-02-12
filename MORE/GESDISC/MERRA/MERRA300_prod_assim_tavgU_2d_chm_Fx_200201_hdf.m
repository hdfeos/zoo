%
%  This example code illustrates how to access and visualize
%  MERRA L3 Grid file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this
%  example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r MERRA300_prod_assim_tavgU_2d_chm_Fx_200201_hdf
%
% Tested under: MATLAB R2020a
% Last updated: 2020-10-20

import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Open HDF-EOS2 Grid file.
FILE_NAME = 'MERRA300.prod.assim.tavgU_2d_chm_Fx.200201.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data.
GRID_NAME = 'EOSGRID';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME = 'CLDHGH';

[data, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);


% Convert the data to double type for plot.
data = double(data);

gd.detach(grid_id);
gd.close(file_id);

% Read attributes.
SD_id = sd.start(FILE_NAME, 'rdonly');
DATAFIELD_NAME = 'CLDHGH';

sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);

sds_id = sd.select(SD_id, sds_index);

% Read fillvalue and missing value.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

missingvalue_index = sd.findAttr(sds_id, 'missing_value');
missingvalue = sd.readAttr(sds_id, missingvalue_index);

% Read units.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale_factor.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);

% Convert to double type for plot.
scale = double(scale);

% Read add_offset from a Data Field
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);

offset = double(offset);

sd.endAccess(sds_id);
sd.close(SD_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Replace the missing value with NaN.
data(data==missingvalue) = NaN;

% Multiply scale and add offset.
data = data*scale + offset ;

% Plot the data using contourfm and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];


f=figure('Name', FILE_NAME, 'visible','off');

subplot(2,2,1);
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ... 
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize',4);
coast = load('coast.mat');
% Subset data.
data1 = squeeze(data(:,:,2));
surfm(lat,lon,data1);
colormap('Jet');
min_data=floor(min(min(data1)));
max_data=ceil(max(max(data1)));
caxis([min_data max_data]); 
h=colorbar('YTick', min_data:0.1:max_data);
plotm(coast.lat,coast.long,'k');
title({FILE_NAME; [DATAFIELD_NAME ' at TIME=1']}, ...
      'Interpreter', 'None', 'FontSize', 8);
set(get(h, 'title'), 'string', units);
tightmap;
grid on;

subplot(2,2,2);
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ... 
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize',4);
coast = load('coast.mat');
% Subset data.
data2 = squeeze(data(:,:,3));
surfm(lat,lon,data2);
colormap('Jet');
min_data=floor(min(min(data2)));
max_data=ceil(max(max(data2)));
caxis([min_data max_data]); 
h=colorbar('YTick', min_data:0.1:max_data);
plotm(coast.lat,coast.long,'k')
title({[DATAFIELD_NAME ' at TIME=2']}, ...
      'Interpreter', 'None', 'FontSize', 8);
set(get(h, 'title'), 'string', units);
tightmap;
grid on;

subplot(2,2,3);
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ... 
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize',4);
coast = load('coast.mat');
% Subset data.
data3 = squeeze(data(:,:,4));
surfm(lat,lon,data3);
colormap('Jet');
min_data=floor(min(min(data3)));
max_data=ceil(max(max(data3)));
caxis([min_data max_data]); 
h=colorbar('YTick', min_data:0.1:max_data);
plotm(coast.lat,coast.long,'k')
title({[DATAFIELD_NAME ' at TIME=4']}, ...
      'Interpreter', 'None', 'FontSize', 8);
set(get(h, 'title'), 'string', units);
tightmap;
grid on;

subplot(2,2,4);
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ... 
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize',4);
coast = load('coast.mat');
% Subset data.
data4 = squeeze(data(:,:,8));
surfm(lat,lon,data4);
colormap('Jet');
min_data=floor(min(min(data4)));
max_data=ceil(max(max(data4)));
caxis([min_data max_data]); 
h=colorbar('YTick', min_data:0.1:max_data);
plotm(coast.lat,coast.long,'k')
title({[DATAFIELD_NAME ' at TIME=8']}, ...
      'Interpreter', 'None', 'FontSize', 8);
set(get(h, 'title'), 'string', units);
tightmap;
grid on;
saveas(f, [FILE_NAME '.m.png']);
exit;