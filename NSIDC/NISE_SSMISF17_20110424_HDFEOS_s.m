%
% This example code illustrates how to access and visualize NSIDC 
% NISE HDF-EOS2 Grid file in MATLAB.
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
%  $matlab -nosplash -nodesktop -r NISE_SSMISF17_20110424_HDFEOS
%
% Tested under: MATLAB R2018a
% Last updated: 2019-05-01

import matlab.io.hdf4.*
import matlab.io.hdfeos.*

% Define file name, grid name, and data field.
FILE_NAME='NISE_SSMISF17_20110424.HDFEOS';
GRID_NAME='Southern Hemisphere';
DATAFIELD_NAME='Extent';

% Open the HDF-EOS2 Grid file.
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
grid_id = gd.attach(file_id, GRID_NAME);
[data, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Detach from the Grid object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);

long_name = DATAFIELD_NAME;

% from HDFView NISE_SSMISF17_20110424.HDFEOS
% data_grid_key = Data Value     Parameter
%                 0              snow-free land
%                 1-100          sea ice concentration percentage
%                 101            permanent ice (Greenland, Antarctica)
%                 102            not used
%                 103            dry snow
%                 104            wet snow
%                 105-251        not used
%                 252            mixed pixels at coastlines
%                               (unable to reliably apply microwave algorithm)
%                 253            suspect ice value
%                 254            corners(undefined)
%                 255            ocean


% Re-bin data based on the key and color map.
data(data > 0  & data < 21) = 20;
data(data > 20  & data < 41) = 40;
data(data > 40  & data < 61) = 60;
data(data > 60  & data < 81) = 80;
data(data > 80  & data < 101) = 100;


% Plot the data using surfacem() and axesm().
% axesm() EquaAzim Map Origin Argument -- North Pole
pole=[-90.0 0.0 0.0]; 

% floor(min(min(lat))) is not useful because undefined values extend to
% the opposite pole. Set it to 30.0.
latlim=[-90.0, 0.0];

% The following will return 12 keys used in the dataset.
z = unique(data);
num_levels = size(z);
k = double(num_levels(1));

% Create an array for tick label.
y = 1:1:k;

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


% Plot data.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');


% Here is the color map used by the MODIS group for the browse
% images.
% Use 12 entries for the values that z = unique(data) returns.
cmap = [
    [0.00 0.25 0.00];   % 0 -- snow-free land
    [0.00 0.00 1.00];   % 1-20% sea ice -- blue
    [0.00 0.25 1.00];   % 21-40% sea ice -- blue-cyan
    [0.00 0.50 1.00];   % 41-60% sea ice -- blue
    [0.00 0.75 1.00];   % 61-80% sea ice -- cyan-blue
    [0.00 1.00 1.00];   % 81-100% sea ice -- cyan
    [0.25 0.00 0.25];   % 101 -- permanent ice
    [1.00 1.00 1.00];   % 103 -- dry snow
    [0.10 0.10 0.10];   % 252 -- mixed pixels at coastlines
    [0.00 0.00 0.00];   % 253 -- suspect ice value
    [0.00 0.00 0.00];   % 254 -- corners (undefined)
    [0.00 0.00 0.50]];  % 255 -- ocean
colormap(cmap);

% Set the map parameters.
axesm('MapProjection', 'eqaazim', 'MapLatLimit', latlim, ...
      'Origin', pole, 'Frame', 'on', 'Grid', 'on', ...
      'MeridianLabel','on', 'ParallelLabel','on', 'MLabelParallel', 0);

% Load the global coastlines graphics.
coast = load('coast.mat');

% surfacem() is faster than contourfm(), but does not support
% discrete data level specification.
surfm(lat,lon,data);

caxis([1 m]);
h = colorbar('YTickLabel', ...
             {'snow-free land', '1-20% Sea Ice', ...
              '21-40% Sea Ice', '41-60% Sea Ice', '61-80% Sea Ice', ...
              '81-100% Sea Ice', 'permanent ice', 'dry snow', ...
              'mixed pixels at coastlines', 'suspect ice value', ...
              'corners (undefined)', 'ocean'}, 'YTick', y);

% Plot coastlines in black ('k').
plotm(coast.lat,coast.long,'k')

tightmap;

title({strrep(FILE_NAME,'_','\_');...
       strrep(long_name,'_','\_')}, ...
      'FontSize',16,'FontWeight','bold');
saveas(f, [FILE_NAME '.s.m.png']);
exit;
