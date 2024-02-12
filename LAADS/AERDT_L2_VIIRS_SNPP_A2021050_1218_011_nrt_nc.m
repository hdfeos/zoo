%
% This example code illustrates how to access and visualize LAADS
% AERDT_L2_VIIRS_SNPP_NRT netCDF-4/HDF5 Swath file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
% 
% $matlab -nosplash -nodesktop -r AERDT_L2_VIIRS_SNPP_A2021050_1218_011_nrt_nc
%
% Tested under: MATLAB R2020a
% Last updated: 2020-03-02

import matlab.io.hdf5.*

% Open the HDF5 File.
FILE_NAME = 'AERDT_L2_VIIRS_SNPP.A2021050.1218.011.nrt.nc';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
LATFIELD_NAME='/geolocation_data/latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='/geolocation_data/longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

DATAFIELD_NAME='/geophysical_data/Image_Optical_Depth_Land_And_Ocean';
data_id=H5D.open(file_id, DATAFIELD_NAME);


% Read the datasets.
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units_data = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name_data = H5A.read(attr_id, 'H5ML_DEFAULT');


% Read the fillvalue.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

                                % Read scale_factor attribute.
ATTRIBUTE = 'scale_factor';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
scale = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read add_offset attribute.
ATTRIBUTE = 'add_offset';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
offset = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5D.close (lon_id);
H5D.close (lat_id);
H5F.close (file_id);

% Handle fill value.
data(data==fillvalue) = NaN;

% Apply scale factor.
data = data*scale+offset;

% Create the graphics figure.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible','off');

% Put title.
var_name = sprintf('%s', long_name_data);
tstring = {FILE_NAME; var_name};

% Title is long. Use a small font size.
title(tstring,...
      'Interpreter', 'none', 'FontSize', 10, ...
      'FontWeight','bold');
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')

% Plot world map coast line.
scatterm(lat(:), lon(:), 1, data(:));
h = colorbar();
units_str = sprintf('%s', char(units_data));
%Title is very long. Put units label vertically.
ylabel(h, units_str)

% Plot world map coast line.
coast = load('coast.mat');
plotm(coast.lat, coast.long, 'k');
tightmap;
saveas(f, [FILE_NAME '.m.png']);
exit;
