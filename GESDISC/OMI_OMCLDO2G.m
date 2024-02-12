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

clear
% Open the HDF5 File.
FILE_NAME = 'OMI-Aura_L2G-OMCLDO2G_2007m0129_v002-2007m0130t174603.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = ...
'/HDFEOS/GRIDS/CloudFractionAndPressure/Data Fields/CloudPressure';
data_id = H5D.open (file_id, DATAFIELD_NAME);

Lat_NAME='/HDFEOS/GRIDS/CloudFractionAndPressure/Data Fields/Latitude';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='/HDFEOS/GRIDS/CloudFractionAndPressure/Data Fields/Longitude';
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

%Plot the data using surfacem and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f = figure('Name', FILE_NAME);

axesm('MapProjection','eqdcylin','MapLatLimit', ... 
      latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

surfacem(lat, lon, data);

colormap('Jet');

caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min(min(data)):granule:max(max(data)));

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in veritcal manner.
unit = sprintf('%s', units);
set(get(h, 'title'), 'string', unit, 'FontSize',16,'FontWeight', ...
                   'bold');

plotm(coast.lat,coast.long,'k');


title({FILE_NAME; [DATAFIELD_NAME ' at nCandidate=0']}, ... 
      'Interpreter', 'None', 'FontSize',16,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f, [FILE_NAME '.CloudPressure.m.jpg']);
