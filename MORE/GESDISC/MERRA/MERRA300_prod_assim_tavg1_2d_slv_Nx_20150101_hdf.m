%
%   This example code illustrates how to access and visualize GES DISC MERRA
% HDF-EOS2 Grid file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r MERRA300_prod_assim_tavg1_2d_slv_Nx_20150101_hdf
%
% Tested under: MATLAB R2015a
% Last updated: 2015-05-28

file_name= 'MERRA300.prod.assim.tavg1_2d_slv_Nx.20150101.hdf';
file_id = hdfgd('open', file_name, 'rdonly');
grid_name='EOSGRID';
grid_id = hdfgd('attach', file_id, grid_name);

% datafield_name='U500';
datafield_name='TS';

[data, fail] = hdfgd('readfield', grid_id, datafield_name, [], [], []);
data=squeeze(double(data(:,:,1)));
data=data';
% size(data)

datafield_name='XDim';
[lon, status] = hdfgd('readfield', grid_id, datafield_name, [], [], []);
lon=double(lon);
datafield_name='YDim';
[lat, status] = hdfgd('readfield', grid_id, datafield_name, [], [], []);
lat=double(lat);
hdfgd('detach', grid_id);
hdfgd('close', file_id);
SD_id = hdfsd('start',file_name, 'rdonly');

% datafield_name='U500';
datafield_name='TS';


% size(lat)
% size(lon)
sds_index = hdfsd('nametoindex', SD_id, datafield_name);

sds_id = hdfsd('select',SD_id, sds_index);
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

missingvalue_index = hdfsd('findattr', sds_id, 'missing_value');
[missingvalue, status] = hdfsd('readattr',sds_id, missingvalue_index);

long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

scale = double(scale);
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

offset = double(offset);
hdfsd('endaccess', sds_id);
data(data==fillvalue) = NaN;
data(data==missingvalue) = NaN;
data = data*scale + offset ;
latlim = [floor(min(min(lat))),ceil(max(max(lat)))];
lonlim = [floor(min(min(lon))),ceil(max(max(lon)))];
min_data = floor(min(min(data)));
max_data = ceil(max(max(data)));

f = figure('Name', file_name,'visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

% surfacem(lat,lon,data);
surfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = floor((max_data - min_data) / ntickmarks);

h=colorbar('YTick', min_data:granule:max_data);

plotm(coast.lat,coast.long,'k')

title({file_name; ...
       [long_name  [' at TIME=0']]}, ...
       'Interpreter', 'None', 'FontSize', 16,'FontWeight','bold');

set (get(h, 'title'), 'string', units, 'FontSize', 16,'FontWeight','bold');

% Use the following if your screen isn't too big (> 1024 x 768). 
scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in PNG if
% your screen is too large.
scrsz = [1 1 800 600];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f, [file_name '.m.png']);
exit;