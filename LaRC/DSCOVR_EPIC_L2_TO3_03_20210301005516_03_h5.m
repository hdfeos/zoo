% This example code illustrates how to access and visualize LaRC ASDC
% DSCOVR_EPIC L2 HDF5 Swath file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r DSCOVR_EPIC_L2_TO3_03_20210301005516_03_h5
%
% Tested under: MATLAB R2020a
% Last updated: 2021-03-19

import matlab.io.hdf5.*

% Open the HDF5 File.
FILE_NAME = 'DSCOVR_EPIC_L2_TO3_03_20210301005516_03.h5';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
LATFIELD_NAME='/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='/Longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

DATAFIELD_NAME='/Ozone';
data_id=H5D.open(file_id, DATAFIELD_NAME);


% Read the datasets.
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

fillvalue = -999.0;

% Close and release resources.
H5D.close (data_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);

% Handle fill value.
data(data==fillvalue) = NaN;
lat(lat > 90) = NaN;
lon(lon > 180) = NaN;

% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

% Put title.
var_name = 'Ozone';
tstring = {FILE_NAME; var_name};

% Title is long. Use a small font size.
title(tstring,...
      'Interpreter', 'none', 'FontSize', 10, ...
      'FontWeight','bold');

% Set the map parameters.
[xdimsize, ydimsize] = size(data);
lon_c = lon(xdimsize/2, ydimsize/2);
lat_c = lat(xdimsize/2, ydimsize/2);

axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'origin', [lat_c, lon_c]);
mlabel('equator')
plabel(0); 
plabel('fontweight','bold');

% Plot world map coast line.
scatterm(lat(:), lon(:), 1, data(:));
h = colorbar();
units_str = 'DU';
set (get(h, 'title'), 'string', units_str, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');


% Plot world map coast line.
coast = load('coast.mat');
plotm(coast.lat, coast.long, 'k');
tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;
