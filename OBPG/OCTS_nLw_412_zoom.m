%  This example code illustrates how to access and visualize OBPG
%  OCTS Swath HDF4 file in MATLAB. 
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
% Last updated: 2011-10-31

clear

% Open the HDF4 file.
FILE_NAME='O1996306152450.L2_GAC.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from the  data field.
DATAFIELD_NAME='nLw_412';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert the data to double type for plot
data=double(data);

% Transpose the data
data=data';

% Read long name attribute from the data field.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Read units attribute from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read scale factor attribute from the data field.
scale_index = hdfsd('findattr', sds_id, 'slope');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
scale = double(scale);

% Read offset attribute from the data field.
offset_index = hdfsd('findattr', sds_id, 'intercept');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = double(offset);

% Terminate access to the data set.
hdfsd('endaccess', sds_id);

% Read lat information from the data field.
DATAFIELD_NAME='latitude';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[nlat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert the data to double type for plot.
nlat=double(nlat);

% Transpose the lat.
nlat=nlat';

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Read lon information from the data field.
DATAFIELD_NAME='longitude';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[nlon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert the data to double type for plot.
nlon=double(nlon);

% Transpose the lon.
nlon=nlon';

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% We need to interpolate lat and lon to match the size of data.
[numlat, numlon] = size(data);
numCol = size(nlat,2);
step1 = 8;
step2 = 7;

for i = 1 : numlat
    for j = 1 : numCol
        if(j==1)
            lat(i,j) = nlat(i,j);
            lon(i,j) = nlon(i,j);
            continue;
        end
        
        if(j>=2 && j<=numCol-1)
            count = step1*(j-2)+1;
            arr_fill = linspace(nlat(i,j-1), nlat(i,j), step1+1);
            lat(i, count+1:count+step1) = arr_fill(2:step1+1);
            arr_fill = linspace(nlon(i,j-1), nlon(i,j), step1+1);
            lon(i, count+1:count+step1) = arr_fill(2:step1+1);
            continue;
        end
        
        if(j == numCol)
            count = step1*(j-2) + 1;
            arr_fill = linspace(nlat(i,j-1), nlat(i,j), step2+1);
            lat(i, count+1:count+step2) = arr_fill(2:step2+1);
            arr_fill = linspace(nlon(i,j-1), nlon(i,j), step2+1);
            lon(i, count+1:count+step2) = arr_fill(2:step2+1);
            continue;
        end
    end
end

% Replace the fill value with NaN.
data(data==0) = NaN;

% Multiply scale and add offset.
data = data*scale + offset ;

% Plot the data using surfm(or contourfm) and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');

% Set the limits for zoomed image.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
axesm('MapProjection','eqdcylin','Frame','on','Grid','on',...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

% surfm is faster than contourfm.
% contourfm(lat,lon,data);
surfm(lat,lon,data);
plotm(coast.lat,coast.long,'k')

% Put colorbar.
% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
min_data=min(min(data));
max_data=max(max(data));
granule = (max_data - min_data) / ntickmarks;
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:granule:max_data);

% Set unit's title.
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 10, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title with an extra blank line to avoid overlap with unit title..
tstring = {FILE_NAME; long_name; ' '};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');

% Save the figure as JPEG image.
% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f,'O1996306152450.L2_GAC_nLw_412_zoom.m.jpg');
exit;

