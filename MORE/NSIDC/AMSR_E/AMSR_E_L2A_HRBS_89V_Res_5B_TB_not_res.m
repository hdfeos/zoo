%This example code illustrates how to access and visualize NSIDC_AMSR Swath file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
FILE_NAME='AMSR_E_L2A_BrightnessTemperatures_V10_200501180027_D.hdf';
SWATH_NAME='High_Res_B_Swath';

%Opening the HDF-EOS2 Swath File
file_id = hdfsw('open', FILE_NAME, 'rdonly');
%Open swath
swath_id = hdfsw('attach', file_id, SWATH_NAME);

%Reading Data from a Data Field
DATAFIELD_NAME='89.0V_Res.5B_TB_(not-resampled)';

[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

%Detaching from the Swath Object
hdfsw('detach', swath_id);
hdfsw('close', file_id);

%Reading attributes from the data field
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='89.0V_Res.5B_TB_(not-resampled)';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

%Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'UNIT');
[units, status] = hdfsd('readattr',sds_id, units_index);

%Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'SCALE FACTOR');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

%Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'OFFSET');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

offset = double(offset);
scale = double(scale);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Convert M-D data to 2-D data
data=data1;

%Convert the data to double type for plot
data=double(data);
lon=double(lon);
lat=double(lat);

%Replacing the filled value with NaN
data(data==-32768) = NaN;

%Multiplying scale and adding offset
data = data*scale + offset ;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f=figure('Name','AMSR_E_L2A_BrightnessTemperatures_V10_200501180027_D_89.0V_Res.5B_TB_not_resampled','visible','off')

axesm('MapProjection','eqdcylin','MapLatLimit',latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');


surfacem(lat, lon, data);
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:20:max_data);

plotm(coast.lat,coast.long,'k')

% title(['AMSR\_E\_L2A\_BrightnessTemperatures\_V10\_200501180027\_D\_89.0V\_Res.5B\_TB\_not\_resampled, units: ',units],'FontSize',16,'FontWeight','bold');
title({FILE_NAME;'89.0V Res.5B TB (not-resampled)'}, 'Interpreter', 'None', ...
    'FontSize',12,'FontWeight','bold');

set (get(h, 'title'), 'string', units, 'Interpreter', 'None', 'FontSize',12,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f,'AMSR_E_L2A_BrightnessTemperatures_V10_200501180027_D_89.0V_Res.5B_TB_not_resampled.m.jpg');