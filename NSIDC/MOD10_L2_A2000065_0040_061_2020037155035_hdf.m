%
% This example code illustrates how to access and visualize NSIDC MODIS 
% MOD10 L2 HDF-EOS2 Swath file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MOD10_L2_A2000065_0040_061_2020037155035_hdf
%
% Tested under: MATLAB R2023b
% Last updated: 2024-08-05

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Read data field
FILE_NAME='MOD10_L2.A2000065.0040.061.2020037155035.hdf';
SWATH_NAME='MOD_Swath_Snow';

% get file info
field_info = hdfinfo(FILE_NAME, 'eos');
% struct field_info.Swath.DataFields(1).Dims 3x1 struct array with fields:
%  Name Size

% Opening the HDF-EOS2 Swath File
file_id = sw.open(FILE_NAME, 'rdonly');
% Open swath
swath_id = sw.attach(file_id, SWATH_NAME);

% Define the Data Field
DATAFIELD_NAME='NDSI_Snow_Cover';


% Read the dataset.
data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);

% Read lat and lon dataset.
lon = sw.readField(swath_id, 'Longitude', [], [], []);
lat = sw.readField(swath_id, 'Latitude', [], [], []);

% Detach Swath object.
sw.detach(swath_id);
sw.close(file_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

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

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Set the map parameters.
latlim = [floor(min(min(lat))),ceil(max(max(lat)))];
lonlim = [floor(min(min(lon))),ceil(max(max(lon)))];

% create the graphics figure -- 'visible'->'off' = off-screen rendering
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');
pole=[90 0 0];
axesm('MapProjection','stereo','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'Origin', pole ,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')


data(data <= 212.0) = 0.5;
data(data > 212.0) = 1.5;
surfm(lat, lon, data);

% Put colormap.
% Create a custom color map for 2 different Feature Type key values.
cmap=[                       %  Key            R   G   B
      [1.00 0.00 1.00];  ... %  1=night       [255,000,255]                    
      [0.00 0.00 1.00];  ... %  2=inland water[000,000,255]
     ];     

colormap(cmap);
caxis([0 2]);

h=colorbar();

% Load the coastlines data file.
coast = load('coastlines.mat');

% Plot coastlines in color black ('k').
plotm(coast.coastlat, coast.coastlon,'k')

% Put colorbar.
% y = [1, 2];
y = [0.5, 1.5];
h = colorbar('YTickLabel', {'night', 'inland water'}, 'YTick', y);

% Set the title using long_name.
title({FILE_NAME; long_name}, ...
      'interpreter', 'none', 'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


