%
%  This example code illustrates how to access and visualize GPM L3 file
% in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r GPM_3GPROFGPMGMI
%
% Tested under: MATLAB R2023b
% Last updated: 2024-07-29

% Open the HDF5 File.
FILE_NAME = '3A-MO.GPM.GMI.GRID2021R1.20140701-S000000-E235959.07.V07A.HDF5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'Grid/cloudWater';
data_id = H5D.open(file_id, DATAFIELD_NAME);


% Read the dataset.
data = H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Read lat/lon.
lon_id = H5D.open(file_id, 'Grid/lon');
lon = H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lat_id = H5D.open(file_id, 'Grid/lat');
lat = H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');


% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Subset data.
dataf = data(:,:,1);

% Plot the data using surfm and axesm.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible', 'off');


axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south');
surfm(lat, lon, dataf);

coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k')
tightmap;

colormap('Jet');
h = colorbar();

unit = sprintf('%s', units);
set(get(h, 'title'), 'string', unit, 'FontSize', 8,'FontWeight', ...
                  'bold');

name = sprintf('%s', DATAFIELD_NAME);
title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 8,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


