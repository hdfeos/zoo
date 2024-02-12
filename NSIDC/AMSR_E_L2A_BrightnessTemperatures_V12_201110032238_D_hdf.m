%
%  This example code illustrates how to access and visualize NSIDC
%  AMSR_E version 3 L2A HDF-EOS2 Swath file in MATLAB.
%
%  If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS  Comprehensive Examples 
% page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum 
% (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r AMSR_E_L2A_BrightnessTemperatures_V12_201110032238_D_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-9-21

FILE_NAME='AMSR_E_L2A_BrightnessTemperatures_V12_201110032238_D.hdf';
SWATH_NAME='High_Res_B_Swath';

% Open the HDF-EOS2 Swath file.

file_id = hdfsw('open', FILE_NAME, 'rdonly');

% Open the swath.
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Read data from a data field.
DATAFIELD_NAME='89.0V_Res.5B_TB_(not-resampled)';

[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

% Detach from the swath object.
hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Read attributes from the data field.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='89.0V_Res.5B_TB_(not-resampled)';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

% Read units from the data field.
units_index = hdfsd('findattr', sds_id, 'UNIT');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read scale_factor from the data field.
scale_index = hdfsd('findattr', sds_id, 'SCALE FACTOR');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

% Read add_offset from the data field.
offset_index = hdfsd('findattr', sds_id, 'OFFSET');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

offset = double(offset);
scale = double(scale);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Copy the data for type conversion.
data=data1;

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace the fill value with NaN.
data(data==-32768) = NaN;

% Multiply scale and add offset.
data = data*scale + offset ;

% Set the limits for the plot.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f = figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], 'visible', 'off');

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'MapLatLimit',latlim, 'MapLonLimit',lonlim, ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');
surfm(lat, lon, data);
colormap('Jet');
h = colorbar();
plotm(coast.lat,coast.long,'k');
tightmap;

title({FILE_NAME;'89.0V Res.5B TB (not-resampled)'}, 'Interpreter', 'None', ...
    'FontSize',12,'FontWeight','bold');

set (get(h, 'title'), 'string', units, 'Interpreter', 'None', ...
                   'FontSize',12,'FontWeight','bold');

saveas(f,[FILE_NAME '.m.png']);
exit;
