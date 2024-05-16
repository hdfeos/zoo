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
%  $matlab -nosplash -nodesktop -r SWOT_L2_HR_PIXC_015_074_030L_20240510T224523_20240510T224528_nc
%
% Tested under: MATLAB R2023b
% Last updated: 2024-05-16

% Open the netCDF-4/HDF5 file.
FILE_NAME='SWOT_L2_HR_PIXC_015_074_030L_20240510T224523_20240510T224528_PIC0_01.nc';

% List file content.
% ncdisp(FILE_NAME)

ncid = netcdf.open(FILE_NAME, 'nowrite');

% Read data from a data field.
DATAFIELD_NAME='/pixel_cloud/water_frac';

data = ncread(FILE_NAME, DATAFIELD_NAME);

% Read units.
units = ncreadatt(FILE_NAME, DATAFIELD_NAME, "units");

% Read long_name.
long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, "long_name");

% Read latitude data.
DATAFIELD_NAME='/pixel_cloud/latitude';
lat = ncread(FILE_NAME, DATAFIELD_NAME);
lat = double(lat);
                 
% Read longitude data.
DATAFIELD_NAME='/pixel_cloud/longitude';
lon = ncread(FILE_NAME, DATAFIELD_NAME);
lon = double(lon);

% Close the file.
netcdf.close(ncid);

% Get min/max value of lat and lon for zoomed image.
latlim=[min(min(lat)),max(max(lat))];
lonlim=[min(min(lon)),max(max(lon))];

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');
axesm('eqdcylin', 'Frame', 'on', 'Grid', 'on', ...
      'MapLatLimit', latlim, 'MapLonLimit', lonlim, ...
      'MLineLocation', 0.5,  'PLineLocation', 0.1, ...
      'MLabelRound', -1,  'PLabelRound', -1, ...
      'MeridianLabel', 'on', 'ParallelLabel', 'on', ...
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
