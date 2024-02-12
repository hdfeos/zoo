%
%   This example code illustrates how to access and visualize
%   TES L3 CH4 HDF-EOS5 Grid file in MATLAB.
%
%   If you have any questions, suggestions, comments  on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r TES_Aura_L3_CH4_r0000033028_C01_F01_12_he5
%
% Tested under: MATLAB R2021a
% Last updated: 2021-12-02

clear

% Open the HDF5 File.
FILE_NAME = 'TES-Aura_L3-CH4_r0000033028_C01_F01_12.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'HDFEOS/GRIDS/NadirGrid/Data Fields/SurfacePressure';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME='HDFEOS/GRIDS/NadirGrid/Data Fields/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='HDFEOS/GRIDS/NadirGrid/Data Fields/Longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

% Get dataspace.
% data_space = H5D.get_space (data_id);
% [data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
% data_dims=fliplr(data_dims');

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Release resources.
%H5S.close(data_space)

% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the title.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fillvalue
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

data = data';


% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on');
coast = load('coastlines.mat');
surfm(lat, lon, data);
plotm(coast.coastlat, coast.coastlon, 'k');

% Put colorbar.
colormap('Jet');
h = colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);
set(get(h, 'title'), 'string', unit, 'FontSize',16,'FontWeight', ...
                   'bold');

% Draw unit.
set(get(h, 'title'), 'string', unit, ...
                  'FontSize', 16, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME;name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');

saveas(f, [FILE_NAME '.m.png']);
exit;

