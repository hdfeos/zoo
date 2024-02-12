%
%  This example code illustrates how to access and visualize GESDISC TRMM
% version 7 HDF4 Level 1B file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r TRMM_1B11_20100725_72299_7_HDF
%
% Tested under: MATLAB R2020a
% Last updated: 2020-06-24

% See [1] for new HDF4 APIs.
import matlab.io.hdf4.*

% Open the HDF4 File.
FILE_NAME = '1B11.20100725.72299.7.HDF';
SD_id = sd.start(FILE_NAME, 'read');

% Read data to plot.
datafield_name='lowResCh';
sds_index = sd.nameToIndex(SD_id, datafield_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
data = sd.readData(sds_id);

% Read units attribute.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale_factor attribute.
sf_index = sd.findAttr(sds_id, 'scale_factor');
scale_factor = sd.readAttr(sds_id, sf_index);

% Read add_offset attribute.
ao_index = sd.findAttr(sds_id, 'add_offset');
add_offset = sd.readAttr(sds_id, ao_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Read lat/lon information.
lat_name='Latitude';
sds_index = sd.nameToIndex(SD_id, lat_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
lat = sd.readData(sds_id);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

lon_name='Longitude';
sds_index = sd.nameToIndex(SD_id, lon_name);
sds_id = sd.select(SD_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
lon = sd.readData(sds_id);

% Terminate access to the corresponding data set
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Convert the data to double type for plot.
data=squeeze(double(data(1,1,:)));
lon=squeeze(double(lon(1,:)));
lat=squeeze(double(lat(1,:)));
lat = lat';
lon = lon';

% Apply scale and offset according to
% http://disc.sci.gsfc.nasa.gov/precipitation/documentation/TRMM_README/TRMM_1B11_readme.shtml
data = data / scale_factor + add_offset;


% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
         'Renderer', 'zbuffer', ...
         'Position', [0,0,800,600], ...                  
         'visible', 'off');

% Create the plot.
axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on')

% Plot the dataset value.
cm = colormap('Jet');
lat = lat(:)';
lon = lon(:)';
data = data(:)';
scatterm(lat, lon, 1, data);
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k');
h = colorbar();
units_str = sprintf('%s', char(units));

% Unit string is quite long. Use ylabel to avoid clutter at the top
% of colorbar.
ylabel(h, units_str)
  
% Put title. 
tstring = {FILE_NAME;[datafield_name, ' (Channel=1 - 10GHz Vertical)']};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

% Reference
% [1] https://www.mathworks.com/help/matlab/ref/matlab.io.hdf4.sd.html
