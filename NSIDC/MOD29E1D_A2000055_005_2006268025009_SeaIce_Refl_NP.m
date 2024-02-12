% This example code illustrates how to access and visualize NSIDC MODIS-T Grid
% file in Matlab.
% If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums).
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Example HDF File source:
% ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
%       MOD29E1D.A2000055.005.2006268025009.hdf
% Authoritative source:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD29E1D.005/2000.02.24/
%       MOD29E1D.A2000055.005.2006268025009.hdf
% Browse images:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD29E1D.005/2000.02.24/
%       BROWSE.MOD29E1D.A2000055.005.2006268025009.[1-4].jpg

clear;
% Open the HDF-EOS2 Grid File.
FILE_NAME='MOD29E1D.A2000055.005.2006268025009.hdf'
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read data from a data Field.
GRID_NAME='MOD_Grid_Seaice_4km_North'
grid_id = hdfgd('attach', file_id, GRID_NAME);
DATAFIELD_NAME='Sea_Ice_by_Reflectance_NP'

[data_raw, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% This file contains coordinate variables that will not properly plot.
% To properly display the data, the latitude/longitude must be remapped.

[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id)

% Detach from the Grid Object.
hdfgd('detach', grid_id);

%Close the File.
hdfgd('close', file_id);

% The file contains LAMAZ projection. We need to use an external program
% to generate 1D lat and lon and then convert them to 2D lat and lon
% accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL
% http://hdfeos.org/zoo/note_non_geographic.php

% Read YDim x XDim geolocation values into 1-dimensional arrays.
lat1D = ...
    load('lat_MOD29E1D.A2000055.005.2006268025009.MOD_Grid_Seaice_4km_North.output');
lon1D = ...
    load('lon_MOD29E1D.A2000055.005.2006268025009.MOD_Grid_Seaice_4km_North.output');

% Reshape lat and lon geolocation matrices to match data grid.
lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

% You can get the following Key information Using HDFView.
%  Key = 0=missing data, 1=no decision, 11=night, 25=land, 37=inland water,
%       39=ocean, 50=cloud, 200=sea ice, 253=no input tile expected,
%      254=non-production mask; _FillValue = 255


% Plot the data using surfacefm(contourfm) and axesm.

% surfacem() is faster than contourfm(), but does not support
% discrete data level specification.
% Thus, we make data linear.
data = double(data_raw)

% The following will return 10 keys used in the dataset.
z = unique(data_raw)
k = size(z);
for m = 1:k
    data(data_raw == z(m)) = double(m);
end

% Create the graphics figure -- 'visible'->'off' = off-screen rendering
figure_handle=figure('Name', ...
                     'MOD29E1D.A2000055.005.2006268025009 4km Sea Ice by Reflectance NP', ...
                     'visible','on');
% if 'visible'->'on', figure_handle is undefined.

% Set the map parameters.
% axesm EquaAzim Map Origin Argument -- North Pole
pole=[90 0 0]; 

% floor(min(min(lat))) is not useful because undefined values extend to
% the opposite pole.
latlim=[0.0,ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','eqaazim','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'Origin',pole,'Frame','on','Grid','on','MeridianLabel','on', ...
      'ParallelLabel','on','MLabelParallel','south');

% Load the global coastlines graphics.
coast = load('coast.mat');

% Here is the color map that matches the MODIS group for the browse image 
% closely.
%
% See: ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD29E1D.005/
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
colormap(cmap);
surfacem(lat,lon,data);
caxis([1 m]);
colorbar('YTickLabel', ...
         {'missing data', 'no decision', 'night', 'land', ...
          'inland water', 'ocean', 'cloud',  ...
          'sea ice', 'no input tile expected', 'fill value'});
plotm(coast.lat,coast.long,'k')


title({FILE_NAME;... 
       DATAFIELD_NAME}, ...
      'FontSize',16,'FontWeight','bold', 'Interpreter', 'none');

% For off-screen rendering, make the figure the same size as the X display.
scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
    set(figure_handle,'position',scrsz,'PaperPositionMode','auto');

    saveas(figure_handle, ...
           'MOD29E1D.A2000055.005.2006268025009_4km_SeaIce_Refl_NP_matlab.jpg');
end
