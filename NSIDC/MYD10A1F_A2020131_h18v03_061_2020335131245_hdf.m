%
% This example code illustrates how to access and visualize NSIDC
% MYD10A1F L3 HDF-EOS2 Sinusoidal Grid file in MATLAB.
%
% If you have any questions, suggestions, comments on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r MYD10A1F_A2020131_h18v03_061_2020335131245_hdf
%
% Tested under: MATLAB R2019a
% Last updated: 2020-12-03

import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Open the HDF-EOS2 Grid file.
FILE_NAME='MYD10A1F.A2020131.h18v03.061.2020335131245.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='MOD_Grid_Snow_500m';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME='MYD10A1_NDSI_Snow_Cover';
[data, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
% data=data';

% Detach from the Grid Object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);


% lon(lon<0) = lon(lon<0) + 360;

% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);


% Read long_name from the data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

data(data < 200) = 0;
% Set the key values.
z = [0; 200; 201; 211; 237; 239; 250; 254; 255];
num_levels = size(z);
k = double(num_levels(1));
% Create an array for tick label.
y = zeros(num_levels, 'double');



% There are k different boxes in the colorbar 
% and the value starts from 1 to m.
% Thus, we should increment by (k-1)/k to position
% labels properly starting form ((k-1)/k)/2.
x = 1 + ((k-1)/k)/2;

for m = 1:k
    y(m) = x;
    data(data == z(m)) = double(m);
    x = x + (k-1)/k;    
end

f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

% Set map boundary limits.
latlim=[floor(min(min(lat)))-5, ceil(max(max(lat)))+5];
lonlim=[floor(min(min(lon)))-10, ceil(max(max(lon)))+10];

% Plot the data using axesm and surfacem.
axesm('sinusoid', 'Frame', 'on', 'Grid', 'on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelLocation', 5,'PLabelLocation', 5, 'MLabelParallel','south');
coast = load('coast.mat');
surfacem(lat,lon,data);
cmap=[[1.00 1.00 0.00];  ... %   0-100% snow, yellow
      [1.00 0.69 1.00];  ... %   200 missing, pink 
      [0.50 0.50 0.50];  ... %   201 no decision, grey
      [0.00 0.00 0.00];  ... %   211 night, black
      [0.00 1.00 1.00];  ... %   237 in land water, cyan
      [0.00 0.00 1.00];  ... %   239 ocean, blue
      [0.00 1.00 0.00];  ... %   250 cloud, dark green      
      [1.00 0.00 0.00];  ... %   254 detector saturated, red                    
      [0.54 0.16 0.87]];     %   255 fill, purple

colormap(cmap);
caxis([1 m]);
labels = {'0-100% snow', 'missing', 'no decision', 'night', 'inland water', ...
          'ocean', 'cloud', 'detector saturated', 'fill'};
h = colorbar('YTickLabel', labels, 'YTick', y);
plotm(coast.lat,coast.long,'k');
tightmap;

title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
      'FontSize', 12, 'FontWeight', 'bold');

% Save image.
set (get(h, 'title'), 'string', 'keys', 'FontSize', 12, 'FontWeight', 'bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


