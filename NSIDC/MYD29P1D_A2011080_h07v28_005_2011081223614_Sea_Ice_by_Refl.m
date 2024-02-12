% This example code illustrates how to access and visualize NSIDC MYD29
% MODIS-AQUA 1km LAMAZ Grid file in MATLAB.
%
% If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums).
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Example HDF File source:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/MOSA/MYD29P1D.005/2011.03.21/
%       MYD29P1D.A2011080.h07v28.005.2011081223614.hdf
% File metadata:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/MOSA/MYD29P1D.005/2011.03.21/
%       MYD29P1D.A2011080.h07v28.005.2011081223614.hdf.xml

clear;

% Identify the HDF-EOS2 Grid File.
FILE_NAME='MYD29P1D.A2011080.h07v28.005.2011081223614.hdf';

% Open the HDF-EOS2 Grid File via the hdfgd() interface.
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Identify the data Grid.
GRID_NAME='MOD_Grid_Seaice_1km';

% Attach to the data Grid.
grid_id = hdfgd('attach', file_id, GRID_NAME);

% Identify the data field.
DATAFIELD_NAME='Sea_Ice_by_Reflectance';


% Read from the data field.
[data_raw, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% the the Grid Info from the hdfgd() Interface
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detach from the Grid Object
hdfgd('detach', grid_id);

% Close the hdfgd() Interface to the file.
hdfgd('close', file_id);

% The file contains LAMAZ projection. We need to use an external program
% to generate 1D lat and lon and then convert them to 2D lat and lon
% accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL
% http://hdfeos.org/zoo/note_non_geographic.php

% Read YDim x XDim geolocation values into 1-dimensional arrays.
lat1D= ...
load('lat_MYD29P1D.A2011080.h07v28.005.2011081223614.MOD_Grid_Seaice_1km.output');
lon1D= ...
load('lon_MYD29P1D.A2011080.h07v28.005.2011081223614.MOD_Grid_Seaice_1km.output');

% Reshape lat and lon geolocation matrices to match data grid.
lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

% from HDFView MYD29P1D.A2010133.h09v07.005.2010135182659.hdf
% Key = 0=missing data, 1=no decision, 11=night, 25=land, 37=inland water,
%      39=ocean, 50=cloud, 200=sea ice, 253=land mask, 254=ocean mask,
%     255=fill

% Plot the data using surfacem and axesm.

data = double(data_raw);

% The following will return 4 keys used in the dataset.
z = unique(data_raw);
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
    data(data_raw == z(m)) = double(m);
    x = x + (k-1)/k;        
end

% Create the graphics figure -- 'visible'->'off' = off-screen
% rendering. If 'visible'->'on', figure_handle may be undefined.
figure_handle=figure('Name', ...
'MYD29P1D.A2011080.h07v28.005.2011081223614 1km Sea Ice by Reflectance', ...
'visible','off');

% Set the map parameters
% We know that EASE Grid tile h07v28 lies in the Southern Hemisphere
% http://landdb1.nascom.nasa.gov/developers/la_tiles/la_grid.html
% axesm EquaAzim Map Origin Argument -- South Pole
pole=[-90 0 0];

latlim=[-90.0,ceil(max(max(lat)))];

axesm('MapProjection','eqaazim','MapLatLimit',latlim,...
      'Origin',pole,'Frame','on','Grid','on','MeridianLabel','on', ...
      'ParallelLabel','on','MLabelParallel','north');

% Load the global coastlines graphics from the '.mat' file
coast = load('coast.mat');

% Here is the color map used by the MODIS group for the Browse
% images.
% See: ftp://n4ftl01u.ecs.nasa.gov/SAN/MOSA/MYD29P1D.005/
cmap=[[0.00 1.00 0.00];  ... %  25=land [000,255,000],
      [0.14 0.14 0.46];  ... %  39=ocean [035,035,117],
      [0.39 0.78 1.00];  ... %  50=cloud [100,200,255],
      [1.00 0.00 0.00]];     % 200=sea ice [255,000,000],

% Load this colormap into the Matlab graphics system.
colormap(cmap);

surfacem(lat,lon,data);

caxis([1 m]);
colorbar('YTickLabel', {'land', 'ocean', 'cloud', 'sea ice'}, 'YTick', ...
         y);

% Draw the coastlines in black ('k').
plotm(coast.lat,coast.long,'k')

title({strrep(FILE_NAME,'_','\_');...
       strrep(DATAFIELD_NAME,'_','\_')}, ...
'FontSize',16,'FontWeight','bold');

% If off-screen rendering is used, make the figure the same size as
% the X display.
scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
  set(figure_handle,'position',scrsz,'PaperPositionMode','auto');

  saveas(figure_handle, ...
  'MYD29P1D.A2011080.h07v28.005.2011081223614_1km_SeaIce_Refl_matlab.jpg');
end

% See also:
% MODLAND Developers Home Page
%     http://landdb1.nascom.nasa.gov/developers/index.html
%     http://landdb1.nascom.nasa.gov/developers/grids.html
%     http://landdb1.nascom.nasa.gov/developers/la_tiles/la_grid.html

