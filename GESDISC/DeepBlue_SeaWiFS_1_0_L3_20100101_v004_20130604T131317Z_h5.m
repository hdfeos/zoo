%
%  This example code illustrates how to access and visualize GES DISC MEaSUREs
% SeaWiFS L3 Grid HDF5 file in MATLAB.
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2017a
% Last updated: 2018-01-18

clear

% Open the HDF5 File.
FILE_NAME = 'DeepBlue-SeaWiFS-1.0_L3_20100101_v004-20130604T131317Z.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = 'aerosol_optical_thickness_550_ocean';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME='latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

% Read the datasets.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read the attributes.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Set fill value from data using HDFView.
data(data == fillvalue) = NaN;

% Transpose data to match the map.
data = data';

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
         'Renderer', 'zbuffer', ...
         'Position', [0,0,800,600], ...         
         'visible', 'off');


% Set the map parameters.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','FontSize', 6)

% Load the global coastlines graphics
coast = load('coast.mat');

% Plot coastlines.
plotm(coast.lat,coast.long,'k')

% Plot data
surfm(lat, lon, data);
colormap('Jet');
h=colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);

% Draw unit.
set(get(h, 'title'), 'string', unit, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME;name};
title(tstring, 'Interpreter', 'none', 'FontSize', 12, 'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;