%
%   This example code illustrates how to access and visualize LaRC TES O3 
%  HDF-EOS5 Swath file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%   If you would like to see an example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r TES_Aura_L2_O3_Nadir_r0000002433_F08_12_he5
%
% Tested under: MATLAB R2021a
% Last updated: 2021-11-29

% Open the HDF-EOS5 file.
FILE_NAME='TES-Aura_L2-O3-Nadir_r0000002433_F08_12.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'HDFEOS/SWATHS/O3NadirSwath/Data Fields/O3';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME='HDFEOS/SWATHS/O3NadirSwath/Geolocation Fields/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='HDFEOS/SWATHS/O3NadirSwath/Geolocation Fields/Longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

% Get dataspace.
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the dataset.
data1=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the title.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5S.close (data_space)
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data1(data1==fillvalue) = NaN;


% Convert 2D data to 1D data.
nlevels = 6;
data=data1(nlevels,:)';

lat = double(lat);
lon = double(lon);
data = double(data);

% Get min/max value of lat and lon for zoomed image.
latlim=[min(min(lat)),max(max(lat))];
lonlim=[min(min(lon)),max(max(lon))];

% Compute data min/max for colorbar.
min_data=min(min(data));
max_data=max(max(data));

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');


% Create the plot.
axesm('MapProjection','eqdcylin', ...
        'MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
        'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south');

% Load the coastlines data file.
coast = load('coastlines.mat');

% Plot coastlines in color black ('k').
plotm(coast.coastlat,coast.coastlon,'k');

tightmap;



% Plot the dataset value along the flight path.
lat = lat(:)';
lon = lon(:)';
data = data(:)';

scatterm(lat, lon, 1, data);
cm = colormap('Jet');
caxis([min_data max_data]); 
h = colorbar();
units_str = sprintf('%s', char(units));
set (get(h, 'title'), 'string', units_str, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');
  
% Put title. 
% matlab is 1-based. We use 0-based index for nLevels dim. name for label. 
var_name = sprintf('%s at nLevels=%d', long_name, nlevels-1);
tstring = {FILE_NAME;var_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 12, ...
      'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
