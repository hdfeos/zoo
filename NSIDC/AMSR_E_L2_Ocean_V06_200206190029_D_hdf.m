%
%  This example code illustrates how to access and visualize NSIDC
%  AMSR_E Ocean  L2 HDF-EOS2 Swath file in MATLAB.
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
%  $matlab -nosplash -nodesktop -r AMSR_E_L2_Ocean_V06_200206190029_D_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-9-24


FILE_NAME='AMSR_E_L2_Ocean_V06_200206190029_D.hdf';
SWATH_NAME='Swath1';

% Open the HDF-EOS2 file.
file_id = hdfsw('open', FILE_NAME, 'rdonly');

% Open swath.
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Read dataset.
DATAFIELD_NAME='High_res_cloud';

[data, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);


% Detach swath object.
hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Read attributes from the data field.
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='High_res_cloud';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

% Read units from the data field.
units_index = hdfsd('findattr', sds_id, 'Unit');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read scale_factor from the data field.
scale_index = hdfsd('findattr', sds_id, 'Scale');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
scale = double(scale);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Replace the fill value with NaN.
data(data==-9990) = NaN;

% Multiply scale.
data = data*scale;

f = figure('Name', FILE_NAME, 'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], 'visible', 'off');

axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

surfm(lat, lon, data);
colormap('Jet');
h=colorbar();

plotm(coast.lat,coast.long,'k');
tightmap;

title({FILE_NAME;'High res cloud'}, 'Interpreter', 'None', ...
    'FontSize',12,'FontWeight','bold');

set (get(h, 'title'), 'string', units, 'Interpreter', 'None', ...
                   'FontSize',12,'FontWeight','bold');

saveas(f,[FILE_NAME '.m.png']);
exit;


