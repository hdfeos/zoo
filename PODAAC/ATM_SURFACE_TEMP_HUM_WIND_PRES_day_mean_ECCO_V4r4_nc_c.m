%
%  This example code illustrates how to access and visualize
% a PO.DACC ECCO L4 netCDF-4/HDF5 Grid file on AWS S3 [0] in MATLAB. 
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
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r ATM_SURFACE_TEMP_HUM_WIND_PRES_day_mean_ECCO_V4r4_nc_c
%
% Tested under: MATLAB R2021a
% Last updated: 2022-06-21

% Change key and token values. See [1, 2].
setenv('AWS_ACCESS_KEY_ID', '20_CHARACTERS_LONG_KEY'); 
setenv('AWS_SECRET_ACCESS_KEY', '40_CHARACTERS_LONG_KEY');
setenv('AWS_SESSION_TOKEN', '396_CHARACTERS_LONG_KEY'); 
setenv('AWS_DEFAULT_REGION', 'us-west-2');

% Open the netCDF-4 file on AWS S3.
BUCKET_NAME='s3://podaac-ops-cumulus-protected/';
KEY_NAME = 'ECCO_L4_ATM_STATE_05DEG_DAILY_V4R4/';		 
FILE_NAME='ATM_SURFACE_TEMP_HUM_WIND_PRES_day_mean_2017-12-31_ECCO_V4r4_latlon_0p50deg.nc';
file_id = H5F.open([BUCKET_NAME, KEY_NAME, FILE_NAME], 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Read data from a data field.
DATAFIELD_NAME='EXFatemp';
data_id = H5D.open(file_id, DATAFIELD_NAME);
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Read units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');
H5A.close(attr_id);

% Read long_name.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name=H5A.read (attr_id, 'H5ML_DEFAULT');
H5A.close(attr_id);

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue=H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');
H5A.close(attr_id);

% Read latitude data.
LAT_NAME='latitude';
lat_id=H5D.open(file_id, LAT_NAME);
lat=H5D.read(lat_id, 'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


% Read longitude data.
LON_NAME='longitude';
lon_id=H5D.open(file_id, LON_NAME);
lon=H5D.read(lon_id, 'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Close and release resources.
H5D.close(data_id);
H5D.close(lat_id);
H5D.close(lon_id);
H5F.close(file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;


% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');
data = data';
% Plot the data using axesm and surfm.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize', 8)
surfm(double(lat),double(lon),data(:,:,1));
colormap('Jet');
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k');

h = colorbar();
unit = sprintf('%s', units);		 
set (get(h, 'title'), 'string', unit, 'Interpreter', 'None')
tightmap;
ln = sprintf('%s', long_name);
title({FILE_NAME;ln}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME  '.c.m.png']);
exit;

% Reference
%
% [0] https://search.earthdata.nasa.gov/search/granules/collection-details?p=C1990404801-POCLOUD&pg[0][v]=f&pg[0][gsk]=-start_date&g=G1991242272-POCLOUD&q=ECCO_L4_ATM_STATE_05DEG_DAILY_V4R4&tl=1629486312.62!3!!&m=-0.28125!0!0!1!0!0%2C2
% [1] https://archive.podaac.earthdata.nasa.gov/s3credentials
% [2] https://www.mathworks.com/help/matlab/import_export/work-with-remote-data.html
