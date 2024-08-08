%
% This example code illustrates how to access and visualize NSIDC
% MOD10A1 HDF-EOS2 Sinusoidal Grid file in MATLAB.
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
% $matlab -nosplash -nodesktop -r MOD10A1_A2000065_h00v08_061_2020037215022_hdf
%
% Tested under: MATLAB R2023b
% Last updated: 2024-08-08

import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Open the HDF-EOS2 Grid file.
FILE_NAME='MOD10A1.A2000065.h00v08.061.2020037215022.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='MOD_Grid_Snow_500m';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME='NDSI_Snow_Cover';
[data, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
% data=data';

% Detach from the Grid Object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);


lon(lon<0) = lon(lon<0) + 360;

% Read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read units from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read long_name from the data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Terminate access to the corresponding data set.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);


% The following will return 3 keys used in the dataset.
z = unique(data);
num_levels = size(z);
k = double(num_levels(1));
% Create an array for tick label.
y = zeros(num_levels, 'double');

% There are k different boxes in the colorbar 
% and the value starts from 1 to m.
% Thus, we should increment by (k-1)/k to position
% labels properly starting form ((k-1)/k)/2.
x = 1 + ((k-1)/k)/2;

for m = 1:num_levels(1)
    y(m) = x;
    data(data == z(m)) = double(m);
    x = x + (k-1)/k;    
end

f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

% Set map boundary limits.
latlim=[floor(min(min(lat)))-20, ceil(max(max(lat)))+20];
lonlim=[floor(min(min(lon)))-20, ceil(max(max(lon)))+20];

% Plot the data using axesm and surfacem.
axesm('sinusoid', 'Frame', 'on', 'Grid', 'on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelLocation', 5,'PLabelLocation', 5, 'MLabelParallel','south');
coast = load('coastlines.mat');
surfacem(lat, lon, data);


% We picked grey to make fill values visible.
% You can use (0,0,0) for the first entry to hide fill value.
%
% Here is the color map used by the MODIS group for the Browse images
%       [0.00 1.00 0.00];  ... %  25=land   [000,255,000],
cmap=[                       %  Key         R   G   B
      [1.00 1.00 1.00];  ... %  0=missing [255,255,255],    
      [0.14 0.14 0.76];  ... %  239=ocean  [035,035,117],
      [0.00 0.00 0.00]];     %  255=fill  [000,000,000],

colormap(cmap);
caxis([1 m]); 
h = colorbar('YTickLabel', {'missing', 'ocean', 'fill'}, 'YTick', y);

plotm(coast.coastlat, coast.coastlon, 'k');

tightmap;

title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
      'FontSize',12,'FontWeight','bold');

% Save image.
set (get(h, 'title'), 'string', units, 'FontSize', 12, 'FontWeight', 'bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


