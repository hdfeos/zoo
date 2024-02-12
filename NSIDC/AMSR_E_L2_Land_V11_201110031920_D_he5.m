%
%  This example code illustrates how to access and visualize an
%  NSIDC AMSR_E L2 version 11 HDF-EOS5 Point file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r AMSR_E_L2_Land_V11_201110031920_D_he5
% 
%
% Tested under: MATLAB R2020a
% Last updated: 2021-06-08

FILE_NAME = 'AMSR_E_L2_Land_V11_201110031920_D.he5';

% h5disp(fname)
dname = '/HDFEOS/POINTS/AMSR-E Level 2 Land Data/Data/Combined NPD and SCA Output Fields';
dset = h5read(FILE_NAME, dname);
data = dset.SoilMoistureSCA;
latitude = dset.Latitude;
lon = dset.Longitude;

% Handle fill value.
fillvalue = -9999.0;
data(data==fillvalue) = NaN;

% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

% Put title.
var_name = 'SoilMoistureSCA';
tstring = {FILE_NAME;var_name};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

% Plot world map coast line.
scatterm(latitude, lon, 1, data);
h = colorbar();

% Plot world map coast line.
coast = load('coast.mat');
plotm(coast.lat, coast.long, 'k');
tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;
