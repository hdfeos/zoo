%
%  This example code illustrates how to access and visualize GPM L3 file
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
% $matlab -nosplash -nodesktop -r GPM_3_MO
%
% Tested under: MATLAB R2015a
% Last updated: 2016-01-12

clear

% Open the HDF5 File.
FILE_NAME = '3B-MO.MS.MRG.3IMERG.20141201-S000000-E235959.12.V03D.HDF5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'Grid/precipitation';
data_id = H5D.open (file_id, DATAFIELD_NAME);

Lat_NAME='Grid/lat';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='Grid/lon';
lon_id=H5D.open(file_id, Lon_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');


% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');


% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

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
    surfm(lat,lon,data);

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

name = sprintf('%s', DATAFIELD_NAME);
title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 16,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


