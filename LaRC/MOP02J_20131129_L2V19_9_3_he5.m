%
%  This example code illustrates how to access and visualize MOPITT version 9
% HDF-EOS5 Swath file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS  Comprehensive Examples 
% page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum 
% (http://hdfeos.org/forums).

% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r MOP02J_20131129_L2V19_9_3_he5
%
% Tested under: MATLAB R2021a
% Last updated: 2021-11-09

clear
% Open the HDF-EOS5 file.
FILE_NAME = 'MOP02J-20131129-L2V19.9.3.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME='/HDFEOS/SWATHS/MOP02/Data Fields/RetrievedSurfaceTemperature';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME='/HDFEOS/SWATHS/MOP02/Geolocation Fields/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='/HDFEOS/SWATHS/MOP02/Geolocation Fields/Longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

% Get dataspace. 
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');


% Transpose the data to match the map projection.
data=data';

% Release resources.
H5S.close (data_space);

% Read the units attribute.
ATTRIBUTE = 'units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction.
units1 = sprintf('%s', char(units));


% Read the fill value attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue=H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id);
H5D.close (data_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Subset data.
datas=squeeze(data(:,1));
min_data=min(min(datas));
max_data=max(max(datas));

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');
axesm('MapProjection','eqdcylin', 'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south');

% Load the coastlines data file.
coast = load('coastlines.mat');

% Plot coastlines in color black ('k').
plotm(coast.coastlat,coast.coastlon,'k')

tightmap;

% Plot data.
lat = lat(:)';
lon = lon(:)';
data = datas(:)';

% Use every 5th point to save memory.
% scatterm(lat, lon, 1, data);
step = 5;
scatterm(lat(1:step:end), lon(1:step:end), 1, data(1:step:end));

% Put colormap.
colormap('Jet');
h=colorbar();
units_str = sprintf('%s', char(units));
set (get(h, 'title'), 'string', units_str);

% The dataset doesn't have long_name attribute.
long_name='RetrievedSurfaceTemperature';

% Set the title using long_name.
title({FILE_NAME;long_name}, 'Interpreter', 'none', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

