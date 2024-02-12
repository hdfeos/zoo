%
%  This example code illustrates how to access and visualize MERRA-2 L3 file
% in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r MERRA2_400_tavg3_3d_nav_Ne_20151226_nc4
%
% Tested under: MATLAB R2015a
% Last updated: 2016-01-26

clear

% Open the netCDF-4/HDF5 File.
FILE_NAME = 'MERRA2_400.tavg3_3d_nav_Ne.20151226.nc4';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'ZLE';
data_id = H5D.open (file_id, DATAFIELD_NAME);

Lat_NAME='lat';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='lon';
lon_id=H5D.open(file_id, Lon_NAME);

Lev_NAME='lev';
lev_id=H5D.open(file_id, Lev_NAME);

Time_NAME='time';
time_id=H5D.open(file_id, Time_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lev=H5D.read(lev_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
time=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the long name.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the units of lev.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (lev_id, ATTRIBUTE);
lev_units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the long name of lev.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (lev_id, ATTRIBUTE);
lev_long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the units of time.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (time_id, ATTRIBUTE);
time_units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the long name of time.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (time_id, ATTRIBUTE);
time_long_name = H5A.read(attr_id, 'H5ML_DEFAULT');


% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Subset data at time=1 and lev=1.
data=squeeze(data(:,:,1,1));

% Plot the data using surfm and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');

if isempty(ver('map'))
    warning('Mapping Toolbox not present.')
    pcolor(lon,lat,data); shading flat;
else
    latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
    lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

    axesm('MapProjection','eqdcylin','MapLatLimit', ...
          latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
          'MeridianLabel','on','ParallelLabel','on', ...
          'MLabelParallel','south');
    tightmap;
    surfm(lat,lon,data');

    coast = load('coast.mat');
    plotm(coast.lat,coast.long,'k')
    
end

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));
granule = (max_data - min_data) / ntickmarks;
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:granule:max_data);
unit = sprintf('%s', units);
set(get(h, 'title'), 'string', unit, 'FontSize',16,'FontWeight', ...
                   'bold');


plotm(coast.lat,coast.long,'k');

name = sprintf('%s', long_name);
name_lev = sprintf('%s', lev_long_name);
name_time = sprintf('%s', time_long_name);
units_lev = sprintf('%s', lev_units);
units_time = sprintf('%s', time_units);

tstr = num2str(time(1));
lstr = num2str(lev(1));
title({FILE_NAME; name ; [name_time ' = ' tstr ' ' units_time] ; 
       [name_lev ' = ' lstr ' ' units_lev]}, ... 
      'Interpreter', 'None', 'FontSize', 16,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


