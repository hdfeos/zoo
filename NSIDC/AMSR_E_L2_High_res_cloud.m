%This example code illustrates how to access and visualize NSIDC_AMSR Swath file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
FILE_NAME='AMSR_E_L2_Ocean_V06_200206190029_D.hdf';
SWATH_NAME='Swath1';

%Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
%Open swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

%Reading Data from a Data Field
DATAFIELD_NAME='High_res_cloud';

[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);


%Detaching from the Swath Object
hdfsw('detach', swath_id);
hdfsw('close', file_id);

%Convert M-D data to 2-D data
data=data1;

%Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

%Reading attributes from the data field
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='High_res_cloud';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

%Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'Unit');
[units, status] = hdfsd('readattr',sds_id, units_index);

%Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'Scale');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
scale = double(scale);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Replacing the filled value with NaN
data(data==-9990) = NaN;

%Multiplying scale 
data = data*scale;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f=figure('Name','AMSR_E_L2_Ocean_V06_200206190029_D_High_res_cloud','visible','off')

axesm('MapProjection','eqdcylin','MapLatLimit',latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');


surfacem(lat, lon, data);
colormap('Jet');
caxis([min(min(data)) max(max(data))]); 
h=colorbar('YTick', min(min(data)):0.2:max(max(data)));

plotm(coast.lat,coast.long,'k')

title({FILE_NAME;'High res cloud'}, 'Interpreter', 'None', ...
    'FontSize',12,'FontWeight','bold');

set (get(h, 'title'), 'string', units, 'Interpreter', 'None', 'FontSize',12,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f,'AMSR_E_L2_Ocean_V06_200206190029_D_High_res_cloud.m.jpg');