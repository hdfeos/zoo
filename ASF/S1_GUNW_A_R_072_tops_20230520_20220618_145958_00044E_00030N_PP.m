%  This example code illustrates how to access and visualize
% an ASF S1_GUNW L3 netCDF-4/HDF5 Grid file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r S1_GUNW_A_R_072_tops_20230520_20220618_145958_00044E_00030N_PP
%
% Tested under: MATLAB R2020a
% Last updated: 2023-07-07

% Open the netCDF-4 file.
FILE_NAME='S1-GUNW-A-R-072-tops-20230520_20220618-145958-00044E_00030N-PP-ab21-v2_0_6.nc';
% ncdisp(FILE_NAME)

% Read data from a data field.
DATAFIELD_NAME='/science/grids/data/amplitude';
data = ncread(FILE_NAME, DATAFIELD_NAME);

% Read units.
units = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'units');

% Read long_name.
long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, 'long_name');


% Read latitude data.
DATAFIELD_NAME='/science/grids/data/latitude';
lat = ncread(FILE_NAME, DATAFIELD_NAME);

% Read longitude data.
DATAFIELD_NAME='/science/grids/data/longitude';
lon = ncread(FILE_NAME, DATAFIELD_NAME);

% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible', 'off');
% data = data';
% Plot the data using axesm and surfm.
latlim=[min(min(lat)),max(max(lat))];
lonlim=[min(min(lon)),max(max(lon))];
mloc = ceil((lonlim(2) - lonlim(1))/10);
ploc = ceil((latlim(2) - latlim(1))/10);

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'MLineLocation', mloc, ...
      'PLineLocation', ploc, ...      
      'MLabelLocation', mloc, ...
      'PLabelLocation', ploc, ...
      'FontSize', 8)
surfm(lat(1:50:end), lon(1:50:end), data(1:50:end, 1:50:end));
colormap('Jet');
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k');

h = colorbar();
set (get(h, 'title'), 'string', units, 'Interpreter', 'None')
tightmap;

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME  '.m.png']);
exit;
