% This example code illustrates how to access and visualize LAADS MYD
% (MODIS-AQUA) swath file in Matlab. 
% If you have any questions, suggestions, comments  on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Identify the data file
FILE_NAME='MYD021KM.A2002226.0000.005.2009193222735.hdf';
% Identify the data swath
SWATH_NAME='MODIS_SWATH_Type_L1B';

% get file info
field_info = hdfinfo(FILE_NAME, 'eos');
% struct field_info.Swath.DataFields(3).Dims 3x1 struct array with fields:
%  Name Size

% Opening the HDF-EOS2 Swath Data File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
% Attach to the swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Identify the Data Field
DATAFIELD_NAME='EV_1KM_Emissive';

%=================%
% Read data field %
%=================%
[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);

% Detaching from the Swath Object
hdfsw('detach', swath_id);
% Closing the HDF-EOS2 Swath File
hdfsw('close', file_id);

% Read lat and lon data from the MODIS03 Geolocation file
FILE_NAME='MYD03.A2002226.0000.005.2009193071127.hdf';
SWATH_NAME='MODIS_Swath_Type_GEO';

% Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
% Attach to the swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Reading lat and lon data
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

% Detaching from the Swath Object
hdfsw('detach', swath_id);
% Closing the MODIS03 Geolocation file
hdfsw('close', file_id);

% Convert M-D data to 2-D data
lev=0
data=squeeze(data1(:,:,lev+1));

% Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

% Reading attributes from the data field
FILE_NAME='MYD021KM.A2002226.0000.005.2009193222735.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='EV_1KM_Emissive';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

% Reading filledValue from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% get the long name of the data field
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index)

% Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'radiance_units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'radiance_scales');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
% The scale is an array. We need to find the corresponding one.
scale = scale(1);
scale = double(scale);

% Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'radiance_offsets');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = offset(1);
offset = double(offset);

% Reading valid_range from the data field
range_index = hdfsd('findattr', sds_id, 'valid_range');
[range, status] = hdfsd('readattr',sds_id, range_index);

% Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
% Closing the File
hdfsd('end', SD_id);

% Replacing the filled value with NaN
data(data==fillvalue) = NaN;
% Replacing values outside of valid_range with NaN
data(data>range(2)) = NaN;

% Multiplying scale and adding offset, the equation is scale *(data-offset).
data = scale*(data-offset);

% Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% create the graphics figure -- 'visible'->'off' = off-screen rendering
figure_handle= figure('Name', ...
  'MYD021KM.A2002226.0000.005.2009193222735_EV_1KM_Emissive_Band_1KM_Emissive0', ...
  'visible','on');
% if 'visible'->'on', figure_handle may be undefined

whitebg('w');
% Set the plotting parameters
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on')
% load the coastlines data file
coast = load('coast.mat');

% surfacem is faster than controufm
surfacem(lat, lon, data);
% contourfm(lat, lon, data, 'LineStyle', 'none');
% use Matlab default 'cfd' colormap
colormap('Jet');
caxis([min(min(data)) max(max(data))]); 
cbar_handle=colorbar('YTick', min(min(data)):0.05:max(max(data)));
set (get(cbar_handle, 'title'), 'string', strcat('UNITS: ',units));

% plot coastlines in black ('k')
plotm(coast.lat,coast.long,'k')

% Set Title: "...EV_1KM_Emissive at Band 1KM Emissive=0..." from file attributes
title({'MYD021KM.A2002226.0000.005.2009193222735'; ...
      ['FIELD: Radiance derived from ',long_name ]; ...
      [ strrep(field_info.Swath.DataFields(3).Dims(1).Name,'_','\_'),'=',int2str(lev)]}, ...
      'FontSize',16,'FontWeight','bold');

% if off-screen rendering, set image size to screen size
scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
  set(figure_handle,'position',scrsz,'PaperPositionMode','auto');

  saveas(figure_handle, ...
  'MYD021KM.A2002226.0000.005.2009193222735_EV_1KM_Emissive_Band_1KM_Emissive0.m.jpg');
end

