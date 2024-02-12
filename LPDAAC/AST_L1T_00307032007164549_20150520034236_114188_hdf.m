%
% This example code illustrates how to access and visualize LP DAAC AST_L1T v3
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
% $matlab -nosplash -nodesktop -r AST_L1T_00307032007164549_20150520034236_114188_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-03-15

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Open file.
FILE_NAME='AST_L1T_00307032007164549_20150520034236_114188.hdf';
file_id = sw.open(FILE_NAME, 'rdonly');

% Open swath.
SWATH_NAME='SWIR_Swath';
swath_id = sw.attach(file_id, SWATH_NAME);

% Read the dataset.
DATAFIELD_NAME='ImageData4';
data = sw.readField(swath_id, DATAFIELD_NAME, [], [], []);

% Detach Swath object.
sw.detach(swath_id);

% Close file.
sw.close(file_id);



% Read lat/lon info from the outputs of eo2dump file.
lat1D = ...
    load('lat_AST_L1T_00307032007164549_20150520034236_114188.output');

lon1D = ...
    load('lon_AST_L1T_00307032007164549_20150520034236_114188.output');
[xdimsize, ydimsize] = size(data);
lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Set the map parameters. 
% xdimsize = 2839 is an odd number. Add 1.
lon_c = lon((xdimsize+1)/2, ydimsize/2);
lat_c = lat((xdimsize+1)/2, ydimsize/2);
latlim=(ceil(max(max(lat))) - floor(min(min(lat))))/2;

% create the graphics figure -- 'visible'->'off' = off-screen rendering
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'FLatLimit', [-Inf, latlim], ...
       'ParallelLabel', 'on', 'PLabelMeridian', lon_c, ...
       'MeridianLabel', 'on', 'MLabelParallel', lat_c, ...
       'origin', [lat_c, lon_c]);
gridm('mlinelocation',1,'plinelocation',1)
setm(gca,'MLabelLocation', 1)
setm(gca,'PLabelLocation', 1)
mlabel('on');
mlabel('fontweight','bold');
plabel('on'); 
plabel('fontweight','bold');

% Plot data. 
lat = lat(:)';
lon = lon(:)';
data = data(:)';

% Use every 5th point to save memory.
% scatterm(lat, lon, 1, data);
step = 5;
scatterm(lat(1:step:end), lon(1:step:end), 1, data(1:step:end));


% Load the coastlines data file.
coast = load('coast.mat');

% Plot coastlines in color black ('k').
plotm(coast.lat,coast.long,'k');


% Put colormap.
colormap('Jet');
h=colorbar();


title({FILE_NAME; DATAFIELD_NAME}, 'Interpreter', 'none', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

