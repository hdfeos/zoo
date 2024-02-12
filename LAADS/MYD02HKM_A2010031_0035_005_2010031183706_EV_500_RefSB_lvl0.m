% This example code illustrates how to access and visualize LP DAAC
% MYD Swath data file in MATLAB.

% If you have any questions, suggestions, comments on this example, please use
% the HDF-EOS Forum (http://hdfeos.org/forums).
%
% If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS% Forum (http://hdfeos.org/forums).

% Refer to:
% ftp://ftp.hdfgroup.uiuc.edu/pub/outgoing/NASAHDF/MYD02HKM.A2010031.0035.005.2010031183706.hdf
% Data field name: EV_500_RefSB

% Tested under: MATLAB R2011b
% Last update: 2011-09-26

clear;

% Open the HDF-EOS2 Swath File.
FILE_NAME='MYD02HKM.A2010031.0035.005.2010031183706.hdf';
file_id = hdfsw('open', FILE_NAME, 'rdonly');

% Identify the swath.
SWATH_NAME='MODIS_SWATH_Type_L1B';
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Define data field.
DATAFIELD_NAME='EV_500_RefSB';

% Read the data field. 
[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
  
% Detach from the Swath Object.
hdfsw('detach', swath_id);

% Close the HDF Swath file interface.
hdfsw('close', file_id);

% Extract 2-D data from 3-D data at Band_500M = 0.
lev=0;
data=squeeze(data1(:,:,lev+1));

% Convert the data to double type for plot.
dataf=double(data);

% Get field info.
% struct field_info.Swath.DataFields(1).Dims 3x1 struct array with fields:
%  Name Size
field_info = hdfinfo(FILE_NAME, 'eos');


% Read attributes using the Scientific Data Set interface
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);

% Read fill value from the data field.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
if fillvalue_index >= 0
  [fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);
  if status < 0
    warning('hdfsd::readattr: failed to read _FillValue');
  end
else
  warning('hdfsd::findattr: failed to find _FillValue');
end

% Get the long name attribute of the data field.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
if long_name_index>= 0
  [long_name, status] = hdfsd('readattr',sds_id, long_name_index);
  if status < 0
    warning('hdfsd::readattr: failed to read long_name');
  end
else
  warning('hdfsd::findattr: failed to find long_name');
end

% Read unit attribute from the data field.
units_index = hdfsd('findattr', sds_id, 'reflectance_units');
if units_index >= 0
  [units, status] = hdfsd('readattr',sds_id, units_index);
  if status < 0
    warning('hdfsd::readattr: failed to read units');
  end
else
  warning('hdfsd::findattr: failed to find units');
end

% Read scale_factor attribute from the data field.
% See: 
% ftp://modular.nascom.nasa.gov/pub/LatestFilespecs/collection5/MYD02HKM.fs
% http://www.hdfgroup.org/release4/HDF4_UG_html/UG_SD.html#wp14023
scale_index = hdfsd('findattr', sds_id, 'reflectance_scales');
if scale_index >= 0
  [scale, status] = hdfsd('readattr',sds_id, scale_index);
  if status < 0
    warning('hdfsd::readattr: failed to read scale_factor');
  end
else
  warning('hdfsd::findattr: failed to find scale_factor');
end
% Scale is 1 x 5 array.
% Assert that scale is double type.
scale=double(scale);

% Read add_offset from the data field.
offset_index = hdfsd('findattr', sds_id, 'reflectance_offsets');
if offset_index  >= 0
  [offset, status] = hdfsd('readattr',sds_id, offset_index);
  if status < 0
    warning('hdfsd::readattr: failed to read add_offset');
  end
else
  warning('hdfsd::findattr: failed to find add_offset');
end

% Offset is 1 x 5 integer array.
% Assert that the offset is double type.
offset=double(offset);

valid_range_index = hdfsd('findattr', sds_id, 'valid_range');
if valid_range_index >= 0
  [valid_range, status] = hdfsd('readattr', sds_id, valid_range_index);
  if status < 0
    warning('hdfsd::readattr: failed to read valid_range');
  end
else
  warning('hdfsd::findattr: failed to find valid_range');
end

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Replace the filled value with NaN.
dataf(data==fillvalue) = NaN;

% Mask values outside of valid_range.
dataf(data < valid_range(1)) = NaN;
dataf(data > valid_range(2)) = NaN;

% Multiply scale and adding offset, the equation is scale *(data-offset).
dataf = scale(1)*(dataf-offset(1));

% Read lat/lon info from the outputs of  eo2dump file.
lat1D = ...
    load('lat_MYD02HKM.A2010031.0035.005.2010031183706.output');

lon1D = ...
    load('lon_MYD02HKM.A2010031.0035.005.2010031183706.output');
[xdimsize, ydimsize] = size(data);
lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);


% Get max and min of latitude and longitude.
% Stereographic projection requires latlim(1) == -90 (the pole).
latlim=[-90,ceil(max(max(lat)))];

% Polar Stereographic Projection centered at the South Pole.
pole=[-90 0 0];

% Create the graphics figure -- 'visible'->'off' = off-screen
% rendering.
% If 'visible'->'on', figure_handle is undefined.
figure_handle=figure('Name', FILE_NAME, 'visible','off');

% Set the plotting parameters.
axesm('MapProjection','stereo','MapLatLimit', latlim,... 
      'Origin', pole,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on');

% Load the coastlines data.
coast = load('coast.mat');

% Draw plot using surfm() since it is faster than contourfm().
surfm(lat, lon, dataf);

% Draw the coastlines in color black ('k').
plotm(coast.lat,coast.long,'k')

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
colormap('Jet');
min_data=min(min(dataf));
max_data=max(max(dataf));
granule = (max_data - min_data) / ntickmarks;
caxis([min_data max_data]);
cbar_handle=colorbar('YTick', min_data:granule:max_data);
set(get(cbar_handle, 'title'), 'string', units);


title({FILE_NAME; ...
      ['Reflectance derived from ', long_name ]; ...
      ['at ' strrep(field_info.Swath.DataFields(1).Dims(1).Name,'_','\_'),'=',int2str(lev)]}, ...
      'FontSize',14,'FontWeight','bold');

% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');
scrsz = [1 1 1024 768];

if ishghandle(figure_handle)
  set(figure_handle,'position',scrsz,'PaperPositionMode','auto');
  saveas(figure_handle, ...
  'MYD02HKM.A2010031.0035.005.2010031183706_EV_500_RefSB_at_Band_500M.m.p.jpg');
end


