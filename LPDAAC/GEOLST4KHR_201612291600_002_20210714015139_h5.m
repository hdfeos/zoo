%
%  This example code illustrates how to access and visualize an
% LPDAAC GEOLST4KHR L2 HDF5 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r GEOLST4KHR_201612291600_002_20210714015139_h5
%
% Tested under: MATLAB R2021a
% Last updated: 2022-01-13

clear

% Open the HDF5 File.
FILE_NAME = 'GEOLST4KHR_201612291600_002_20210714015139.h5';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'lst';
data_id = H5D.open(file_id, DATAFIELD_NAME);

Lat_NAME = 'lat';
lat_id = H5D.open(file_id, Lat_NAME);

Lon_NAME = 'lon';
lon_id = H5D.open(file_id, Lon_NAME);

% Read the dataset.
data = H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lat = H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon = H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue=H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');

% Read the units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');


% Read title attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
long_name=H5A.read(attr_id, 'H5ML_DEFAULT');

% Read scale_factor attribute.
ATTRIBUTE = 'scale_factor';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
scale = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read add_offset attribute.
ATTRIBUTE = 'add_offset';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
offset = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close(attr_id)
H5D.close(data_id);
H5F.close(file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Apply scale factor.
data = data*scale+offset;

lat(lat==-999.0) = NaN;
lon(lon==-999.0) = NaN;
f=figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
         'Position', [0,0,800,600], ...
         'visible', 'off');

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south')

% Plot the data.
cm = colormap('Jet');
surfm(lat,lon,data);
coast = load('coastlines.mat');
plotm(coast.coastlat,coast.coastlon,'k');
tightmap;

h = colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction.
units1 = sprintf('%s', char(units));

% lunits is pretty long so use a small font.
set(get(h, 'title'), 'string', units1, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');
  
name = sprintf('%s', long_name);

% long_name is also long so we use a small font.
title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
