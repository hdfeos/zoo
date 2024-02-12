%
%  This example code illustrates how to access and visualize SMAP L3 file
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
% $matlab -nosplash -nodesktop -r SMAP_L3_SM_P_20200915_R17000_001_h5_pm
%
% Tested under: MATLAB R2020a
% Last updated: 2021-04-22

clear

% Open the HDF5 File.
FILE_NAME = 'SMAP_L3_SM_P_20200915_R17000_001.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'Soil_Moisture_Retrieval_Data_PM/soil_moisture_pm';
data_id = H5D.open (file_id, DATAFIELD_NAME);

Lat_NAME='Soil_Moisture_Retrieval_Data_PM/latitude_pm';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='Soil_Moisture_Retrieval_Data_PM/longitude_pm';
lon_id=H5D.open(file_id, Lon_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the valid_max.
ATTRIBUTE = 'valid_max';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
valid_max = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the valid_min.
ATTRIBUTE = 'valid_min';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
valid_min = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read title attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name=H5A.read (attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Replace the invalid range values with NaN.
data(data < double(valid_min)) = NaN;
data(data > double(valid_max)) = NaN;

f=figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
         'Position', [0,0,800,600], ...
         'visible', 'off');

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south')

% Plot the data.
cm = colormap('Jet');
min_data=min(min(data));
max_data=max(max(data));
caxis([min_data max_data]);
k = size(data);
[count, n] = size(cm);
datap=data(~isnan(data));
latp=lat(~isnan(data));
lonp=lon(~isnan(data));
scatterm(latp, lonp, 1, datap);    
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k');
tightmap;

h = colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction.
units1 = sprintf('%s', char(units));

% lunits is pretty long so use a small font.
set (get(h, 'title'), 'string', units1, 'FontSize', 7, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');
  
name = sprintf('%s', long_name);

% long_name is also long so we use a small font.
title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 8,'FontWeight','bold');
saveas(f, [FILE_NAME '.pm.m.png']);
exit;




