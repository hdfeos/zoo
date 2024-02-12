%  This example code illustrates how to access and visualize Ocean Productivity
%  net primary production (npp) HDF4 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% Tested under: MATLAB R2011b
% Last updated: 2011-11-17

clear

% Open the HDF4 file.
% This file is downloaded from [1].
FILE_NAME='npp.2010361.hdf';
sd_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from a data field.
DATAFIELD_NAME='npp';
sds_index = hdfsd('nametoindex', sd_id, DATAFIELD_NAME);
sds_id = hdfsd('select',sd_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), ...
                       dimsizes);

% Read units attribute from the data field.
units_index = hdfsd('findattr', sds_id, 'Units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read Hole Value attribute from the data field.
fill_value_index = hdfsd('findattr', sds_id, 'Hole Value');
[fill_value, status] = hdfsd('readattr',sds_id, fill_value_index);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', sd_id);

% Set lat / lon variable based on FAQ [2].
for i=1:2160
 lat(i) = 90 - (180/2160)*((i-1)+0.5);
end

for j=1:4320
 lon(j) = -180 + (360/4320)*((j-1)+0.5);
end

% Process fill value.
data(data==fill_value) = NaN;

% The max value goes up to 13K. Limit the value to get a good plot ...
%  like [2].
data(data > 1000) = 1000;

% Convert the data to double type for plot
data=double(data);

%Transpose the data to match the map projection
data=data';


% Plot the data.
f = figure('Name', FILE_NAME, 'visible', 'off');

% Plot the data using axesm, surfm and plotm if mapping toolbox exists.
if isempty(ver('map'))
    warning('Mapping Toolbox not present.')
	pcolor(lon,lat,double(data)); shading flat
else
    coast = load('coast.mat');
    latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
    lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
    axesm('MapProjection','eqdcylin','Frame','on','Grid','on',...
          'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
          'MeridianLabel','on','ParallelLabel','on')
    % You can use contourfm here but surfm is much faster.
    surfm(lat,lon,data);
    plotm(coast.lat,coast.long,'k')
end

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));
granule = (max_data - min_data) / ntickmarks;
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:granule:max_data);

set(get(h, 'title'), 'string', units, ...
                  'FontSize', 16, 'FontWeight','bold');

% See [1] for the meaningful description of data set.
tstring = {FILE_NAME; DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize',16,'FontWeight','bold');

% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f, [FILE_NAME '.m.jpg']);
exit;
% References
% [1] http://orca.science.oregonstate.edu/2160.by.4320.8day.hdf.vgpm.m.chl.m.sst4.php
% [2] http://orca.science.oregonstate.edu/faq01.php
% [3] http://www.science.oregonstate.edu/ocean.productivity/standard.product.php