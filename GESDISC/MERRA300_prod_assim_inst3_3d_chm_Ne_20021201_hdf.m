%
%  This example code illustrates how to access and visualize
% GES DISC MERRA HDF-EOS2 Grid file in MATLAB. 
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
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r MERRA300_prod_assim_inst3_3d_chm_Ne_20021201_hdf
%
% Tested under: MATLAB R2020a
% Last updated: 2020-10-21

import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Open the HDF-EOS2 Grid file.
file_name='MERRA300.prod.assim.inst3_3d_chm_Ne.20021201.hdf';
file_id = gd.open(file_name, 'rdonly');

% Read data from a data field.
grid_name='EOSGRID';
grid_id = gd.attach(file_id, grid_name);

datafield_name='PLE';

[data1, lat, lon] = gd.readField(grid_id, datafield_name, [], [], []);

% Convert 4-D data to 2-D data.
data=squeeze(data1(:,:,73,2));

% Convert the data to double type for plot.
data=double(data);


% Detach from the grid object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);

% Read attributes from the data field.
SD_id = sd.start(file_name, 'rdonly');
sds_index = sd.nameToIndex(SD_id, datafield_name);
sds_id = sd.select(SD_id, sds_index);

% Read fillvalue and missing value from the data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);
missingvalue_index = sd.findAttr(sds_id, 'missing_value');
missingvalue = sd.readAttr(sds_id, missingvalue_index);

% Read long_name from the data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Read units from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale_factor from a data field.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);

% Convert to double type for plot.
scale = double(scale);

% Read add_offset from a data field.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);

% Convert to double type for plot.
offset = double(offset);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Replace the missing value with NaN.
data(data==missingvalue) = NaN;

% Multiply scale and adding offset.
data = data*scale + offset ;

% Plot the data.
latlim = [floor(min(min(lat))),ceil(max(max(lat)))];
lonlim = [floor(min(min(lon))),ceil(max(max(lon)))];
min_data = floor(min(min(data)));
max_data = ceil(max(max(data)));

f = figure('Name', file_name, 'visible', 'off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south');
coast = load('coast.mat');
lat = fliplr(lat);
surfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = floor((max_data - min_data) / ntickmarks);

h=colorbar('YTick', min_data:granule:max_data);

plotm(coast.lat,coast.long,'k')

title({file_name; ...
       [long_name  [' at TIME=1 and Height=72']]}, ...
       'Interpreter', 'None', 'FontSize', 16,'FontWeight','bold');
tightmap;
set(get(h, 'title'), 'string', units, 'FontSize', 8,'FontWeight','bold');
saveas(f, [file_name '.m.png']);
exit;
