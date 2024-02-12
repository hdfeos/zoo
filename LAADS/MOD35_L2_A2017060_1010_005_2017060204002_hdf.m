%
%  This example code illustrates how to access and visualize MOD35 L2 file
% and convert it into GeoTIFF in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%                                   
% Usage:save this script and run (without .m at the end)
%                                   
% $matlab -nosplash -nodesktop -r MOD35_L2_A2017060_1010_005_2017060204002_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2017-4-6

% MOD35_L2 product uses swath dimension maps.
% You need to dowload and use a separate geo-location file.
GEO_FILE_NAME='MOD03.A2017060.1010.005.2017060201617.hdf'
GEO_SWATH_NAME='MODIS_Swath_Type_GEO';

file_id = hdfsw('open', GEO_FILE_NAME, 'rdonly');
swath_id = hdfsw('attach', file_id, GEO_SWATH_NAME);

% Read lat and lon from MOD03 HDF file.
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

hdfsw('detach', swath_id);
hdfsw('close', file_id);

lat=double(lat);
lon=double(lon);

% Read cloud mask from MOD35_L2.
FILE_NAME='MOD35_L2.A2017060.1010.005.2017060204002.hdf';
SWATH_NAME='mod35';
DATAFIELD_NAME = 'Cloud_Mask'
file_id = hdfsw('open', FILE_NAME, 'rdonly');
swath_id = hdfsw('attach', file_id, SWATH_NAME);
[cloud_mask, status] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);

% Cloud Mask is 6 x 2030 x 1354. Subset to make it 2D.
data=squeeze(cloud_mask(:,:,1));

% Map to plot the results.
latlim=double([floor(min(min(lat))),ceil(max(max(lat)))]);
lonlim=double([floor(min(min(lon))),ceil(max(max(lon)))]);


% Plot cloudmask.
g = figure('Name', FILE_NAME, 'visible', 'off');
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south', 'MapLatLimit',latlim,'MapLonLimit',lonlim)
coast = load('coast.mat');
surfm(lat, lon, data);
colormap('Jet');
h=colorbar();
plotm(coast.lat,coast.long,'k')
set(get(h, 'title'), 'string', 'None', ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');
title({FILE_NAME; [DATAFIELD_NAME ' at BYTE=0']}, 'Interpreter', 'none', ...
      'FontSize', 12, 'FontWeight','bold');
saveas(g, [FILE_NAME '.m.png']);

% Convert to GeoTIFF.
cellsize = .1;
[Z, refvec] = geoloc2grid(lat, lon, double(data), cellsize);
R = refvecToGeoRasterReference(refvec,size(Z));

% Plot the above geo-referenced vector.
fig2 = figure;
axesm('MapProjection','miller','MapLatLimit',latlim,...
      'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south');
geoshow(Z,R,'DisplayType','texturemap');
colorbar;
caxis([0 0.5]);
hold on;
plotm(coast.lat,coast.long,'k','linewidth',2);

% Save the vector into GeoTIFF.
filename = [FILE_NAME, '.m.tif' ];
geotiffwrite(filename, Z, R);
exit;

