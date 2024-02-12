% This example code illustrates how to access and visualize NSIDC NISE Grid
% file in MATLAB.

% If you have any questions, suggestions, comments on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums).
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at
% <mailto: eoshelp@hdfgroup.org> or post it at the HDF-EOS Forum
% (http://hdfeos.org/forums).

% Example HDF File source:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/OTHR/NISE.004/2011.04.24/
%       NISE_SSMISF17_20110424.HDFEOS
% File metadata:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/OTHR/NISE.004/2011.04.24/
%       NISE_SSMISF17_20110424.HDFEOS.xml
% Pre-rendered browse images:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/OTHR/NISE.004/2011.04.24/
%       NISE_SSMISF17_20110424.1.jpg and NISE_SSMISF17_20110424.2.jpg

clear;

% Open the HDF-EOS2 Grid file.
FILE_NAME='NISE_SSMISF17_20110424.HDFEOS';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='Northern Hemisphere';
grid_id = hdfgd('attach', file_id, GRID_NAME);
DATAFIELD_NAME='Extent';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Copy data.
data=data1;

% Convert the data to double type for plot.
data=double(data);

% Transpose the data to match the map projection.
data=data';

% This file contains coordinate variables that will not properly plot.
% To properly display the data, the latitude/longitude must be remapped.

[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the Grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% The file contains LAMAZ projection. We need to use an external program
% to generate 1D lat and lon and then convert them to 2D lat and lon
% accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL
% http://hdfeos.org/zoo/note_non_geographic.php

lat1D = load('lat_NISE_SSMISF17_20110424.Northern_Hemisphere.output');
lon1D = load('lon_NISE_SSMISF17_20110424.Northern_Hemisphere.output');

lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

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
pole=[90.0 0.0 0.0]; 

% floor(min(min(lat))) is not useful because undefined values extend to
% the opposite pole. Set it to 30.0.
latlim=[30.0, 90.0];

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

% Create the graphics figure -- 'visible'->'off' = off-screen
% rendering.
% If 'visible'->'on', figure_handle is undefined.
figure_handle=figure('Name', ...
                     'NISE_SSMISF17_20110424 Northern Hemisphere Extent', ...
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
      'MeridianLabel','on', 'ParallelLabel','on', 'MLabelParallel', 'south');

% Load the global coastlines graphics.
coast = load('coast.mat');

% surfacem() is faster than contourfm(), but does not support
% discrete data level specification.
surfacem(lat,lon,data);

caxis([1 m]);
colorbar('YTickLabel', ...
         {'snow-free land', '1-20% Sea Ice', ...
          '21-40% Sea Ice', '41-60% Sea Ice', '61-80% Sea Ice', ...
          '81-100% Sea Ice', 'permanent ice', 'dry snow', ...
          'mixed pixels at coastlines', 'suspect ice value', ...
          'corners (undefined)', 'ocean'}, 'YTick', y);

% Plot coastlines in black ('k').
plotm(coast.lat,coast.long,'k')

title({strrep(FILE_NAME,'_','\_');...
       strrep(DATAFIELD_NAME,'_','\_')}, ...
      'FontSize',16,'FontWeight','bold');

% If off-screen rendering is used, make the figure the same size as the X display.
scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
  set(figure_handle,'position',scrsz,'PaperPositionMode','auto');

  saveas(figure_handle, ...
  'NISE_SSMISF17_20110424_25km_SeaIce_Extent_NP_matlab.jpg');
end

