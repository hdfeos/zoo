%
%  This example code illustrates how to access and visualize
% GHRC HDF4 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r LISOTD_HRAC_V2_3_2015_hdf
%
% Tested under: MATLAB R2019b
% Last updated: 2020-01-23
                 
import matlab.io.hdf4.*
                 
% Set file name.
FILE_NAME='LISOTD_HRAC_V2.3.2015.hdf';

% Open file.
SD_id = sd.start(FILE_NAME, 'rdonly');                 

% Read data.
DATAFIELD_NAME='HRAC_COM_FR';
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);
data1 = sd.readData(sds_id);

% Convert 3-D data to 2-D data.
data=squeeze(data1(1,:,:));

% Transpose the data to match the map projection.
data=data';

% Read fill value from the data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Read units attribute from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read long name attribute from the data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Read latitude data field.
lat_name='Latitude';
sds_index = sd.nameToIndex(SD_id, lat_name);
sds_id = sd.select(SD_id, sds_index);
lat = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read lon data field.
lon_name='Longitude';
sds_index = sd.nameToIndex(SD_id, lon_name);
sds_id = sd.select(SD_id, sds_index);
lon = sd.readData(sds_id);
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Convert the data to double type for plot.
data = double(data);
lon = double(lon);
lat = double(lat);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ..., 
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south')
coast = load('coast.mat');
surfm(lat,lon,data);
plotm(coast.lat,coast.long,'k')
tightmap;

% Put colorbar.
colormap('Jet');
h = colorbar();

% Set unit's title.
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 8, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME; long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
