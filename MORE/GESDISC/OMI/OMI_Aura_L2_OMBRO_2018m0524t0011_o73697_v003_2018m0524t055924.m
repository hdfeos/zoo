% 
%  This example code illustrates how to access and visualize OMI
%  OMBRO v3 Swath file in MATLAB. 
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
% Note: Maximum function name length is 63 so we drop .he5 from our code.
%
% $matlab -nosplash -nodesktop -r OMI_Aura_L2_OMBRO_2018m0524t0011_o73697_v003_2018m0524t055924
%
% Tested under: MATLAB R2017a
% Last updated: 2018-05-24

clear

% Open the HDF5 File.
FILE_NAME = ...
    'OMI-Aura_L2-OMBRO_2018m0524t0011-o73697_v003-2018m0524t055924.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = '/HDFEOS/SWATHS/OMI Total Column Amount BrO/Data Fields/ColumnAmount';
data_id = H5D.open (file_id, DATAFIELD_NAME);

Lat_NAME='HDFEOS/SWATHS/OMI Total Column Amount BrO/Geolocation Fields/Latitude';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='HDFEOS/SWATHS/OMI Total Column Amount BrO/Geolocation Fields/Longitude';
lon_id=H5D.open(file_id, Lon_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

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

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the missing value.
ATTRIBUTE = 'MissingValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
missingvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read title attribute.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name=H5A.read (attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;
% Replace the missing value with NaN.
data(data==missingvalue) = NaN;

% Apply scale and offset, the equation is scale *(data-offset).
data = scale*(data-offset);

% Plot the data.
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible', 'off');

latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

h = axesm('MapProjection','eqdcylin','MapLatLimit', ...
          latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
          'MeridianLabel','on','ParallelLabel','on', ...
          'MLabelParallel','south');
setm(h,'MapLatLimit',latlim,'MapLonLimit',lonlim);
setm(h,'Frame','on','Grid','on');
surfm(lat, lon, data);
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')
tightmap;
h = colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);
set(get(h, 'title'), 'string', unit, 'FontSize',8,'FontWeight', ...
                   'bold');

plotm(coast.lat,coast.long,'k');

title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize',12,'FontWeight','bold');


saveas(f, [FILE_NAME '.m.png']);
exit;


