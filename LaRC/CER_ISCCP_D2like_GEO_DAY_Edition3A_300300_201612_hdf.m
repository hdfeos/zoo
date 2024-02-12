%
%  This example code illustrates how to access and visualize
% LaRC CERES ISCCP D2like GEO Day Edition3A HDF4 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).

% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r CER_ISCCP_D2like_GEO_DAY_Edition3A_300300_201612_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-08-08

% Open the HDF4 file.
FILE_NAME='CER_ISCCP-D2like-GEO_DAY_Edition3A_300300.201612.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read Data from a data field.
DATAFIELD_NAME='Liquid Effective Temperature - Cumulus - M';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert 3-D data to 2-D data at "thin->thick..." dimension = 0.
data=squeeze(data1(:,:,1));

% Convert the data to double type for plot.
data=double(data);

% Traspose data for mapping.
data = data';

% Read fill value attribute.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Read units attribute.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read long_name attribute.
long_name_index = hdfsd('findattr', sds_id, 'long_name');
[long_name, status] = hdfsd('readattr',sds_id, long_name_index);


% Terminate access to the corresponding data field.
hdfsd('endaccess', sds_id);

% Read lat information from a data field.
DATAFIELD_NAME='Colatitude - M';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[colat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert 3-D lat to 1-D lat
colat=squeeze(colat(:,:,1));
colat=squeeze(colat(1,:));

% Convert the lat data to double type for plot.
colat=double(colat);

% Read fill value.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Replac the fill value with NaN.
colat(colat==fillvalue) = NaN;

% Convert colat to lat.
lat = 90 - colat;

% Terminate access to the corresponding data field.
hdfsd('endaccess', sds_id);


% Read lon information from a data field.
DATAFIELD_NAME='Longitude - M';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert 3-D lon to 1-D lon
lon=squeeze(lon(:,:,1));
lon=squeeze(lon(:,1));

% Convert the data to double type for plot.
lon=double(lon);

% Read fill value.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Replace the fill value with NaN.
lon(lon==fillvalue) = NaN;

% If lon > 180, then subtract 360 to make the plot look continuous.
lon(lon>180)=lon(lon>180)-360;

% Terminate access to the corresponding data set.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);

f = figure('Name', FILE_NAME, 'visible', 'off');           

% Plot the data using axesm, surfm and plotm if mapping toolbox exists.
if isempty(ver('map'))
    warning('Mapping Toolbox not present.')
	pcolor(lon,lat,double(data)); shading flat
else
    coast = load('coast.mat');
    latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
    lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
    axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
          'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
          'MeridianLabel','on','ParallelLabel','on');
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

tstring = {FILE_NAME; long_name};
title(tstring, 'Interpreter', 'none', 'FontSize',16,'FontWeight','bold');

scrsz = [1 1 800 600];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f, [FILE_NAME '.m.png']);
exit;

