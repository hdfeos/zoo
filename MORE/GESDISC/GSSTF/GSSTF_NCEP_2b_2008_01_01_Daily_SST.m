%This example code illustrates how to access and visualize HDF-EOS5 MEaSUREs Grid file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS
%Forum (http://hdfeos.org/forums).

clear
%Open the HDF5 File
FILE_NAME = 'GSSTF_NCEP.2b.2008.01.01.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

%Open the dataset
DATAFIELD_NAME = '/HDFEOS/GRIDS/NCEP/Data Fields/SST';
data_id = H5D.open (file_id, DATAFIELD_NAME);

% Get dataspace 
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

%Transpose the data to match the map projection
data=data';

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

% Read the fillvalue
ATTRIBUTE = 'LongName';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
longname=H5A.read (attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Since the datafile doesn't provide lat and lon, we need to calculate lat and lon data
% using Geo projection.
offsetY = 0.5;
offsetX = 0.5;
scaleX = 360/data_dims(2);
scaleY = 180/data_dims(1);

for i = 0:(data_dims(2)-1)
  lon_value(i+1) = (i+offsetX)*(scaleX) + (-180);
end

for j = 0:(data_dims(1)-1)
  lat_value(j+1) = (j+offsetY)*(scaleY) - 90;
end

%Convert the data to double type for plot
lon=double(lon_value);
lat=double(lat_value);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;


%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name','GSSTF_NCEP.2b.2008.01.01.he5 Daily')

axesm('MapProjection','eqdcylin','MapLatLimit',latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');


contourfm(lat, lon, data);
colormap('Jet');
caxis([min(min(data)) max(max(data))]); 
colorbar('YTick', min(min(data)):20:max(max(data)));

plotm(coast.lat,coast.long,'k')

title(['GSSTF\_NCEP.2b.2008.01.01 Daily ',longname', '     units: ',units'],'FontSize',16,'FontWeight','bold');