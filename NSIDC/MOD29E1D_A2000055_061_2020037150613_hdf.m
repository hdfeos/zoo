%
% This example code illustrates how to access and visualize NSIDC 
% MODIS-T 4km LAMAZ (EASE) Grid file in MATLAB.
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
%  $matlab -nosplash -nodesktop -r MOD29E1D_A2000055_061_2020037150613_hdf
%
% Tested under: MATLAB R2023b
% Last updated: 2024-08-08

import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Define file name, grid name, and data field.
FILE_NAME='MOD29E1D.A2000055.061.2020037150613.hdf';
GRID_NAME='MOD_Grid_Seaice_4km_North';
DATAFIELD_NAME='Sea_Ice_by_Reflectance_NP';

% Open the HDF-EOS2 Grid file.
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
grid_id = gd.attach(file_id, GRID_NAME);
[data_raw, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Detach from the Grid object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);


% Allocate a new variable to map keys.
data = double(data_raw);

% The following will return 10 keys used in the dataset.
%
%  Key = 0=missing data, 1=no decision, 11=night, 25=land, 37=inland water,
%       39=ocean, 50=cloud, 200=sea ice, 253=no input tile expected,
%        _FillValue = 255
z = unique(data_raw)
num_uniq = size(z)
for m = 1:num_uniq
    data(data_raw == z(m)) = double(m);
end

% Plot data.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');
% set the map parameters
% axesm EquaAzim Map Origin Argument -- North Pole
pole=[90 0 0];

axesm('MapProjection','eqaazim', 'FLatLimit',[30, 90], ...
      'Origin',pole, 'Frame','on', 'Grid','on', 'MeridianLabel','on', ...
      'ParallelLabel','on','MLabelParallel',0);      

% Here is the color map used by the browse image.
cmap=[[1.00 1.00 1.00];  ... %   0=missing data [255,255,255],
      [0.72 0.72 0.72];  ... %   1=no decision [184,184,184],
      [1.00 1.00 0.59];  ... %  11=night [255,255,150],
      [0.00 1.00 0.00];  ... %  25=land [000,255,000],
      [0.14 0.14 0.56];  ... %  37=inland water [035,035,117],
      [0.14 0.14 0.76];  ... %  39=ocean [035,035,117],
      [0.39 0.78 1.00];  ... %  50=cloud [100,200,255],
      [1.00 0.00 0.00];  ... % 200=sea ice [255,000,000],
      [0.25 0.25 0.25];  ... % 253=no input tile expected [000,000,000],
      [0.00 0.00 0.00]]; ... % 255=_FillValue [000,000,000]

% Load the custom colormap.
colormap(cmap);
surfm(lat,lon,data);
caxis([1 m]);

% Create an array for tick label.
k = num_uniq;
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
h = colorbar('YTickLabel', ...
         {'missing data', 'no decision', 'night', 'land', ...
          'inland water', 'ocean', 'cloud',  ...
          'sea ice', 'no input tile expected', 'fill value'});

% Draw the coastlines in color black ('k').
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k');

tightmap;

title({strrep(FILE_NAME,'_','\_');...
       strrep(DATAFIELD_NAME,'_','\_')}, ...
      'FontSize',16,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
