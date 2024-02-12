%
%  This example code illustrates how to access and visualize NSIDC
%  AMSR_E L3 V15 HDF-EOS2 grid file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r AMSR_E_L3_SeaIce12km_V15_20020603_hdf_n
%
% Tested under: MATLAB R2015a
% Last updated: 2016-03-04

import matlab.io.hdfeos.*

clear

% Open the HDF-EOS2 grid file.
FILE_NAME='AMSR_E_L3_SeaIce12km_V15_20020603.hdf';
file_id = gd.open(FILE_NAME);

% Read data from a grid.
GRID_NAME='NpPolarGrid12km';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME='SI_12km_NH_ICECON_DAY';
[data1, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME);

% Convert integer to double type for plot.
data=double(data1);

% Detach from the grid.
gd.detach(grid_id)

% Close the file.
gd.close(file_id);


% Replace invalid value:
% read this: http://nsidc.org/data/docs/daac/ae_si12_12km_seaice/data.html
data(data > 100) = NaN;

% Prepare figure.
f = figure('Name', FILE_NAME, 'visible', 'off');

% Set center and bounds for map. 
pole=[90 0 0];
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% Plot data on map.
axesm('MapProjection','stereo','MapLatLimit',latlim, ...
      'MapLonLimit',lonlim,  'Origin', pole,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
surfacem(lat,lon,data);
colormap('Jet');

% Set colorbar.
caxis([min_data max_data]); 
h=colorbar('YTick', min_data:20:max_data);

% Plot coastline.
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')

% Set title.
title({FILE_NAME; DATAFIELD_NAME}, 'Interpreter', 'None', ...
      'FontSize',16,'FontWeight','bold');

% Set colorbar's title.
set (get(h, 'title'), 'string', 'Percent', 'FontSize',12,'FontWeight','bold');

% Save figure in PNG.
saveas(f, [FILE_NAME '.n.m.png']);
exit;
