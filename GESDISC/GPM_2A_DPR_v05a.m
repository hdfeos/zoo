%
%  This example code illustrates how to access and visualize GPM L2 file
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
% $matlab -nosplash -nodesktop -r GPM_2A_DPR_v05a
%
% Tested under: MATLAB R2017a
% Last updated: 2017-09-11

clear

% Open the HDF5 File.
FILE_NAME = '2A.GPM.DPR.V7-20170308.20170704-S001905-E015140.019017.V05A.HDF5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'NS/SLV/precipRateESurface';
data_id = H5D.open(file_id, DATAFIELD_NAME);

Lat_NAME='NS/Latitude';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='NS/Longitude';
lon_id=H5D.open(file_id, Lon_NAME);

% Read the dataset.
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


% Read the fill value attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue = H5A.read(attr_id, 'H5ML_DEFAULT');

                                   
% Read the units attribute.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');



% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;


f=figure('Name', FILE_NAME, 'visible', 'off');

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
lat = lat(:)';
lon = lon(:)';
data = data(:)';
scatterm(lat, lon, 1, data);
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')

tightmap;

h = colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction.
units1 = sprintf('%s', char(units));

% long_name is pretty long so use a small font.
set (get(h, 'title'), 'string', units1, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');
  
name = sprintf('%s', DATAFIELD_NAME);

% Unit is also long so we use a small font.
title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


