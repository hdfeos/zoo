% This example code illustrates how to access and visualize NSIDC MODIS-T 4km
% LAMAZ (EASE) Grid file in Matlab.
% If you have any questions, suggestions, comments  on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums).
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Example HDF File source:
% ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/
%           MOD29E1D.A2009340.005.2009341094922.hdf
% Authoritative source:
% ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD29E1D.005/2009.12.06/
%       MOD29E1D.A2009340.005.2009341094922.hdf
% File Metadata:
%       MOD29E1D.A2009340.005.2009341094922.hdf.xml
% Browse images:
%       BROWSE.MOD29E1D.A2009340.005.2009341094922.[1-4].jpg

clear;
% Identify the HDF-EOS2 Grid File
FILE_NAME='MOD29E1D.A2009340.005.2009341094922.hdf'
% Opening the HDF-EOS2 Grid File
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Identify the HDF-EOS2 Data Grid
GRID_NAME='MOD_Grid_Seaice_4km_South'
% Attach to the HDF-EOS2 Data Grid
grid_id = hdfgd('attach', file_id, GRID_NAME);
% Identify the Data Field
DATAFIELD_NAME='Sea_Ice_by_Reflectance_SP'

%================================%
% Reading Data from a Data Field %
%================================%
[data_raw, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Get Grid Info
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id)

% Detach from the Grid Object
hdfgd('detach', grid_id);
% Close the HDF GD Interface to the File
hdfgd('close', file_id);

% The file contains LAMAZ projection. We need to use an external program
% to generate 1D lat and lon and then convert them to 2D lat and lon
% accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL
% http://hdfeos.org/zoo/note_non_geographic.php

% read YDim x XDim geolocation values from ASCII files into 1-dimensional arrays
lat1D= ...
load('lat_MOD29E1D.A2009340.005.2009341094922.MOD_Grid_Seaice_4km_South.output');
lon1D= ...
load('lon_MOD29E1D.A2009340.005.2009341094922.MOD_Grid_Seaice_4km_South.output');

% reshape lat and lon 1-D geolocation arrays to matrices matching the data grid
lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

% we are finished with the 1-D arrays and can clear them
clear lat1D lon1D;

% from HDFView MOD29E1D.A2009340.005.2009341094922.hdf we see the Key to
% the discrete levels ion the data field
%  Key = 0=missing data, 1=no decision, 11=night, 25=land, 37=inland water,
%       39=ocean, 50=cloud, 200=sea ice, 253=no input tile expected,
%      254=non-production mask; _FillValue = 255

% Plot the data using contourfm and axesm

% Thus, we make data linear.
data = double(data_raw);

% The following will return 8 keys used in the dataset.
z = unique(data_raw)
num_uniq = size(z)
for m = 1:num_uniq
    data(data_raw == z(m)) = double(m);
end

% create the graphics figure -- 'visible'->'off' = off-screen rendering
figure_handle=figure('Name', ...
'MOD29E1D.A2009340.005.2009341094922 4km Sea Ice by Reflectance SP', ...
'visible','on');
% if 'visible'->'on', figure_handle may be undefined

% set the map parameters
% axesm EquaAzim Map Origin Argument -- South Pole
pole=[-90 0 0];

% ceil(max(max(lat))) is not useful because undefined values extend to
% the opposite pole.
latlim=[-90,-30];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','eqaazim','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Origin',pole,'Frame','on','Grid','on','MeridianLabel','on', ...
   'ParallelLabel','on','MLabelParallel','south');
% load the global coastlines graphics from a '.mat' file
coast = load('coast.mat');

% Here is the color map used by the MODIS group for the Browse images
cmap=[[1.00 1.00 0.59];  ... %  11=night [255,255,150],
      [0.00 1.00 0.00];  ... %  25=land [000,255,000],
      [0.14 0.14 0.46];  ... %  37=inland water [035,035,117],
      [0.14 0.14 0.46];  ... %  39=ocean [035,035,117],
      [0.39 0.78 1.00];  ... %  50=cloud [100,200,255],
      [1.00 0.00 0.00];  ... % 200=sea ice [255,000,000],
      [0.00 0.00 0.00];  ... % 253=no input tile expected [000,000,000],
      [0.00 0.00 0.00]]; ... % 255=_FillValue [000,000,000]
% See: ftp://n4ftl01u.ecs.nasa.gov/SAN/MOST/MOD29E1D.005/

% load out colormap into Matlab's graphics system
colormap(cmap);

% Surfacem() is faster than Contourfm()
surfacem(lat,lon,data);

caxis([1 m]);
colorbar('YTickLabel', {'night', 'land', ...
                        'inland water', 'ocean', 'cloud', ...
                        'sea ice', 'no input tile expected', '_Fill'});

% draw the coastlines in color black ('k')
plotm(coast.lat,coast.long,'k')

title({ strrep(FILE_NAME,'_','\_');...
       strrep(DATAFIELD_NAME,'_','\_')}, ...
'FontSize',16,'FontWeight','bold');

% if off-screen rendering, make the figure the same size as the X display
scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
  set(figure_handle,'position',scrsz,'PaperPositionMode','auto');

  saveas(figure_handle, ...
  'MOD29E1D.A2009340.005.2009341094922_4km_SeaIce_Refl_SP_matlab.jpg');
end

