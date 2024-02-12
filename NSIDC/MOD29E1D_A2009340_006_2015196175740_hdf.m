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
%  $matlab -nosplash -nodesktop -r MOD29E1D_A2009340_006_2015196175740_hdf
%
% Tested under: MATLAB R2018a
% Last updated: 2019-04-11

import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Define file name, grid name, and data field.
FILE_NAME='MOD29E1D.A2009340.006.2015196175740.hdf';
GRID_NAME='MOD_Grid_Seaice_4km_South';
DATAFIELD_NAME='Sea_Ice_by_Reflectance_SP';

% Open the HDF-EOS2 Grid file.
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
grid_id = gd.attach(file_id, GRID_NAME);
[data_raw, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Detach from the Grid object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);

% from HDFView MOD29E1D.A2009340.005.2009341094922.hdf we see the Key to
% the discrete levels ion the data field
%  Key = 0=missing data, 1=no decision, 11=night, 25=land, 37=inland water,
%       39=ocean, 50=cloud, 200=sea ice, 253=no input tile expected,
%      254=non-production mask; _FillValue = 255

% Plot the data using contourfm and axesm

% Thus, we make data linear.
data = double(data_raw);

% The following will return 7 keys used in the dataset.
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
% axesm EquaAzim Map Origin Argument -- South Pole
pole=[-90 0 0];

axesm('MapProjection','eqaazim', 'FLatLimit',[-Inf 60], ...
      'Origin',pole, 'Frame','on', 'Grid','on', 'MeridianLabel','on', ...
      'ParallelLabel','on','MLabelParallel',0);      
coast = load('coast.mat');

% Here is the color map used by the MODIS group for the Browse images
cmap=[
      [0.00 1.00 0.00];  ... %  25=land [000,255,000],
      [0.14 0.14 0.46];  ... %  37=inland water [035,035,117],
      [0.14 0.14 0.46];  ... %  39=ocean [035,035,117],
      [0.39 0.78 1.00];  ... %  50=cloud [100,200,255],
      [1.00 0.00 0.00];  ... % 200=sea ice [255,000,000],
      [0.00 0.00 0.00];  ... % 253=no input tile expected [000,000,000],
      [0.00 0.00 0.00]]; ... % 255=_FillValue [000,000,000]
% See: ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD29E1D.005/

% load colormap into MATLAB's graphics system
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
             {'land', 'inland water', 'ocean', 'cloud', ...
              'sea ice', 'no input tile expected', 'fill value'}, 'YTick', y);

% draw the coastlines in color black ('k')
plotm(coast.lat,coast.long,'k');

tightmap;

title({strrep(FILE_NAME,'_','\_');...
       strrep(DATAFIELD_NAME,'_','\_')}, ...
      'FontSize',16,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;