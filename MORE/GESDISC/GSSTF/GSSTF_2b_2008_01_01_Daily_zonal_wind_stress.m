%This example code illustrates how to access and visualize HDF-EOS5 MEaSUREs Grid file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS
%Forum (http://hdfeos.org/forums).

clear
%Open the HDF5 File
FILE_NAME = 'GSSTF.2b.2008.01.01.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

%Open the dataset
DATAFIELD1_NAME = '/HDFEOS/GRIDS/SET1/Data Fields/STu';
data1_id = H5D.open (file_id, DATAFIELD1_NAME);

DATAFIELD2_NAME = '/HDFEOS/GRIDS/SET2/Data Fields/STu';
data2_id = H5D.open (file_id, DATAFIELD2_NAME);

% Get dataspace 
data1_space = H5D.get_space (data1_id);
[data1_numdims data1_dims data1_maxdims]= H5S.get_simple_extent_dims (data1_space);
data1_dims=fliplr(data1_dims');

data2_space = H5D.get_space (data2_id);
[data2_numdims data2_dims data2_maxdims]= H5S.get_simple_extent_dims (data2_space);
data2_dims=fliplr(data2_dims');

% Read the dataset.
data1=H5D.read (data1_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
data2=H5D.read (data2_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

%Transpose the data to match the map projection
data1=data1';
data2=data2';

% Release resources.
H5S.close (data1_space)
H5S.close (data2_space)

% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data1_id, ATTRIBUTE);
units1 = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data2_id, ATTRIBUTE);
units2 = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fillvalue
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data1_id, ATTRIBUTE);
fillvalue1=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data2_id, ATTRIBUTE);
fillvalue2=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the fillvalue
ATTRIBUTE = 'LongName';
attr_id = H5A.open_name (data1_id, ATTRIBUTE);
longname1=H5A.read (attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'LongName';
attr_id = H5A.open_name (data2_id, ATTRIBUTE);
longname2=H5A.read (attr_id, 'H5ML_DEFAULT');


% Close and release resources.
H5A.close (attr_id)
H5D.close (data1_id);
H5D.close (data2_id);
H5F.close (file_id);


% Since the datafile doesn't provide lat and lon, we need to calculate lat and lon data
% using Geo projection.
offsetY = 0.5;
offsetX = 0.5;
scaleX = 360/data1_dims(2);
scaleY = 180/data1_dims(1);

for i = 0:(data1_dims(2)-1)
  lon1_value(i+1) = (i+offsetX)*(scaleX) + (-180);
end

for j = 0:(data1_dims(1)-1)
  lat1_value(j+1) = (j+offsetY)*(scaleY) - 90;
end

%Convert the data to double type for plot
lon1=double(lon1_value);
lat1=double(lat1_value);

%Replacing the filled value with NaN
data1(data1==fillvalue1) = NaN;


%Plot the data using contourfm and axesm
latlim1=[floor(min(min(lat1))),ceil(max(max(lat1)))];
lonlim1=[floor(min(min(lon1))),ceil(max(max(lon1)))];
min_data1=floor(min(min(data1)));
max_data1=ceil(max(max(data1)));

offsetY = 0.5;
offsetX = 0.5;
scaleX = 360/data2_dims(2);
scaleY = 180/data2_dims(1);

for i = 0:(data2_dims(2)-1)
  lon2_value(i+1) = (i+offsetX)*(scaleX) + (-180);
end

for j = 0:(data2_dims(1)-1)
  lat2_value(j+1) = (j+offsetY)*(scaleY) - 90;
end

%Convert the data to double type for plot
lon2=double(lon2_value);
lat2=double(lat2_value);

%Replacing the filled value with NaN
data2(data2==fillvalue2) = NaN;


%Plot the data using contourfm and axesm
latlim2=[floor(min(min(lat2))),ceil(max(max(lat2)))];
lonlim2=[floor(min(min(lon2))),ceil(max(max(lon2)))];
min_data2=floor(min(min(data2)));
max_data2=ceil(max(max(data2)));

figure('Name','GSSTF.2b.2008.01.01.Daily zonal wind stress')

subplot(2,1,1)
axesm('MapProjection','eqdcylin','MapLatLimit',latlim1,'MapLonLimit',lonlim1,'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');


contourfm(lat1, lon1, data1);
colormap('Jet');
caxis([min(min(data1)) max(max(data1))]); 
colorbar('YTick', min(min(data1)):20:max(max(data1)));

plotm(coast.lat,coast.long,'k')

title(['GSSTF.2b.2008.01.01 Daily SET1 ', longname1', '   units: ',units1'],'FontSize',16,'FontWeight','bold');

subplot(2,1,2)
axesm('MapProjection','eqdcylin','MapLatLimit',latlim2,'MapLonLimit',lonlim2,'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');


contourfm(lat2, lon2, data2);
colormap('Jet');
caxis([min(min(data2)) max(max(data2))]); 
colorbar('YTick', min(min(data2)):20:max(max(data2)));

plotm(coast.lat,coast.long,'k')

title(['GSSTF.2b.2008.01.01 Daily SET2 ', longname2', '   units: ',units2'],'FontSize',16,'FontWeight','bold');
