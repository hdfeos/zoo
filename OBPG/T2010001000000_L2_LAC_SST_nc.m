%
%  This example code illustrates how to access and visualize
%  OBPG TERRA MODIS netCDF-4 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r T2010001000000_L2_LAC_SST_nc
%
% Tested under: MATLAB R2019b
% Last updated: 2019-12-11

% Open the netCDF-4 file.
FILE_NAME='T2010001000000.L2_LAC_SST.nc';

% Read data from a data field.
DATAFIELD_NAME='geophysical_data/sst';
data = ncread(FILE_NAME, DATAFIELD_NAME);

% Read units.
units = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'units');

% Read long_name.
long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'long_name');

% Read scale_factor.
scale_factor = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'scale_factor');

% Read add_offset.
add_offset = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'add_offset');

% Read valid_min.
valid_min = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'valid_min');

% Read valid_max.
valid_max = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'valid_max');

% MATLAB netCDF API cannot handle valid_min/max attribute.
min_scaled = scale_factor * double(valid_min) + add_offset;
max_scaled = scale_factor * double(valid_max) + add_offset;

% Replace the invalid range values with NaN.
data(data < double(min_scaled)) = NaN;
data(data > double(max_scaled)) = NaN;

% Read latitude data.
DATAFIELD_NAME='navigation_data/latitude';
lat = ncread(FILE_NAME, DATAFIELD_NAME);

% Read longitude data.
DATAFIELD_NAME='navigation_data/longitude';
lon = ncread(FILE_NAME, DATAFIELD_NAME);

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% Plot the data using axesm and surfm.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize', 8)
surfm(lat,lon,data);
colormap('Jet');
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')

h = colorbar();
set (get(h, 'title'), 'string', units, 'Interpreter', 'None')
tightmap;

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME  '.m.png']);
exit;
