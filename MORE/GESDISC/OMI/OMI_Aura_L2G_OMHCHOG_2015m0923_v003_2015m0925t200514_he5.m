%
%  This example code illustrates how to access and visualize OMI Grid file
% in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r OMI_Aura_L2G_OMHCHOG_2015m0923_v003_2015m0925t200514_he5
%
% Tested under: MATLAB R2017a
% Last updated: 2017-10-04

clear
% Open the HDF5 File.
FILE_NAME = 'OMI-Aura_L2G-OMHCHOG_2015m0923_v003-2015m0925t200514.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = ...
'/HDFEOS/GRIDS/OMI Total Column Amount HCHO/Data Fields/AMFCloudPressure';
data_id = H5D.open (file_id, DATAFIELD_NAME);

Lat_NAME='/HDFEOS/GRIDS/OMI Total Column Amount HCHO/Data Fields/Latitude';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='/HDFEOS/GRIDS/OMI Total Column Amount HCHO/Data Fields/Longitude';
lon_id=H5D.open(file_id, Lon_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
    'H5P_DEFAULT');

lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
    'H5P_DEFAULT');

lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
    'H5P_DEFAULT');

% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the offset.
ATTRIBUTE = 'Offset';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
offset = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the scale.
ATTRIBUTE = 'ScaleFactor';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
scale = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fillvalue.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the missingvalue.
ATTRIBUTE = 'MissingValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
missingvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

attr_id = H5A.open_name (lat_id, ATTRIBUTE);
missingvalue_lat=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

attr_id = H5A.open_name (lon_id, ATTRIBUTE);
missingvalue_lon=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');


% Close and release resources.
H5A.close (attr_id)
H5D.close (lat_id);
H5D.close (lon_id);
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN
data(data==fillvalue) = NaN;
lat(lat==missingvalue) = NaN;
lon(lon==missingvalue) = NaN;

% Apply scale and offset, the equation is scale *(data-offset).
data = scale*(data-offset);

% Subset array.
nCandidate = 1;
data = data(:,:,nCandidate);
lat = lat(:,:,nCandidate);
lon = lon(:,:,nCandidate);

f = figure('Name', FILE_NAME, 'visible', 'off');

axesm('MapProjection','eqdcylin', 'Grid', 'on', 'MeridianLabel', ...
      'on','ParallelLabel','on', 'MLabelParallel','south');
coast = load('coast.mat');

surfacem(lat, lon, data);

colormap('Jet');
h = colorbar();

unit = sprintf('%s', units);
set(get(h, 'title'), 'string', unit, 'FontSize', 7);

plotm(coast.lat,coast.long,'k');
tightmap;

title({FILE_NAME; DATAFIELD_NAME; ' at nCandidate=0'}, ... 
      'Interpreter', 'None', 'FontSize', 7);
saveas(f, [FILE_NAME '.m.png']);
exit;
