%
% This example code illustrates how to access and visualize PO.DAAC AQUARIUS
% SSS L3 Grid HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r Q2012034_L3m_DAY_SCI_V5_0_SSS_1deg_h5
%
% Tested under: MATLAB R2019b
% Last updated: 2019-10-21

clear

% Open the HDF5 File.
FILE_NAME = 'Q2012034.L3m_DAY_SCI_V5.0_SSS_1deg.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Read the file attributes.
ATTRIBUTE = 'data_minimum';
attr_id = H5A.open_name (file_id, ATTRIBUTE);
minval = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'data_maximum';
attr_id = H5A.open_name (file_id, ATTRIBUTE);
maxval = H5A.read(attr_id, 'H5ML_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = 'l3m_data';
data_id = H5D.open (file_id, DATAFIELD_NAME);

% Read the datasets.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
FillValue = H5A.read(attr_id, 'H5ML_DEFAULT');



% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Convert the data type for plot.
data=double(data);

% Filter data based on file attribute values as specified in [1].
data(data > maxval) = NaN;
data(data < minval) = NaN;

% You may want to set 0 as fill value if you don't plot values on land area.
data(data == FillValue) = NaN;

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
f=figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...         
         'Position', [0,0,800,600], ...         
         'visible', 'off');

% Set the map parameters.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south');

% Load the global coastlines graphics
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')
surfm(lat,lon, data);

colormap('Jet');
h=colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
units = 'psu';
long_name = 'Sea Surface Salinity';

% Draw unit.
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME;long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');
tightmap;

saveas(f, [FILE_NAME '.m.png']);
exit;

% Reference
%
% [1] https://podaac-tools.jpl.nasa.gov/drive/files/allData/aquarius/docs/v5/AQ-010-UG-0008_AquariusUserGuide_DatasetV5.0.pdf