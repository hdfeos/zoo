%
%  This example code illustrates how to access and visualize PO.DAAC AQUARIUS
% SSS L2 Swath HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2019b
% Last updated: 2019-10-19

% Open the HDF5 File.
FILE_NAME = 'Q2011280003000.L2_SCI_V5.0.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = 'Aquarius Data/SSS';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME='Navigation/sclat';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LEVFIELD_NAME='Navigation/scalt';
lev_id=H5D.open(file_id, LEVFIELD_NAME);

LONFIELD_NAME='Navigation/sclon';
lon_id=H5D.open(file_id, LONFIELD_NAME);

% Read the datasets.
data1=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lev=H5D.read(lev_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Read the attributes.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue = H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Handle fill value.
data1(data1 == fillvalue) = NaN;

% Subset data.
data1 = data1';
data=squeeze(data1(:,1));

% Create the graphics figure.
f=figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...         
         'Position', [0,0,800,600], ...         
         'visible', 'off');


% Set the map parameters.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south');

% Load the global coastlines graphics
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')
scatterm(lat, lon, 1, data);    

colormap('Jet');
h=colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);

% Draw unit.
set(get(h, 'title'), 'string', unit, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME;name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');
tightmap;

saveas(f, [FILE_NAME '.m.png']);
exit;
