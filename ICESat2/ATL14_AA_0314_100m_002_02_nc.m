%
%  This example code illustrates how to access and visualize NSIDC ICESat-2 
% ATL14 version 2 HDF5 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r ATL14_AA_0314_100m_002_02_nc
%
% Tested under: MATLAB R2023a
% Last updated: 2023-05-19
%
% Credit: Jonathan Gale
clear


% Set the HDF5 File.
f = 'ATL14_AA_0314_100m_002_02.nc';

% Read the datasets.
ds = '/h';

% Subset the datasets since dataset is too big.
% Dataset is reduced to lat:447 * lon:547.
start = [1 1];
count = [547 447];
stride = [100 100];
data = h5read(f, ds, start, count, stride);

% Read attributes.
fillvalue = h5readatt(f, '/h', '_FillValue');
ln = h5readatt(f, '/h', 'long_name');
units = h5readatt(f, '/h', 'units');

% Process fill value.
data = standardizeMissing(data, fillvalue);

x = h5read(f, '/x', 1, 547, 100);
y = h5read(f, '/y', 1, 447, 100);

% Transform location data.
proj = projcrs(3031);
[x_m, y_m] = ndgrid(x, y);
[lat, lon] = projinv(proj, x_m, y_m);

% Use map projection parameters to define latitude limits by picking the
% limits that center on the standard parallel.
latlim = [-90, -(-90 - proj.ProjectionParameters.LatitudeOfStandardParallel * 2)];

fig = figure('Name', f, 'Position', [0,0,800,600], 'Visible', 'off');
axesm('MapProjection', 'stereo', 'Geoid', proj.GeographicCRS.Spheroid, ...
      'MapLatLimit', latlim, 'Frame', 'on', 'FLineWidth', 0.5, ...
      'Grid', 'on', 'MeridianLabel', 'on', 'ParallelLabel', 'on')

geoshow(lat, lon, zeros(size(data)), 'DisplayType', 'surface', 'CData', data)
colormap('turbo')
cbar = colorbar;
load('coastlines.mat')
plotm(coastlat, coastlon, 'k')

title(f, 'Interpreter', 'none', 'FontWeight', 'bold')
subtitle(ln, 'FontWeight', 'bold')
title(cbar, units, 'FontWeight', 'bold')

saveas(fig,[f '.m.png'])

exit;
