%This example code illustrates how to access and visualize LP_DAAC_MOD Grid file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Grid File
FILE_NAME='MOD13C2.A2007001.005.2007108072029.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
GRID_NAME='MOD_Grid_monthly_CMG_VI';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='CMG 0.05 Deg Monthly NDVI';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

%Convert M-D data to 2-D data
data=data1;

%Convert the data to double type for plot
data=double(data);

%Transpose the data to match the map projection
data=data';

%Detaching from the Grid Object
hdfgd('detach', grid_id);
%Closing the File
hdfgd('close', file_id);

% All the upleft and lowright points are -1. Assume it uses GEO projection.
% We calculate lat and lon manually.

[latdim, londim] = size(data);

for i=1:latdim
    lat(i)=-(180./latdim)*(i-1+0.5)+90;
end

for j=1:londim
    lon(j)=(360./londim)*(j-1+0.5)-180;
end

%Reading attributes from the data field
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='CMG 0.05 Deg Monthly NDVI';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

%Reading filledValue from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

%Reading valid_range from the data field
valid_range_index = hdfsd('findattr', sds_id, 'valid_range');
[valid_range, status] = hdfsd('readattr',sds_id, valid_range_index);

%Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

%Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

% Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

% Reading long_name from the data field
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

% Convert type.
dataf = double(data);

%Replacing the filled value with NaN
dataf(data==fillvalue) = NaN;

%Replacing the out of range values with NaN
dataf(data < valid_range(1)) = NaN;
dataf(data > valid_range(2)) = NaN;

%Multiplying scale and adding offset, the equation is scale *(data-offset).
dataf = (dataf - offset) / scale ;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=min(min(dataf));
max_data=max(max(dataf));

f=figure('Name','MOD13C2.A2007001.005.2007108072029_CMG_0.05_Deg_Monthly_NDVI','visible','off')

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

surfacem(lat,lon,dataf);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:5e6:max_data);

plotm(coast.lat,coast.long,'k')

title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
    'FontSize',12,'FontWeight','bold');

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min_data:granule:max_data);

set (get(h, 'title'), 'string', units, 'FontSize',12,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f,'MOD13C2.A2007001.005.2007108072029_CMG_0.05_Deg_Monthly_NDVI.m.jpg');