%This example code illustrates how to access and visualize NSIDC_AMSR Grid file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Grid File
FILE_NAME='AMSR_E_L3_DailyLand_V06_20050118.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
GRID_NAME='Descending_Land_Grid';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='D_TB06.9V (Res 1)';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

%Convert M-D data to 2-D data
data=data1;

%Convert the data to double type for plot
data=double(data);

%Transpose the data to match the map projection
data=data';

% This file contains coordinate variables that will not properly plot. 
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

%Detaching from the Grid Object
hdfgd('detach', grid_id);
%Closing the File
hdfgd('close', file_id);

% The file contains CEA projection. We need to use eosdump to generate 1D lat and lon
% accordingly.

lat1D = load('Latitude_D_TB06_9V_Res_1');
lon1D = load('Longitude_D_TB06_9V_Res_1');

% Since it's CEA projection, the output lat and lon are all 1D data.

lat = lat1D;
lon = lon1D;

clear lat1D lon1D;

lat = lat';
lon = lon';

%Reading attributes from the data field
SD_id = hdfsd('start',FILE_NAME, 'rdonly');
DATAFIELD_NAME='D_TB06.9V (Res 1)';

sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

sds_id = hdfsd('select',SD_id, sds_index);

%Reading filledValue from the data field
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

%Terminate access to the corresponding data set
hdfsd('endaccess', sds_id);
%Closing the File
hdfsd('end', SD_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


figure('Name','AMSR_E_L3_DailyLand_V06_20050118_D_TB06.9V_Res_1')

axesm('MapProjection','eqacylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
coast = load('coast.mat');

contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:200:max_data);

plotm(coast.lat,coast.long,'k')

title('AMSR\_E\_L3\_DailyLand\_V06\_20050118\_D\_TB06.9V\_Res\_1','FontSize',16,'FontWeight','bold');
