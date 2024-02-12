%This example code illustrates how to access and visualize LaRC_MISR Grid file in Matlab. 
%If you have any questions, suggestions, comments on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Grid File
FILE_NAME='MISR_AM1_CGAL_2005_F06_0012.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
GRID_NAME='AlbedoAverage_1_degree';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='Local albedo average - 1 deg';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

%Convert M-D data to 2-D data
data=squeeze(data1(5,:,:));

%Convert the data to double type for plot
data=double(data);

%Transpose the data to match the map projection
data=data';

%Get information about the spatial extents of the grid.
[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

%We need to readjust the limits of latitude and longitude. HDF-EOS is using DMS(DDDMMMSSS.SS) format to represent degrees.
%So to calculate the lat and lon in degree, one needs to convert minutes and seconds into degrees. 

%The following is the detailed description on how to calculate the latitude and longitude range based on lowright and upleft.
%One should observe the fact that 1 minute is 60 seconds and 1 degree is 60 minutes. 

%First calculate the difference of .SS between lowright and upleft:
lowright_ss= lowright*100-floor(lowright)*100;
upleft_ss = upleft*100-floor(upleft)*100;
dss = lowright_ss - upleft_ss;

%Then calculate the difference of SSS between lowright and upleft:
lowright_s = mod(floor(lowright),1000);
upleft_s = mod(floor(upleft),1000);

ds =lowright_s - upleft_s +dss/100;

%Then calculate the difference of MMM between lowright and upleft:

lowright_m = mod(floor(lowright/1000),1000);
upleft_m = mod(floor(upleft/1000),1000);

dm = lowright_m-upleft_m +ds/60;

%Then calculate the difference of DDD between lowright and upleft:
lowright_d = floor(lowright/1000000);
upleft_d = floor(upleft/1000000);
dd = lowright_d-upleft_d+dm/60;

lat_limit = dd(2);
lon_limit = dd(1);

%We need to calculate the grid space interval between two adjacent points

scaleX = lon_limit/xdimsize;
scaleY = lat_limit/ydimsize;

%By default HDFE_CENTER is assumed for the offset value, which assigns 0.5 to both offsetX and offsetY.
offsetX = 0.5;
offsetY = 0.5;

%Since this grid is using geographic projection, the latitude and longitude value will be calculated based on the formula:
% (i+offsetX)*scaleX+leftX  for longitude and (i+offsetY)*scaleY+leftY for latitude.


for i = 0:(xdimsize-1)
  lon_value(i+1) = (i+offsetX)*(scaleX) + upleft_d(1);
end

for j = 0:(ydimsize-1)
  lat_value(j+1) = (j+offsetY)*(scaleY) + upleft_d(2);
end

%Convert the data to double type for plot
lon=double(lon_value);
lat=double(lat_value);

%Read fillvalue from the data
[fillvalue,status] = hdfgd('getfillvalue',grid_id, DATAFIELD_NAME);

%Detaching from the Grid Object
hdfgd('detach', grid_id);
%Closing the File
hdfgd('close', file_id);

%Replacing the filled value with NaN
data(data==fillvalue) = NaN;

%The Local albedo average - 1 deg should be less than 1
data(data>1) = NaN;

%Plot the data using contourfm and axesm
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


figure('Name','MISR_AM1_CGAL_2005_F06_0012_Local_albedo_average_1_deg_Band4')

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', 'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

contourfm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:0.1:max_data);

plotm(coast.lat,coast.long,'k')

title({'MISR\_AM1\_CGAL\_2005\_F06\_0012\_Local\_albedo\_average\_1\_deg'; 'at Band=4'},'FontSize',16,'FontWeight','bold');
