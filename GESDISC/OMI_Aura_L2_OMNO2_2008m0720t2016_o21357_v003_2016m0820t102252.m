% 
%  This example code illustrates how to access and visualize OMI Swath file
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
% Maximum length is 63 so we drop .he5 from our code.
% $matlab -nosplash -nodesktop -r OMI_Aura_L2_OMNO2_2008m0720t2016_o21357_v003_2016m0820t102252
%
% Tested under: MATLAB R2017a
% Last updated: 2018-01-16

clear

% Open the HDF5 File.
FILE_NAME = ...
    'OMI-Aura_L2-OMNO2_2008m0720t2016-o21357_v003-2016m0820t102252.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = '/HDFEOS/SWATHS/ColumnAmountNO2/Data Fields/CloudFraction';
data_id = H5D.open (file_id, DATAFIELD_NAME);

Lat_NAME='HDFEOS/SWATHS/ColumnAmountNO2/Geolocation Fields/Latitude';
lat_id=H5D.open(file_id, Lat_NAME);

Lon_NAME='HDFEOS/SWATHS/ColumnAmountNO2/Geolocation Fields/Longitude';
lon_id=H5D.open(file_id, Lon_NAME);

% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the offset.
ATTRIBUTE = 'Offset';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
offset = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the scale.
ATTRIBUTE = 'ScaleFactor';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
scale = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the missing value.
ATTRIBUTE = 'MissingValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
missingvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read title attribute.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name=H5A.read (attr_id, 'H5ML_DEFAULT');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;
% Replace the missing value with NaN.
data(data==missingvalue) = NaN;

% Apply scale and offset, the equation is scale *(data-offset).
data = scale*(data-offset);

% Plot the data.
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible', 'off');

if isempty(ver('map'))
    warning('Mapping Toolbox not present.')
    pcolor(lon,lat,data); shading flat;
else
    latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
    lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

    h = axesm('MapProjection','eqdcylin','MapLatLimit', ...
              latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
              'MeridianLabel','on','ParallelLabel','on', ...
              'MLabelParallel','south');
    setm(h,'MapLatLimit',latlim,'MapLonLimit',lonlim);
    setm(h,'Frame','on','Grid','on');
    
    contourm(lat, lon, data);

    coast = load('coast.mat');
    plotm(coast.lat,coast.long,'k')
    
end

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min(min(data)):granule:max(max(data)));

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);
set(get(h, 'title'), 'string', unit, 'FontSize',16,'FontWeight', ...
                   'bold');

plotm(coast.lat,coast.long,'k');

title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize',16,'FontWeight','bold');


saveas(f, [FILE_NAME '.m.png']);
exit;


