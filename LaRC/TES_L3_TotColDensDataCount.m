%This example code illustrates how to access and visualize TES L3 Grid file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS
%Forum (http://hdfeos.org/forums).

clear
%Open the HDF5 File
FILE_NAME = 'TES-Aura_L3-O3-M2008m03_F01_04.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

%Open the dataset
DATAFIELD_NAME = 'HDFEOS/GRIDS/NadirGrid/Data Fields/TotColDensDataCount';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME='HDFEOS/GRIDS/NadirGrid/Data Fields/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='HDFEOS/GRIDS/NadirGrid/Data Fields/Longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

% Get dataspace 
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the dataset.
data_1=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Release resources.
H5S.close (data_space)

% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fillvalue
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the missingvalue
ATTRIBUTE = 'MissingValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
missingvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;
%Replacing the missing value with NaN
data(data==missingvalue) = NaN;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name','TES-Aura_L3-O3-M2008m03_F01_04_TotColDensDataCount')

axesm('MapProjection','eqdcylin','MapLatLimit',latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');


contourfm(lat, lon, data);
colormap('Jet');
caxis([min(min(data)) max(max(data))]); 
colorbar('YTick', min(min(data)):20:max(max(data)));

plotm(coast.lat,coast.long,'k')

title(['TES-Aura\_L3-O3-M2008m03\_F01\_04\_TotColDensDataCount, units: ',units'],'FontSize',16,'FontWeight','bold');