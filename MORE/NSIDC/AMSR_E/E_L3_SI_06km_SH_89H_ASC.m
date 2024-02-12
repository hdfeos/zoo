%This example code illustrates how to access and visualize NSIDC_AMSR Grid file in Matlab. 
%If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
%If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
%feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear
%Opening the HDF-EOS2 Grid File
FILE_NAME='AMSR_E_L3_SeaIce6km_V11_20050118.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

%Reading Data from a Data Field
GRID_NAME='SpPolarGrid06km';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='SI_06km_SH_89H_ASC';

[data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

%Convert M-D data to 2-D data
data=data1;

%Convert the data to double type for plot
data=double(data);

%Transpose the data to match the map projection
data=data';

% This file contains coordinate variables that will not properly plot. 
% To properly display the data, the latitude/longitude must be remapped.

[xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

%Detaching from the Grid Object
hdfgd('detach', grid_id);
%Closing the File
hdfgd('close', file_id);

% The file contains SINSOID projection. We need to use eosdump to generate 1D lat and lon
% and then convert them to 2D lat and lon accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL http://hdfeos.org/zoo/note_non_geographic.php

lat1D = load('lat_AMSR_E_L3_SeaIce6km_V11_20050118_SpPolarGrid06km.output');
lon1D = load('lon_AMSR_E_L3_SeaIce6km_V11_20050118_SpPolarGrid06km.output');

% lat = zeros(ydimsize, xdimsize);
% lon = zeros(ydimsize, xdimsize);

lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

%Replacing the filled value with NaN
data(data==0) = NaN;

%Plot the data using contourfm and axesm
pole=[-90 0 0];
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));


h=figure('Name','AMSR_E_L3_SeaIce6km_V11_20050118_SI_06km_SH_89H_ASC','visible','off')

axesm('MapProjection','stereo','MapLatLimit',latlim,'MapLonLimit',lonlim,'Origin',pole,'Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

contourm(lat,lon,data);
colormap('Jet');
caxis([min_data max_data]); 
colorbar('YTick', min_data:100:max_data);

plotm(coast.lat,coast.long,'k')

title('AMSR\_E\_L3\_SeaIce6km\_V11\_20050118\_SI\_06km\_SH\_89H\_ASC','FontSize',16,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(h,'position',scrsz,'PaperPositionMode','auto');

saveas(h,'AMSR_E_L3_SeaIce6km_V11_20050118_SI_06km_SH_89H_ASC.jpg');
