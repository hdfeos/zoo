%  This example code illustrates how to access and visualize PO.DAAC AQUARIUS
% SSS L3 Grid HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2011b
% Last updated: 2012-02-27

clear

% Open the HDF5 File.
FILE_NAME = 'Q2012034.L3m_DAY_EVSCI_V1.2DR_SSS_1deg.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = 'l3m_data';
data_id = H5D.open (file_id, DATAFIELD_NAME);

% Read the datasets.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');

% Read the attributes.
ATTRIBUTE = 'Parameter';
attr_id = H5A.open_name (file_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'Units';
attr_id = H5A.open_name (file_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Convert the data type for plot.
data=double(data);

% Filter data based on "Suggested Image Scaling Maximum" and 
% "Suggested Image Scaling Minimum" file attribute values
% as specified in [1].
data(data > 38.0) = NaN;
data(data < 32.0) = NaN;

% You may want to set 0 as fill value if you don't plot values on land area.
data(data == -32767.0) = NaN;

% Transpose data for map.
data = data';

% Calculate lat and lon according to file specfication.
% It's simple 360 (lon) x 180 (lat) size grid.
[latdim, londim] = size(data);
for i=1:latdim
    lat(i)=90 - (i-1+0.5);
end

for j=1:londim
    lon(j)=(j-1+0.5) - 180;
end

% Convert the data to double type for plot.
lon=double(lon);
lat=double(lat);

% Create the graphics figure.
f=figure('Name', FILE_NAME, 'visible', 'off');


% Set the map parameters.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','FontSize',10)

% Load the global coastlines graphics
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')
surfm(lat,lon, data);

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

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;
