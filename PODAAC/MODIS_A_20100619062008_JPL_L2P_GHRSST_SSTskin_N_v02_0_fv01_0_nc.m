%
%  This example code illustrates how to access and visualize
%  PO.DAAC MODIS L2 HDF5 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r MODIS_A_20100619062008_JPL_L2P_GHRSST_SSTskin_N_v02_0_fv01_0_nc
% 
%
% Tested under: MATLAB R2021a
% Last updated: 2022-05-26

% Open the HDF5 File.
FILE_NAME = '20100619062008-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
LATFIELD_NAME='/lat';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='/lon';
lon_id=H5D.open(file_id, LONFIELD_NAME);

DATAFIELD_NAME='/sea_surface_temperature';
data_id=H5D.open(file_id, DATAFIELD_NAME);


% Read the datasets.
latitude=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units_data = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
long_name_data = H5A.read(attr_id, 'H5ML_DEFAULT');
% Read the fillvalue.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue = H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');

% Read the scale factor.
ATTRIBUTE = 'scale_factor';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
scale_factor = H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');

% Read the add_offset.
ATTRIBUTE = 'add_offset';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
add_offset = H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');
				
% Close and release resources.
H5A.close(attr_id);
H5D.close(data_id);
H5D.close(lon_id);
H5D.close(lat_id);
H5F.close(file_id);

% Handle fill value.
data(data==fillvalue) = NaN;

% Handle scale factor and offset.
data = scale_factor * data + add_offset;
				
% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

% Put title.
tstring = {FILE_NAME; long_name_data{1}};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

% Plot data.
scatterm(latitude(:), lon(:), 1, data(:));
h = colorbar();
set(get(h, 'title'), 'string', units_data, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');

% Plot world map coast line.
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k');
tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;

