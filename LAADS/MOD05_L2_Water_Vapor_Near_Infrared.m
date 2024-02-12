% This example code illustrates how to access and visualize LAADS MODIS swath
% file in Matlab. 
% If you have any questions, suggestions, comments  on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Read data field
FILE_NAME='MOD05_L2.A2010001.0000.005.2010005211557.hdf';
SWATH_NAME='mod05';

% get file info
field_info = hdfinfo(FILE_NAME, 'eos');
% struct field_info.Swath.DataFields(1).Dims 3x1 struct array with fields:
%  Name Size

% Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
% Open swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Reading Data from a Data Field
DATAFIELD_NAME='Water_Vapor_Near_Infrared';

[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);

% Detaching from the Swath Object
hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Convert M-D data to 2-D data
data=data1;

% Read lat and lon data
FILE_NAME='MOD03.A2010001.0000.005.2010003235220.hdf';
SWATH_NAME='MODIS_Swath_Type_GEO';

% Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
% Open swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Reading lat and lon data
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

% Detaching from the Swath Object
hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

% Reading attributes from the data field
FILE_NAME='MOD05_L2.A2010001.0000.005.2010005211557.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='Water_Vapor_Infrared';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

% Reading filledValue from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% long name for title
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% data valid range
valid_range_index = hdfsd('findattr', sds_id, 'valid_range');
[valid_range, status] = hdfsd('readattr',sds_id, valid_range_index);

% Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
scale = double(scale);

% Reading add_offset from the data Field
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = double(offset);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);


% Replacing the filled value with NaN
data(data==fillvalue) = NaN;
% Replacing values outside of valid_range with NaN
data(data<valid_range(1)) = NaN;
data(data>valid_range(2)) = NaN;

%Multiplying scale and adding offset, the equation is scale *(data-offset).
data = scale*(data-offset);

%Plot the data using contourfm and axesm
pole=[-90 0 0];
latlim=[-90, ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% create the graphics figure -- 'visible'->'off' = off-screen rendering
figure_handle=figure('Name', ...
'MOD05_L2.A2010001.0000.005.2010005211557_Water_Vapor_Near_Infrared', ...
'visible','on');
% if 'visible'->'on', figure_handle is undefined

whitebg('w');
% setting the plotting parameters
axesm('MapProjection','stereo','MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
      'Origin',pole,'Frame','on','Grid','on', ...
     'MeridianLabel','on','ParallelLabel','on')
% load the coastlines data
coast = load('coast.mat');

% surfacem is faster than controufm
surfacem(lat, lon, data);
% contourfm(lat, lon, data);
% use Matlab default 'cfd' colormap
colormap('Jet');
caxis([min(min(data)) max(max(data))]); 
cbar_handle=colorbar('YTick', min(min(data)):0.1:max(max(data)));
set (get(cbar_handle, 'title'), 'string', strcat('UNITS: ',units));

% plot coastlines in black
plotm(coast.lat,coast.long,'k')

% set title: Water Vapor Near Infrared from file attributes
title({'MOD05\_L2.A2010001.0000.005.2010005211557'; ...
      ['FIELD: Derived from ', long_name];
      [strrep(field_info.Swath.DataFields(1).Dims(1).Name,'_','\_') ]}, ...
       'FontSize',16,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
  set(figure_handle,'position',scrsz,'PaperPositionMode','auto');

  saveas(figure_handle, ...
  'MOD05_L2.A2010001.0000.005.2010005211557_Water_Vapor_Near_Infrared_Polar.m.jpg');
end

