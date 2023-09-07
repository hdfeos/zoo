%
%  This example code illustrates how to access and visualize TRMM version 7
% 2A23 HDF4 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r TRMM_2A23_20150401_98981_7_HDF_s
%
% Tested under: MATLAB R2023a
% Last updated: 2023-09-07
%
% Acknowledgement
%
%  Part of this example code is provided by
%  Kelly Luekemeyer, Mapping Toolbox Development, MathWorks, Inc.
import matlab.io.hdf4.*

% Open the HDF4 File
file_name='2A23.20150401.98981.7.HDF';
sd_id = sd.start(file_name, 'rdonly');

% Read data.
datafield_name='freezH';
sds_index = sd.nameToIndex(sd_id, datafield_name);
sds_id = sd.select(sd_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
data = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read units attribute.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);
sd.endAccess(sds_id);
   
% Read latitude.
geo_name='Latitude';
sds_index = sd.nameToIndex(sd_id, geo_name);
sds_id = sd.select(sd_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
lat = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read longitude.
geo_name='Longitude';
sds_index = sd.nameToIndex(sd_id, geo_name);
sds_id = sd.select(sd_id, sds_index);
[name, dimsizes, data_type, nattrs] = sd.getInfo(sds_id);
lon = sd.readData(sds_id);
sd.endAccess(sds_id);

% Close the file.
sd.close(sd_id);

% Convert the data to double type for plot.
data = double(data);
lon = double(lon);
lat = double(lat);

% Find indexes for the region of interest.
x = (lon > 16.3449768409 & lon < 32.830120477 & ...
     lat > -34.8191663551 & lat < 32.830120477);
lon_s = lon(x);
lat_s = lat(x);
data_s = data(x);

f = figure('Name', file_name, ...
    'Renderer', 'zbuffer', ...
    'Position', [0, 0, 800, 600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto', ...
    'Colormap', jet(2048));

axesm('MapProjection', 'eqdcylin', 'Frame', 'on', 'Grid', 'on', ...
      'MeridianLabel', 'on', 'ParallelLabel', 'on', ...
      'MLabelParallel', 'south')
tightmap
scatterm(lat_s(:), lon_s(:), 1, data_s(:));
colormap('Jet');

h=colorbar();

% Draw unit.
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Draw coast lines.
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k');


% Put title.
tstring = {file_name; datafield_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight', 'bold');
saveas(f, [file_name '.s.m.png']);

exit;
