%
%  This example code illustrates how to access and visualize
% PO.DAAC SWOT L2 netCDF-4 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r SWOT_GPR_2PfP009_584_20240124_232805_20240125_001932_nc
%
% Tested under: MATLAB R2023b
% Last updated: 2024-05-15

% Open the netCDF-4/HDF5 file.
FILE_NAME='SWOT_GPR_2PfP009_584_20240124_232805_20240125_001932.nc';

% List file content.
% ncdisp(FILE_NAME)

ncid = netcdf.open(FILE_NAME, 'nowrite');

% Read data from a data field.
DATAFIELD_NAME='/data_01/mean_dynamic_topography';

data = ncread(FILE_NAME, DATAFIELD_NAME);

% Read units.
units = ncreadatt(FILE_NAME, DATAFIELD_NAME, "units");

% Read long_name.
long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, "long_name");

% Read latitude data.
DATAFIELD_NAME='/data_01/latitude';
lat = ncread(FILE_NAME, DATAFIELD_NAME);
lat = double(lat);
                 
% Read longitude data.
DATAFIELD_NAME='/data_01/longitude';
lon = ncread(FILE_NAME, DATAFIELD_NAME);
lon = double(lon);

% Close the file.
netcdf.close(ncid);

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');
axesm ('eqdcylin', 'Frame', 'on', 'Grid', 'on', ...
      'MeridianLabel', 'on', 'ParallelLabel','on', ...
      'MLabelParallel', 'south')

scatterm(lat, lon, 1, data);
colormap('Jet');

coast = load('coastlines.mat');
plotm(coast.coastlat,coast.coastlon,'k')

% Change the value if you want to have more than 10 tick marks.
h = colorbar();
set (get(h, 'title'), 'string', units)
tightmap;

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');

saveas(f, [FILE_NAME  '.m.png']);
exit