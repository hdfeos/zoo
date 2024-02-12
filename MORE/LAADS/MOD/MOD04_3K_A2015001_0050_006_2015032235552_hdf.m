%
%  This example code illustrates how to access and visualize MOD04_3K L2 file
% and convert it into GeoTIFF in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MOD04_3K_A2015001_0050_006_2015032235552_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2017-8-21
%                                   
% Read wind speed dataset.
FILE_NAME='MOD04_3K.A2015001.0050.006.2015032235552.hdf';
SWATH_NAME='mod04';
DATAFIELD_NAME = 'Wind_Speed_Ncep_Ocean';
file_id = hdfsw('open', FILE_NAME, 'rdonly');
swath_id = hdfsw('attach', file_id, SWATH_NAME);
[data, status] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
                                   
% Read lat and lon.
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], ...
                      []);
hdfsw('detach', swath_id);
hdfsw('close', file_id);

lat=double(lat);
lon=double(lon);

% Read attributes from the data field.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);

% Read fill value from the data field.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Read units from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read scale_factor from the data field.
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

% Read add_offset from the data field.
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

% Read long_name from the data field.
offset_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, offset_index);


% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Replace fill value with NaN.
data(data==fillvalue) = NaN;

% Apply scale and offset.
data = scale*(data-offset);

% Map to plot the results.
latlim=double([floor(min(min(lat))),ceil(max(max(lat)))]);
lonlim=double([floor(min(min(lon))),ceil(max(max(lon)))]);


% Plot wind speed.
g = figure('Name', FILE_NAME, 'visible', 'off');
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south', 'MapLatLimit',latlim,'MapLonLimit',lonlim)
coast = load('coast.mat');
surfm(lat, lon, data);
colormap('Jet');
h=colorbar();
plotm(coast.lat,coast.long,'k');
set(get(h, 'title'), 'string', units, ...
                  'Interpreter', 'none');
title({FILE_NAME; [long_name]}, 'Interpreter', 'none');
saveas(g, [FILE_NAME '.m.png']);
exit;

