%
% This example code illustrates how to access and visualize LP DAAC AST_08 
% HDF-EOS2 Swath file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r AST_08_00310162018232146_20181017215729_30106_hdf
%
% Tested under: MATLAB R2018b
% Last updated: 2019-01-23

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Open file.
FILE_NAME='AST_08_00310162018232146_20181017215729_30106.hdf';
file_id = sw.open(FILE_NAME, 'rdonly');

% Open swath.
SWATH_NAME='SurfaceKineticTemperature';
swath_id = sw.attach(file_id, SWATH_NAME);

% Read the dataset.
DATAFIELD_NAME='KineticTemperature';
data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);

% Detach Swath object.
sw.detach(swath_id);

% Close file.
sw.close(file_id);



% Read lat/lon info from the outputs of eo2dump file.
lat1D = ...
    load('lat_AST_08_00310162018232146_20181017215729_30106.output');

lon1D = ...
    load('lon_AST_08_00310162018232146_20181017215729_30106.output');
[xdimsize, ydimsize] = size(data);
lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);
                                
% Apply scale [1].                                
data=data * 0.1;
                                
% Set the map parameters. 
lon_c = lon(xdimsize/2, ydimsize/2);
lat_c = lat(xdimsize/2, ydimsize/2);
latlim=(ceil(max(max(lat))) - floor(min(min(lat))))/2;

% Create the graphics figure -- 'visible'->'off' = off-screen rendering
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% See [2] for map properties.
axesm('ortho', 'Frame', 'on', 'Grid', 'on', ...
      'FLatLimit', [-Inf, latlim], ...
      'ParallelLabel', 'on', 'PLabelMeridian', lon_c, ...
      'MeridianLabel', 'on', 'MLabelParallel', lat_c, ...
      'MLineLocation', 0.5, 'PLineLocation', 0.5, ...
      'MLabelLocation', 0.5, 'PLabelLocation', 0.5, ...
      'LabelUnits', 'dm', ...
      'origin', [lat_c, lon_c]);

% Plot data. 
lat = lat(:)';
lon = lon(:)';
data = data(:)';

% Use every 5th point to save memory.
% scatterm(lat, lon, 1, data);
step = 5;
scatterm(lat(1:step:end), lon(1:step:end), 1, data(1:step:end));

% Load the coastlines data file.
load coastlines;

% Plot coastlines.
plotm(coastlat,coastlon);

% Put color bar.
colormap('Jet');
h=colorbar();
units = 'K';
set (get(h, 'title'), 'string', units);
                                
title({FILE_NAME; DATAFIELD_NAME}, 'Interpreter', 'none', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

% References
%                                
% [1] https://asterweb.jpl.nasa.gov/content/03_data/01_Data_Products/release_surface_kinetic_temperatur.htm
% [2] https://www.mathworks.com/help/map/ref/mapaxes-properties.html