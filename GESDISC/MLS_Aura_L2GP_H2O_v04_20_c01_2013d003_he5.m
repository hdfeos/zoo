%
%   This example code illustrates how to access and visualize GES DISC MLS
% Swath HDF-EOS5 file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r MLS_Aura_L2GP_H2O_v04_20_c01_2013d003_he5
%
% Tested under: MATLAB R2020a
% Last updated: 2020-11-09

% Open the HDF5 file.
FILE_NAME='MLS-Aura_L2GP-H2O_v04-20-c01_2013d003.he5';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'HDFEOS/SWATHS/H2O/Data Fields/L2gpValue';
data_id = H5D.open(file_id, DATAFIELD_NAME);

LATFIELD_NAME='HDFEOS/SWATHS/H2O/Geolocation Fields/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='HDFEOS/SWATHS/H2O/Geolocation Fields/Longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

PRSFIELD_NAME='HDFEOS/SWATHS/H2O/Geolocation Fields/Pressure';
prs_id=H5D.open(file_id, PRSFIELD_NAME);

% Get dataspace.
% data_space = H5D.get_space(data_id);
% [data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims(data_space);
% data_dims=fliplr(data_dims');

% Read the dataset.
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
prs=H5D.read(prs_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the title.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the units of Pressure dataset.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (prs_id, ATTRIBUTE);
units_prs = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
% H5S.close(data_space)
H5A.close(attr_id)
H5D.close(data_id);
H5F.close(file_id);


lat = double(lat);
lon = double(lon);
data = double(data);
% Convert 2-D data to 1-D data.
data=squeeze(data(1,:));

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
         'Renderer', 'zbuffer', ...
         'Position', [0,0,800,600], ...                  
         'visible', 'off');

% Create the plot.
axesm('MapProjection','eqdcylin', ...
        'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel', 'south')


% Plot the dataset value along the flight path.
cm = colormap('Jet');
lat = lat(:)';
lon = lon(:)';
data = data(:)';
scatterm(lat, lon, 1, data);
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k');
tightmap;
h = colorbar();
units_str = sprintf('%s', char(units));
units_prs_str = sprintf('%s', char(units_prs));

% Unit string is quite long. Use ylabel to avoid clutter at the top
% of colorbar.
ylabel(h, units_str)
  
% Put title. 
var_name = sprintf('%s', char(long_name));
tstring = {FILE_NAME; [var_name ' at Pressure = ' num2str(prs(1)) ' ' units_prs_str]};
title(tstring, 'Interpreter', 'none', 'FontSize', 12, ...
      'FontWeight','bold');

saveas(f, [FILE_NAME '.m.png']);
exit;
