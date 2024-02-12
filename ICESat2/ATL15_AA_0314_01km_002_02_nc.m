%
%  This example code illustrates how to access and visualize NSIDC ICESat-2 
% ATL15 version 2 HDF5 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r ATL15_AA_0314_01km_002_02_nc
%
% Tested under: MATLAB R2023a
% Last updated: 2023-05-11

% Set the HDF5 File.
f = 'ATL15_AA_0314_01km_002_02.nc';

% Read the datasets.
ds = '/dhdt_lag1/dhdt';
data = h5read(f, ds);
data = squeeze(data(:,:,1));

% Read attributes.
fillvalue = h5readatt(f, ds, '_FillValue');
ln = h5readatt(f, ds, 'long_name');
units = h5readatt(f, ds, 'units');

% Process fill value.
data(data==fillvalue) = NaN;

x = h5read(f, '/dhdt_lag1/x');
y = h5read(f, '/dhdt_lag1/y');
t = h5read(f, '/dhdt_lag1/time');
units_t = h5readatt(f, '/dhdt_lag1/time', 'units');

% Transform location data.
proj = projcrs(3031);
[x_m, y_m] = meshgrid(y, x);
[lat, lon] = projinv(proj, x_m, y_m);

latlim = [floor(min(min(lat))), ceil(max(max(lat)))];

fig = figure('Name', f, 'Renderer', 'zbuffer', ...
             'Position', [0,0,800,600], 'visible', 'off');
pole=[-90 0 00];
axesm('MapProjection','stereo', ...
      'MapLatLimit', latlim, ...
      'Origin', pole ,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'north')
% Align data with map - add 90 and fliplr.
lon = lon + 90;
surfm(lat, lon, fliplr(data));
colormap('Jet');

h = colorbar();
coast = load('coastlines.mat');         
plotm(coast.coastlat,coast.coastlon, 'k');
title({f;ln;['on ', num2str(t(1)), ' ', units_t]}, 'Interpreter', 'None', ...
      'FontSize', 12,'FontWeight','bold');

set(get(h, 'title'), 'string', units, ...
                  'FontSize', 12, 'FontWeight', 'bold');
saveas(fig,[f '.m.png']);

exit;

