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

DATAFIELD_NAME='CMG 0.05 Deg Monthly EVI';

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
DATAFIELD_NAME='CMG 0.05 Deg Monthly EVI';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

%Reading filledValue from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

%Reading units from the data field
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

%Reading scale_factor from the data field
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);

%Reading add_offset from the data field
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%Multiplying scale and adding offset, the equation is scale *(data-offset).
data = scale * (data - offset) ;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


h=figure('Name','MOD13C2.A2007001.005.2007108072029_CMG_0.05_Deg_Monthly_EVI','visible','off')

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:5e6:max_data);

plotm(coast.lat,coast.long,'k')

title(['MOD13C2.A2007001.005.2007108072029\_CMG\_0.05\_Deg\_Monthly\_EVI, units: ',units],'FontSize',16,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(h,'position',scrsz,'PaperPositionMode','auto');

saveas(h,'MOD13C2.A2007001.005.2007108072029_CMG_0.05_Deg_Monthly_EVI.jpg');

