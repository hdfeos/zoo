%
% This example code illustrates how to access and visualize LAADS MODIS Swath
% file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MOD021KM_A2015013_1240_006_2015014140954_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-02-06


clear

% Read data field
FILE_NAME='MOD021KM.A2015013.1240.006.2015014140954.hdf';
SWATH_NAME='MODIS_SWATH_Type_L1B';

% get file info
field_info = hdfinfo(FILE_NAME, 'eos');
% struct field_info.Swath.DataFields(1).Dims 3x1 struct array with fields:
%  Name Size

% Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
% Open swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Define the Data Field
DATAFIELD_NAME='EV_Band26';

%====================%
% Read the datafield %
%====================%
[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);

% Detaching from the Swath Object
hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Read lat and lon data
GEO_FILE_NAME='MOD03.A2015013.1240.006.2015013194359.hdf';
SWATH_NAME='MODIS_Swath_Type_GEO';

% Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', GEO_FILE_NAME, 'rdonly');
% Open swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Reading lat and lon data
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

% Detaching from the Swath Object
hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Convert M-D data to 2-D data
data=data1;

% Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

% Reading attributes from the data field
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='EV_Band26';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

% Reading filledValue from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% get the long name of the data field
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'radiance_units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'radiance_scales');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
scale = double(scale);

% Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'radiance_offsets');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
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
data(data>range(2)) = NaN;

% Multiplying scale and adding offset, the equation is scale *(data-offset).
data = scale*(data-offset);

% create the graphics figure -- 'visible'->'off' = off-screen rendering
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% setting the plotting parameters
% Set the map parameters.
lon_c = mean(mean(lon));
lat_c = mean(mean(lat));
latlim=ceil(max(max(lat))) - floor(min(min(lat)))

% FlatLimit will give us a zoom-in effect in Ortho projection.
axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'FLatLimit', [-Inf, latlim], ...
       'origin', [lat_c, lon_c])
mlabel('equator')
plabel(0); 
plabel('fontweight','bold')

% load the coastlines data file
coast = load('coast.mat');
% plot coastlines in color black ('k')
plotm(coast.lat,coast.long,'k')

% surfacem is faster than controufm
surfm(lat, lon, data);


colormap('Jet');
h=colorbar();
set (get(h, 'title'), 'string', strcat('UNITS: ',units));

% set the title using long_name
title({FILE_NAME; ...
      ['FIELD: Radiance derived from ',long_name ]; 
      [strrep(field_info.Swath.DataFields(1).Dims(1).Name,'_','\_') ]}, ...
      'FontSize',10,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


