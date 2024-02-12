%
%  This example code illustrates how to access and visualize LP DAAC ASTER
% GED (AG100) v3 HDF5 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r AG100_v003_64__089_0001_h5
%
% Tested under: MATLAB R2017a
% Last updated: 2018-05-09

clear

% Open the HDF5 File.
FILE_NAME = 'AG100.v003.64.-089.0001.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'Emissivity/Mean';
data_id = H5D.open(file_id, DATAFIELD_NAME);

LATFIELD_NAME='Geolocation/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='Geolocation/Longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);


% Read the datasets.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
  
% Read the attribute.
ATTRIBUTE = 'Description';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
description = H5A.read(attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Change type for scaling.
data = double(data);

% Subset for Band 10 (8.3 um) [1].
data = data(:,:,2);

% Handle _FillValue [1].
data(data == -9999) = NaN;

% Apply scale factor [1].
data = 0.001*data;

% Annotate plot.
long_name = 'Mean Emissivity for Band 10';
units = 'None';

% Compute latitude and longitude limits for the map.
latlim = double([min(min(lat)),max(max(lat))]);
lonlim = double([min(min(lon)),max(max(lon))]);

% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];


% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'Visible', 'off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
    'MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on', ...
    'MLabelLocation', 0.2, 'PLabelLocation', 0.2, ...
    'MLineLocation',  0.2, 'PlineLocation', 0.2, ...
    'MlabelParallel', min(latlim), 'LabelUnits', 'dm');

tightmap;
surfm(lat,lon,data);
cmap = colormap('Jet');
% caxis([min_data max_data]); 
geoshow(coast.lat, coast.long, 'Color', 'k');

% Create a colorbar. The colorbar can be moved to the right side of the
% plot by setting 'Location' to 'vertical'.
h = colorbar();
set(get(h, 'title'), 'string', units, ...
    'Interpreter', 'none', ...
    'FontSize', 8, 'FontWeight','bold');

% Put title.
tstring = {FILE_NAME; long_name};
title(tstring, 'Interpreter', 'none', 'FontSize', 10,'FontWeight', ...
      'bold');

% Put description.
description_s = sprintf('%s', char(description));
ylim=get(gca,'YLim');
xlim=get(gca,'XLim');
text(xlim(1), ylim(1)-0.0020,description_s,...
     'FontSize', 8, ...     
     'VerticalAlignment','bottom',...
     'HorizontalAlignment','left')

saveas(f, [FILE_NAME '.m.png']);

exit;
% References
%
% [1] https://lpdaac.usgs.gov/sites/default/files/public/files/ASTER_GED.pdf
