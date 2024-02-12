%
%  This example code illustrates how to access and visualize MOD04_3K L2 file
% in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%                                   
% Usage:save this script and run (without .m at the end)
%                                   
% $matlab -nosplash -nodesktop -r MOD04_3K_A2022022_2355_061_2022024190628_hdf
%
% Tested under: MATLAB R2021a
% Last updated: 2022-01-27
%

import matlab.io.hdfeos.*
import matlab.io.hdf4.*
                                   
FILE_NAME='MOD04_3K.A2022022.2355.061.2022024190628.hdf';
SWATH_NAME='mod04';
% Set data field to read.                                   
% DATAFIELD_NAME = 'Angstrom_Exponent_1_Ocean';
DATAFIELD_NAME ='Optical_Depth_Land_And_Ocean';

file_id = sw.open(FILE_NAME, 'rdonly');
swath_id = sw.attach(file_id, SWATH_NAME);
data_i16 = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);
                                   
% Read lat and lon.
lon = sw.readField(swath_id, 'Longitude', [], [], []);
lat = sw.readField(swath_id, 'Latitude', [], [], []);

% Detach Swath object.
sw.detach(swath_id);
sw.close(file_id);

lat=double(lat);
lon=double(lon);

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
scale = double(scale);

% Read add_offset from the data field.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);
offset = double(offset);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

data = double(data_i16);

% Replace fill value with NaN.
data(data_i16==fillvalue) = NaN;

% Apply scale and offset.
data = scale*(data-offset);

% Map to plot the results.
latlim=double([floor(min(min(lat))),ceil(max(max(lat)))]);
lonlim=double([floor(min(min(lon))),ceil(max(max(lon)))]);


% Plot wind speed.
g = figure('Name', FILE_NAME, 'visible', 'off');
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south', 'MapLatLimit',latlim,'MapLonLimit',lonlim)
coast = load('coastlines.mat');

scatterm(lat(:), lon(:), 1, data(:));
colormap('Jet');
h=colorbar();
plotm(coast.coastlat,coast.coastlon,'k');
set(get(h, 'title'), 'string', units, ...
                  'Interpreter', 'none');
title({FILE_NAME; DATAFIELD_NAME}, 'Interpreter', 'none');
saveas(g, [FILE_NAME '.m.png']);
exit;

