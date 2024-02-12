% This example code illustrates how to access and visualize NSIDC Level-2
% MODIS Swath data file in Matlab.

% If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums).
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo),
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% File Source:
% ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
%	MOD10_L2.A2000065.0040.005.2008235221207.hdf
% Authoritative source:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD10_L2.005/2000.03.05/
%	MOD10_L2.A2000065.0040.005.2008235221207.hdf
% Data description document:
% http://nsidc.org/data/docs/daac/
%	 mod10_l2_modis_terra_snow_cover_5min_swath.gd.html
% File Metadata:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD10_L2.005/2000.03.05/
%	MOD10_L2.A2000065.0040.005.2008235221207.hdf.xml

clear
% Identify the HDF-EOS2 Swath Data File
FILE_NAME='MOD10_L2.A2000065.0040.005.2008235221207.hdf';
% Identify the HDF-EOS2 Data Swath
SWATH_NAME='MOD_Swath_Snow';

% Open the HDF_SW interface to the HDF-EOS2 File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
% Attach to the swath via the HDF_SW interface
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Identify the Data Field
DATAFIELD_NAME='Snow_Cover';

% Read Data from the Data Field via the HDF_SW interface
[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
% Data type: 8-bit unsigned character, Dims: 4060 x 2708
[xdimsize, ydimsize] = size(data1);

% Detach from the Swath Object
hdfsw('detach', swath_id);
% close the HDF_SW interface to the file
hdfsw('close', file_id);

% File Geolocation Fields Latitude, Longitude are 406 x 271
% 1/10th the size of the data swath -- We create adjusted geolocation
% coordinates externally in the EOS2 Dumper and load them here
% See: http://www.hdfeos.org/software/eosdump.php
lat1D = ...
    load('lat_MOD10_L2.A2000065.0040.005.2008235221207.output');
lon1D = ...
    load('lon_MOD10_L2.A2000065.0040.005.2008235221207.output');

% Reshape 1-D lat and lon geolocation arrays to matrices
% of the same dimensions as the data swath
lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

% from the Data description document:
% http://nsidc.org/data/docs/daac/
%        mod10_l2_modis_terra_snow_cover_5min_swath.gd.html

% Parameter Range
%    Pixel values are as follows:
%	0: Missing
%	1: No decision
%	11: Night
%	25: Snow-free land
%	37: Lake or inland water
%	39: Open water (ocean)
%	50: Cloud obscured
%	100: Snow-covered lake ice
%	200: Snow
%	254: Detector saturated
%	255: Fill

% Plot the data using surfacefm(contourfm) and axesm.

% Make the data linear
data = double(data1);

% The following will return two key values (0,39) used in the dataset.
z = unique(data1);
k = size(z);
for m = 1:k
    data(data1 == z(m)) = double(m);
end

% Create the graphics figure -- 'visible'->'off' = off-screen rendering
figure_handle=figure('Name', ...
                     'MOD10_L2.A2000065.0040.005.2008235221207Snow Cover', ...
                     'visible','off');
% if 'visible'->'on', figure_handle may become undefined if the user
%			 closes the window

% Set the map parameters.
% axesm North Polar Stereographic
pole=[90 0 0];

% we can zoom the map view to the limits of the data's geographical region
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','stereo','MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
      'Origin',pole,'Frame','on','Grid','on', ...
     'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
% load the coastlines data file
coast = load('coast.mat');

% Here is the color map.
% Although there are only two (0,39) in the dataset,
% we define the rest to make the color bar look correct.
% MATLAB repeats labels 5 times if only two are specified.
% Please note that we use grey instead of white for missing data
% since background is white. We'd like to make the missing data
% stand out since most of the dataset is missing.
cmap=[[0.50 0.50 0.50];  ... %   0=missing data [255,255,255],
      [0.14 0.14 0.76]];  ... %  39=ocean [035,035,117],            
colormap(cmap);
surfacem(lat,lon,data);
caxis([1 m]);
% YTick property sets the location of tick label.
% Without it, MATLAB will repeat labels 5 times.
colorbar('YTickLabel', ...
         {'missing data', 'ocean'}, 'YTick', [1.25,1.75]);
plotm(coast.lat,coast.long,'k')

title({FILE_NAME;...
       DATAFIELD_NAME}, ...
      'FontSize',16,'FontWeight','bold', 'Interpreter', 'none');

% For off-screen rendering, make the figure the same size as the X display.
scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
    set(figure_handle,'position',scrsz,'PaperPositionMode','auto');

    saveas(figure_handle, ...
           'MOD10_L2.A2000065.0040.005.2008235221207_Snow_Cover_P_m.jpg');
end
