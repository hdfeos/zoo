%
%  This example code illustrates how to access and visualize an
%  LaRC CALIPSO L2 HDF5 file in MATLAB.
%
%  If you have any questions, suggestions, comments on this example, please
% use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run
%
%  $matlab -nosplash -nodesktop -r CAL_LID_L2_BlowingSnow_Antarctica_Standard_V2_00_2023_06_hdf5
%
% Tested under: MATLAB R2023b
% Last updated: 2024-02-15

% Open the HDF5 File.
FILE_NAME = 'CAL_LID_L2_BlowingSnow_Antarctica-Standard-V2-00.2023-06.hdf5';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'Snow_Fields/Blowing_Snow_Depol_Profile';
data_id = H5D.open(file_id, DATAFIELD_NAME);

LAT_NAME = 'Geolocation_Fields/Latitude';
lat_id = H5D.open(file_id, LAT_NAME);

LON_NAME = 'Geolocation_Fields/Longitude';
lon_id = H5D.open(file_id, LON_NAME);

% Read the dataset.
data = H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lat = H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon = H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');



% Read the units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

long_name = 'Blowing_Snow_Depol_Profile';

% Close and release resources.
H5A.close(attr_id)
H5D.close(data_id);
H5D.close(lat_id);
H5D.close(lon_id);
H5F.close(file_id);

% Replace the fill value with NaN.
% data(data==fillvalue) = NaN;

f = figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible', 'off');

% Set map limits.
latlim=[-90, ceil(max(max(lat)))];

% Create the plot.
pole=[-90 0 0];
axesm('MapProjection', 'stereo', 'MapLatLimit', latlim, ...
      'Origin', pole, 'Frame', 'on', 'Grid', 'on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', -60)

% Plot the data.
cm = colormap('Jet');
datas = data(1,:);
scatterm(lat(:), lon(:), 1, datas(:));
coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon, 'k');
tightmap;

h = colorbar();

units1 = sprintf('%s', char(units));
set(get(h, 'title'), 'string', units1, 'FontSize', 8, ...
                  'Interpreter', 'None', ...
                  'FontWeight','bold');
  
name = sprintf('%s', long_name);

title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 10, 'FontWeight', 'bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
