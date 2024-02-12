%
% This example code illustrates how to access and visualize LAADS
% MODIS MOD04 L2 swath v6.1 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r MOD04_L2_A2019026_0555_061_2019030074248_hdf
%
% Tested under: MATLAB R2020a
% Last updated: 2020-08-05
import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Set file name and swath name.
FILE_NAME='MOD04_L2.A2019026.0555.061.2019030074248.hdf';
SWATH_NAME='mod04';

% Open HDF-EOS2 file.
file_id = sw.open(FILE_NAME, 'rdwr');

% Open swath.
swath_id = sw.attach(file_id, SWATH_NAME);

% Read data from a data field.
DATAFIELD_NAME='Effective_Optical_Depth_Best_Ocean';
data3D = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);

% Subset band.
data = data3D(:,:,1);

% Read lat and lon data.
lon = sw.readField(swath_id, 'Longitude', [], [], []);
lat = sw.readField(swath_id, 'Latitude', [], [], []);

% Detach from the Swath Object.
sw.detach(swath_id);
sw.close(file_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Read attributes from the data field
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
scale = double(scale);

% Read add_offset from the data field.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);
offset = double(offset);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Multiply scale and adding offset, the equation is scale *(data-offset).
data = scale*(data-offset);

% Plot the data using contourfm and axesm.
pole=[-90 0 0];
latlim=[-90,ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible', 'off');

latlim = [floor(min(min(lat))),ceil(max(max(lat)))];
lonlim = [floor(min(min(lon))),ceil(max(max(lon)))];

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

% surfm is faster than contourfm.
surfm(lat, lon, data);
colormap('Jet');
h=colorbar();
plotm(coast.lat,coast.long,'k')

% Draw unit.
set(get(h, 'title'), 'string', 'None', ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME;DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
