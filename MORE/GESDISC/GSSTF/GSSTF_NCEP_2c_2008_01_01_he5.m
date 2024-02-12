%
%  This example code illustrates how to access and visualize MEaSUREs GSSTF
% HDF-EOS5 Grid file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS  Comprehensive Examples 
% page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum 
% (http://hdfeos.org/forums).

% Usage:save this script and run (without .m at the end)
%
%   #matlab -nosplash -nodesktop -r GSSTF_NCEP_2c_2008_01_01_he5
%
% Tested under: MATLAB R2012a
% Last updated: 2013-1-18

clear

% Open the HDF-EOS5 file.
FILE_NAME = 'GSSTF_NCEP.2c.2008.01.01.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = '/HDFEOS/GRIDS/NCEP/Data Fields/SST';
data_id = H5D.open (file_id, DATAFIELD_NAME);

% Get dataspace.
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');

% Transpose the data to match the map projection.
data=data';

% Release resources.
H5S.close (data_space)

% Read the units attribute.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fill value attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the long name attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
longname=H5A.read (attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Since the datafile doesn't provide lat and lon, we need to
% calculate lat and lon data using Geographic projection.
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

% Convert the data to double type for plotting.
lon=double(lon_value);
lat=double(lat_value);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;


f = figure('Name', FILE_NAME, 'visible', 'off');

axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

% surfm() is faster than contourfm().
surfm(lat, lon, data);
colormap('Jet');
h=colorbar();
plotm(coast.lat,coast.long,'k')

% Draw unit.
% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction.
units_str = sprintf('%s', char(units));
set(get(h, 'title'), 'string', units_str, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
longname_str = sprintf('%s', char(longname));
tstring = {FILE_NAME;longname_str};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;
