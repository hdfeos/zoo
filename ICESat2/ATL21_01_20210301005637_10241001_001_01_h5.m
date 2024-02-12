%
%  This example code illustrates how to access and visualize an
%  NSIDC ICESat-2 ATL21 L3B version 3 HDF5 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r ATL21_01_20210301005637_10241001_001_01_h5
% 
%
% Tested under: MATLAB R2020a
% Last updated: 2021-08-11

% Open the HDF5 File.
FILE_NAME = 'ATL21-01_20210301005637_10241001_001_01.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
LATFIELD_NAME='grid_lat';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='grid_lon';
lon_id=H5D.open(file_id, LONFIELD_NAME);

DATAFIELD_NAME='/monthly/mean_weighted_mss';
data_id=H5D.open(file_id, DATAFIELD_NAME);


% Read the datasets.
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units_data = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name_data = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue=H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');


% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Prepare figure.
f = figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], 'visible', 'off');
lon = lon - 180;
% Set center and bounds for map. 
pole=[90 0 0];
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% Plot data on map.
axesm('MapProjection','stereo','MapLatLimit',latlim, ...
      'Origin', pole, 'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
surfm(lat, lon, data);
colormap('Jet');

% Set colorbar.
h=colorbar();

% Plot coastline.
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')

% Set title.
title({FILE_NAME; DATAFIELD_NAME}, 'Interpreter', 'None', ...
      'FontSize',12,'FontWeight','bold');

units_str = sprintf('%s', char(units_data));
set (get(h, 'title'), 'string', units_str, 'FontSize', 12, 'FontWeight','bold');

% Save figure in PNG.
saveas(f, [FILE_NAME '.m.png']);
exit;
