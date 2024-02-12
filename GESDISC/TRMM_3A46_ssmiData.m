%  This example code illustrates how to access and visualize
% GESDISC_TRMM file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the HDF-EOS
% Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the 
%  HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Open the HDF4 File.
FILE_NAME='3A46.080101.2.HDF';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from a data field.
DATAFIELD_NAME='ssmiData';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

[name, rank, dimsizes, data_type, nattrs, status] = hdfsd('getinfo', sds_id);

[m, n] = size(dimsizes);

[data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert 3-D data to 2-D data.
data=squeeze(data1(:,:,1));
data=data';

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the input file.
hdfsd('end', SD_id);

% The lat and lon should be calculated manually.
% More information can be found in [1].
lat = 89.5 : -1 : -89.5;
lon = 0.5 : 1 : 359.5;


% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace the fill value with NaN.
fillvalue = data(1,1);
data(data == fillvalue) = NaN;

% Plot the data using surfacem and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f = figure('Name','3A46.080101.2_ssmiData', 'visible','off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on',  ...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');


surfacem(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:0.2:max_data);

plotm(coast.lat,coast.long,'k')



title({FILE_NAME; [DATAFIELD_NAME]}, 'Interpreter', 'None', ...
      'FontSize',16,'FontWeight','bold');

units = 'mm/hr';
set (get(h, 'title'), 'string', units, 'FontSize',16,'FontWeight', ...
                   'bold');

% Save image in JPEG.
scrsz = get(0,'ScreenSize');
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f,'3A46.080101.2_ssmiData.m.jpg');

% References
% [1] http://disc.sci.gsfc.nasa.gov/precipitation/documentation/TRMM_README/TRMM_3A46_readme.shtml
