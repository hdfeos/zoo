%
%  This example code illustrates how to access and visualize
% a PO.DACC ECCO L4 netCDF-4/HDF5 Grid file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r ATM_SURFACE_TEMP_HUM_WIND_PRES_day_mean_ECCO_V4r4_nc
%
% Tested under: MATLAB R2020a
% Last updated: 2021-08-05

% Open the netCDF-4 file.
FILE_NAME='ATM_SURFACE_TEMP_HUM_WIND_PRES_day_mean_2017-12-31_ECCO_V4r4_latlon_0p50deg.nc';

% Read data from a data field.
DATAFIELD_NAME='EXFatemp';
data = ncread(FILE_NAME, DATAFIELD_NAME);

% Read units.
units = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'units');

% Read long_name.
long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'long_name');


% Read latitude data.
DATAFIELD_NAME='latitude';
lat = ncread(FILE_NAME, DATAFIELD_NAME);

% Read longitude data.
DATAFIELD_NAME='longitude';
lon = ncread(FILE_NAME, DATAFIELD_NAME);

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');
data = data';
% Plot the data using axesm and surfm.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize', 8)
surfm(double(lat),double(lon),data(:,:,1));
colormap('Jet');
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k');

h = colorbar();
set (get(h, 'title'), 'string', units, 'Interpreter', 'None')
tightmap;

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME  '.m.png']);
exit;
