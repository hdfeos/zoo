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
%   #matlab -nosplash -nodesktop -r GSSTF_2c_2008_01_01_he5.m
%
% Tested under: MATLAB R2012a
% Last updated: 2013-1-18
clear

% Open the HDF-EOS5 File.
FILE_NAME = 'GSSTF.2c.2008.01.01.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD1_NAME = '/HDFEOS/GRIDS/SET1/Data Fields/Qair';
data1_id = H5D.open (file_id, DATAFIELD1_NAME);


% Get the dataspace.
data1_space = H5D.get_space(data1_id);
[data1_numdims data1_dims data1_maxdims] = ...
    H5S.get_simple_extent_dims(data1_space);
data1_dims=fliplr(data1_dims');


% Read the dataset.
data1=H5D.read(data1_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');

% Transpose the data to match the map projection.
data1=data1';

% Release resources.
H5S.close (data1_space)

% Read the units attribute.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data1_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction.
units1 = sprintf('%s', char(units));

% Read the fill value attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data1_id, ATTRIBUTE);
fillvalue1 = H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');


% Read the long name attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data1_id, ATTRIBUTE);
longname = H5A.read (attr_id, 'H5ML_DEFAULT');
longname1 = sprintf('%s', char(longname));

% Close and release resources.
H5A.close (attr_id)
H5D.close (data1_id);
H5F.close (file_id);


% Since the data file doesn't provide lat and lon, we need to
% calculate lat and lon data using Geo projection information 
% in the StructMetadata.
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

% Convert the data to double type for plot.
lon1=double(lon1_value);
lat1=double(lat1_value);

% Replace the filled value with NaN.
data1(data1==fillvalue1) = NaN;


f = figure('Name', FILE_NAME, 'visible', 'off');

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

% surfm is faster than contourfm.
surfm(lat1, lon1, data1);
colormap('Jet');
h=colorbar();
plotm(coast.lat,coast.long,'k')

% Draw unit.
set(get(h, 'title'), 'string', units1, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME;longname1};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;
