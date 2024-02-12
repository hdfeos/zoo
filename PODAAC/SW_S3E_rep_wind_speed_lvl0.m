%  This example code illustrates how to access and visualize PO.DAAC
%  SeaWinds Grid HDF4 file in MATLAB. 
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
FILE_NAME='SW_S3E_2003100.20053531923.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read data from the data field.
DATAFIELD_NAME='rep_wind_speed';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Read long name attribute from the data field.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr', sds_id, long_name_index);

% Read units attribute from the data field.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read valid range from the data field.
validrange_index = hdfsd('findattr', sds_id, 'valid_range');
[validrange, status] = hdfsd('readattr',sds_id, validrange_index);
validrange=double(validrange);

% Read scale factor from the data field.
scale_index = hdfsd('findattr', sds_id, 'scale_factor');
[scale, status] = hdfsd('readattr',sds_id, scale_index);
scale = double(scale);

% Read offset from the data field.
offset_index = hdfsd('findattr', sds_id, 'add_offset');
[offset, status] = hdfsd('readattr',sds_id, offset_index);
offset = double(offset);

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

% Convert 3-D data to 2-D data.
data=squeeze(data1(1,:,:));

% Transpose the data to match the map projection.
data=data';

% Calculate lat and lon according to [1]
[latdim, londim] = size(data);
for i=1:latdim
    lat(i)=(180./latdim)*(i-1+0.5)-90;
end
for j=1:londim
    lon(j)=(360./londim)*(j-1+0.5);
end

% Convert the data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Replace the fill value with NaN.
data(data == 0) = NaN;

% Replace out of range values with NaN.
data(data > validrange(2)) = NaN;
data(data < validrange(1)) = NaN;

% Multiply scale and add offset.
data = data*scale + offset ;

% Plot the data using surfm(or contourfm) and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');

axesm('MapProjection','eqdcylin','Frame','on','Grid','on',...
      'MeridianLabel','on','ParallelLabel','on')
coast = load('coast.mat');

% surfm is faster than contourfm.
%contourfm(lat,lon,data);
surfm(lat,lon,data);
plotm(coast.lat,coast.long,'k')

% Put colorbar.
colormap('Jet');
h = colorbar();

% Set unit's title.
set(get(h, 'title'), 'string', units, ...
                  'FontSize', 16, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Put title.
tstring = {FILE_NAME; [long_name ' at Pass=0']};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, 'FontWeight','bold');

% Save the figure as JPEG image.
% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f,'SW_S3E_2003100.20053531923_rep_wind_speed_Pass0.m.jpg');
exit;


% References
% [1] ftp://podaac.jpl.nasa.gov/ocean_wind/seawinds/L3/doc/SWS_L3.pdf