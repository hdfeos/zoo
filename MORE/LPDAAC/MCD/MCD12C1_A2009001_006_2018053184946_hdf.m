%
% This example code illustrates how to access and visualize LP_DAAC
% MCD12C1 Grid file in MATLAB. 
%
% If you have any questions, suggestions, comments  on this
% example, please use the HDF-EOS Forum
% (http://hdfeos.org/forums). 
%
% If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r MCD12C1_A2009001_006_2018053184946_hdf
%                                   
% Tested under: MATLAB R2020a
% Last updated: 2021-10-19
import matlab.io.hdf4.*
import matlab.io.hdfeos.*
                                   
% Open the HDF-EOS2 grid file.
FILE_NAME='MCD12C1.A2009001.006.2018053184946.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Read data from a data field.
GRID_NAME='MOD12C1';
grid_id = gd.attach(file_id, GRID_NAME);

DATAFIELD_NAME='Land_Cover_Type_1_Percent';

% The following code throws an error on MATLAB 2021a.
[data3D, lat, lon] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Convert 3-D data to 2-D data
data=squeeze(data3D(2,:,:));
% size(data)


% Convert the data to double type for plot
data=double(data);


% Detach from the HDF-EOS2 Grid object.
gd.detach(grid_id);

% Close the file.
gd.close(file_id);

% Read attributes from the data field using HDF4 interface.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read fill value attribute from the data field.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);


% Read units attribute from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read layer information attribute from the data field.
layer_index = sd.findAttr(sds_id, 'Layer 1');
layer = sd.readAttr(sds_id, layer_index);

% Read long_name attribute from the data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);

% Terminate access to the data field.
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Replace the fill value with NaN.
data(data==double(fillvalue)) = NaN;


% Create the figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');


axesm('MapProjection', 'eqdcylin', 'Frame', 'on', 'Grid', 'on', ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south')

coast = load('coast.mat');
% For MATLAB 2021a, use the following:
% coast = load('coastlines.mat');


% The following is a good colormap for 0-100% value plot.
colormap(flipud(fliplr(pink(100))));
surfm(lat,lon,data);

plotm(coast.lat,coast.long,'k')
% For MATLAB 2021a, use the following:
% plotm(coast.coastlat,coast.coastlon,'k')

tightmap;

title({FILE_NAME; [long_name ' - ' layer]}, 'Interpreter', 'None', ...
      'FontSize', 8 ,'FontWeight', 'bold');

h = colorbar();
set (get(h, 'title'), 'string', units, 'FontSize', 6, 'FontWeight', ...
                   'bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
