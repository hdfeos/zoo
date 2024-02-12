% This example code illustrates how to access and visualize LAADS MODIS swath
% file in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use
%  the HDF-EOS Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% See file specification:
% http://ladsweb.nascom.nasa.gov/filespecs/MOD06_L2.CDL.fs

clear

% Set the HDF file name
FILE_NAME='MOD06_L2.A2010001.0000.005.2010005213214.hdf';

% get file info
field_info = hdfinfo(FILE_NAME, 'eos');
% struct field_info.Swath.DataFields(1).Dims 3x1 struct array with fields:
%  Name Size

% Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');

% Attach to the data swath
SWATH_NAME='mod06';
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Identify the Swath Data Field
DATAFIELD_NAME='Cloud_Optical_Thickness';

%================================%
% Reading Data from a Swath Data Field %
%================================%
[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);

% Detaching from the Swath Object
hdfsw('detach', swath_id);
% Closing the HDF-EOS2 Swath File
hdfsw('close', file_id);

% Read lat and lon data from the MODIS03 Geolocation file
FILE_NAME='MOD03.A2010001.0000.005.2010003235220.hdf';
SWATH_NAME='MODIS_Swath_Type_GEO';

% Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
% Attach to the data swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Reading lat and lon data
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

% Detaching from the Swath Object
hdfsw('detach', swath_id);
% Closing the HDF-EOS2 Swath File
hdfsw('close', file_id);

% Convert M-D data to 2-D data
data=data1;

%Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

%Reading attributes from the data field
FILE_NAME='MOD06_L2.A2010001.0000.005.2010005213214.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='Cloud_Optical_Thickness';

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

% Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = double(offset);

% Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
% Closing the File
hdfsd('end', SD_id);

% Replacing the filled value with NaN
data(data==fillvalue) = NaN;
% Replacing values outside of valid_range with NaN
data(data<valid_range(1)) = NaN;
data(data>valid_range(2)) = NaN;

% Multiplying scale and adding offset, the equation is scale *(data-offset).
data = scale*(data-offset);

% Plot the data using contourfm and axesm
pole=[-90 0 0];
latlim=[-90,ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

% create the graphics figure -- 'visible'->'off' = off-screen rendering
figure_handle= figure('Name', ...
    'MOD06_L2.A2010001.0000.005.2010005213214_Cloud_Optical_Thickness', ...
    'visible','on');
% if 'visible'->'on', figure_handle is undefined

whitebg('w');
axesm('MapProjection','stereo','MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
      'Origin',pole,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on')
% load the coastlines data file
coast = load('coast.mat');

% surfacem is faster than controufm
surfacem(lat, lon, data);
% contourfm(lat, lon, data, 'LineStyle', 'none');
% use Matlab default 'cfd' colormap
colormap('Jet');
caxis([min_data max_data]); 
cbar_handle=colorbar('YTick', min_data:10:max_data);
set (get(cbar_handle, 'title'), 'string', strcat('UNITS: ',units));

% plot coastlines in black
plotm(coast.lat,coast.long,'k')

% set title: Cloud Optical Thickness from file attributes
% Since long_name is too long (> 122 characters), we use DATAFIELD_NAME.
title({'MOD06\_L2.A2010001.0000.005.2010005213214'; ...
       [ 'Field: ', strrep(DATAFIELD_NAME,'_',' ') ]}, ...
       'FontSize',16,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
if ishghandle(figure_handle)
  set(figure_handle,'position',scrsz,'PaperPositionMode','auto');

  saveas(figure_handle, ...
  'MOD06_L2.A2010001.0000.005.2010005213214_Cloud_Optical_Thickness_Polar.m.jpg');
end

