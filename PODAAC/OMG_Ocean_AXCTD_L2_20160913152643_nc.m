%
%  This example code illustrates how to access and visualize
% PO.DAAC OMG AXCTD L2 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% You can run this script in batch mode as follows:
%
% $matlab -nosplash -nodesktop -r OMG_Ocean_AXCTD_L2_20160913152643_nc
%
% Please note that there is no .m in the above command at the end.
%
% Last Update: September 18, 2019

% Open the HDF5 File.
FILE_NAME = 'OMG_Ocean_AXCTD_L2_20160913152643.nc';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the temperature dataset.
DATAFIELD_NAME = 'temperature';
data_id = H5D.open(file_id, DATAFIELD_NAME);

% Read the dataset.
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');

% Read the units of data.
ATTRIBUTE = 'units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');
H5A.close(attr_id)

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue=H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');
H5A.close(attr_id)

% Read the long_name attribute value.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');
H5A.close(attr_id)

H5D.close(data_id);

% Open the depth dataset.
DEPTH_NAME = 'depth';
depth_id = H5D.open(file_id, DEPTH_NAME);
depth = H5D.read(depth_id, 'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                 'H5P_DEFAULT');

% Read the units of depth.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (depth_id, ATTRIBUTE);
units_depth = H5A.read(attr_id, 'H5ML_DEFAULT');
H5A.close(attr_id);

% Read the long_name attribute value.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (depth_id, ATTRIBUTE);
long_name_depth = H5A.read(attr_id, 'H5ML_DEFAULT');
H5A.close(attr_id);
H5D.close(depth_id);


% Open the latitude dataset.
lat_id = H5D.open(file_id, 'lat');
lat = H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');
H5D.close(lat_id);

% Open the longitude dataset.
lon_id = H5D.open(file_id, 'lon');
lon = H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
               'H5P_DEFAULT');
H5D.close(lon_id);

H5F.close(file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;


f = figure('Name', FILE_NAME, 'visible', 'off');
yunit = sprintf('%s', units_depth);
xunit = sprintf('%s', units);
name = sprintf('%s', long_name);
name_d = sprintf('%s', long_name_depth);

plot(data(:,1), depth(:,1));
ylabel([name_d ' (' yunit ')']);
xlabel([name ' (' xunit ')'], 'Interpreter', 'None');

ax = gca;
ax.YDir = 'reverse';

lat_s = sprintf('%f', lat(1,1));
lon_s = sprintf('%f', lon(1,1));
title({FILE_NAME; ['Location: lat=' lat_s ' lon=' lon_s]}, ... 
      'Interpreter', 'None', 'FontSize', 10,'FontWeight','bold');

saveas(f, [FILE_NAME, '.m.png']);
exit;

