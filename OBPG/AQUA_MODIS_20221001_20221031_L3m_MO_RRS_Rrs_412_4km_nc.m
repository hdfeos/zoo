%
%  This example code illustrates how to access and visualize
%  OBPG Aqua MODIS Grid netCDF-4 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r AQUA_MODIS_20221001_20221031_L3m_MO_RRS_Rrs_412_4km_nc
%
% Tested under: MATLAB R2023b
% Last updated: 2023-11-02

% Open the netCDF-4 file.
FILE_NAME = 'AQUA_MODIS.20221001_20221031.L3m.MO.RRS.Rrs_412.4km.nc';

% Read data from a data field.
DATAFIELD_NAME = 'Rrs_412';
data = ncread(FILE_NAME, DATAFIELD_NAME);

% Read units.
units = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'units');

% Read long_name.
long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'long_name');


% Read latitude data.
DATAFIELD_NAME='lat';
lat = ncread(FILE_NAME, DATAFIELD_NAME);

% Read longitude data.
DATAFIELD_NAME='lon';
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
surfm(lat,lon,data);
colormap('Jet');

coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k')

h = colorbar();
set (get(h, 'title'), 'string', units, 'Interpreter', 'None')
tightmap;

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME  '.m.png']);
exit;