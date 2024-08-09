%
% This example code illustrates how to access and visualize NSIDC 
% MYD29P1D HDF-EOS2 Grid file in MATLAB.
%
% If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums).
%
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r MYD29P1D_A2011080_h07v28_061_2021184064216_hdf
%
% Tested under: MATLAB R2023b
% Last updated: 2024-08-09

import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Define file name, grid name, and data field.
FILE_NAME = 'MYD29P1D.A2011080.h07v28.061.2021184064216.hdf';
GRID_NAME = 'MOD_Grid_Seaice_1km';
DATAFIELD_NAME = 'Sea_Ice_by_Reflectance';

% Open the HDF-EOS2 Grid file.
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
grid_id = gd.attach(file_id, GRID_NAME);
[data_raw, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Detach from the Grid object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);

% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Get the long name from data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);


% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% From HDFView, you can find the following attribute.
%
% Key = 0=missing data, 1=no decision, 11=night, 25=land, 37=inland water,
%      39=ocean, 50=cloud, 200=sea ice, 253=land mask, 254=ocean mask,
%     255=fill

% Plot the data using surfacem and axesm.
data = double(data_raw);

% The following will return 5 keys used in the dataset.
z = unique(data_raw);
num_levels = size(z);
k = double(num_levels(1));
% Create an array for tick label.
y = zeros(num_levels, 'double');

% There are k different boxes in the colorbar 
% and the value starts from 1 to m.
% Thus, we should increment by (k-1)/k to position
% labels properly starting form ((k-1)/k)/2.
x = 1 + ((k-1)/k)/2;

for m = 1:num_levels
    y(m) = x;
    data(data_raw == z(m)) = double(m);
    x = x + (k-1)/k;    
end

% Plot data.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

% Set the map parameters.
pole=[-90 0 0];

latlim=ceil(max(max(lat)));

% Specifying 30 limits map to 60S latitude.
axesm('MapProjection','eqaazim', 'FLatLimit', [-Inf 30], ...
      'Origin', pole,'Frame','on','Grid','on','MeridianLabel','on', ...
      'ParallelLabel','on','MLabelParallel',0);

% Here is the color map used by the MODIS group for the Browse images
cmap=[
      [0.00 1.00 0.00];  ... %  25=land [000,255,000],
      [0.14 0.14 0.56];  ... %  37=inland water [035,035,117],
      [0.14 0.14 0.76];  ... %  39=ocean [035,035,117],
      [0.39 0.78 1.00];  ... %  50=cloud [100,200,255],
      [1.00 0.00 0.00]];     % 200=sea ice [255,000,000],
% See: ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD29E1D.005

% Load this colormap into the Matlab graphics system.
colormap(cmap);

% Create the color-mapped level-surface plot with map projection.
surfm(lat,lon,data);

caxis([1 m]);
colorbar('YTickLabel', {'land', 'inland water', 'ocean', 'cloud', ...
                    'sea ice'}, 'YTick', y);

% Load the global coastlines graphics from the '.mat' file.
coast = load('coastlines.mat');
                                   
% Draw the coastlines in black ('k').
plotm(coast.coastlat, coast.coastlon, 'k')

tightmap;

title({strrep(FILE_NAME,'_','\_');...
       strrep(long_name,'_','\_')}, ...
      'FontSize',16,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


