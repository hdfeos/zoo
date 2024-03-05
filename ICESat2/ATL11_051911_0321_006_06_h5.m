%
%  This example code illustrates how to access and visualize
%  NSIDC ICESat-2 ATL11 L3B HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
% 
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r ATL11_051911_0321_006_06_h5
% 
%
% Tested under: MATLAB R2023b
% Last updated: 2023-03-05

% Open the HDF5 File.
FILE_NAME = 'ATL11_051911_0321_006_06.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
LATFIELD_NAME='pt1/latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='pt1/longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

DATAFIELD_NAME='/pt1/h_corr';
data_id=H5D.open(file_id, DATAFIELD_NAME);


% Read the datasets.
latitude=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Subset Cycle 3.
data = data(1,:);

% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units_data = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name_data = H5A.read(attr_id, 'H5ML_DEFAULT');


% Read the fillvalue.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);

% Handle fill value.
data(data==fillvalue) = NaN;

% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

% Plot world map coast line.
scatterm(latitude, lon, 1, data);
h = colorbar();
units_str = sprintf('%s', char(units_data));
set (get(h, 'title'), 'string', units_str, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');

% Plot world map coast line.
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k');

% Put title.
var_name = sprintf('%s', long_name_data);
tstring = {FILE_NAME; var_name; ' at Cycle 3'};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;
