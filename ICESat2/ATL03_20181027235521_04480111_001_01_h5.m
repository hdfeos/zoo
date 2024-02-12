%
%  This example code illustrates how to access and visualize
%  ICESat-2 ATL03 HDF5 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r ATL03_20181027235521_04480111_001_01_h5
%
% Tested under: MATLAB R2018a
% Last updated: 2019-06-06

% Open the HDF5 File.
FILE_NAME = 'ATL03_20181027235521_04480111_001_01.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
LATFIELD_NAME='gt1l/geolocation/reference_photon_lat';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='gt1l/geolocation/reference_photon_lon';
lon_id=H5D.open(file_id, LONFIELD_NAME);

DATAFIELD_NAME='gt1l/geolocation/tx_pulse_energy';
temp_id=H5D.open(file_id, DATAFIELD_NAME);


% Read the datasets.
latitude=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
temp=H5D.read(temp_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (temp_id, ATTRIBUTE);
units_temp = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (temp_id, ATTRIBUTE);
long_name_temp = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (temp_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);


% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

% Put title.
var_name = sprintf('%s', long_name_temp);
tstring = {FILE_NAME;var_name};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

% Plot world map coast line.
scatterm(latitude, lon, 1, temp);
h = colorbar();
units_str = sprintf('%s', char(units_temp));
set (get(h, 'title'), 'string', units_str, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');

% Plot world map coast line.
coast = load('coast.mat');
plotm(coast.lat, coast.long, 'k');
tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;

