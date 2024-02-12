%
%  This example code illustrates how to access and visualize
% NSIDC MOD10C1 L3 HDF-EOS2 Grid file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
%  HDF/HDF-EOS data product that is not listed in the HDF-EOS
%  Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the 
% HDF-EOS Forum (http://hdfeos.org/forums).
%                 
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r MOD10C1_A2005018_006_2016141204712_hdf
%
% Tested under: MATLAB R2018b
% Last updated: 2019-02-22

import matlab.io.hdf4.*
import matlab.io.hdfeos.*
                 
% Define file name, grid name, and data field.
FILE_NAME='MOD10C1.A2005018.006.2016141204712.hdf';
GRID_NAME='MOD_CMG_Snow_5km';
DATAFIELD_NAME='Day_CMG_Snow_Cover';

% Open the HDF-EOS2 Grid file.
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
grid_id = gd.attach(file_id, GRID_NAME);
[data, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Detach from the Grid Object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);

% Get information about the spatial extents of the grid.
% [xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the Grid object.
% hdfgd('detach', grid_id);

% Close the file.
% hdfgd('close', file_id);

% Convert the data to double type for plot.
data=double(data);

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


% The following will return unique key values used in the dataset.
z = unique(data);

% To get a similar image to NSIDC browse image [1], 
% construct a color table based on the following assignment:
%
% Key      R  G   B    Name
% ==========================
%  0%     0   100 0    dark green
%  1-99%  127 127 127  grey
%  100%   255 255 255  white
%  107    255 176 255  pink  
%  111    0   0   0    black
%  237    0   0   255  blue
%  239    0   0   205  medium blue                 
%  250    100 200 255
%  253    255 0   255  magenta
%  255    138 42  226  blue violet
%
%
%  We added two more (0% and 1-99%) entries for ice coverage to get better
%  image.


% Plot the data using surfacem and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

% Here is the color map 
cmap=[[0.00 1.00 0.00];  ... %   0% dark green
      [0.50 0.50 0.50];  ... %   1-99% grey
      [1.00 1.00 1.00];  ... %   100% white
      [1.00 0.69 1.00];  ... %   107 pink 
      [0.00 0.00 0.00];  ... %   111 black
      [0.00 0.00 1.00];  ... %   237 blue                     
      [0.00 0.00 0.80];  ... %   239
      [0.39 0.78 1.00];  ... %   250
      [0.00 1.00 0.78];  ... %   253                      
      [0.54 0.16 0.87]]; ... %   255
colormap(cmap);

% Put 1%-99% data under one grey label.
data((data > 0) & (data < 100)) = 99;

% Construct a discrete data for plot.
z = unique(data);
k = size(z);

% Create an array for tick label.
y = zeros(k, 'double');

% There are k different boxes in the colorbar 
% and the value starts from 1 to m.
% Thus, we should increment by (k-1)/k to position
% labels properly starting form ((k-1)/k)/2.
x = 1 + ((k-1)/k)/2;

for m = 1:k
    y(m) = x; 
    data(data == z(m)) = double(m);
    x = x+(k-1)/k;    
end

surfm(lat,lon,data);

caxis([1 m]);
h = colorbar('YTickLabel',...
         {'0% snow', '1-99% snow', '100% snow', 'lake ice', 'night', ...
          'inland water', 'ocean', ...    
          'cloud obsc. water', 'data not mapped', 'fill'}, 'YTick', y);

plotm(coast.lat,coast.long,'k')
                 
tightmap;
                 
title({FILE_NAME;...
       long_name}, ...
      'FontSize',12,'FontWeight','bold', 'Interpreter', 'none');

% Save image.
set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


