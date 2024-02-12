% This example code illustrates how to access and visualize GESDISC_AIRS Grid in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum 
% (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed 
% in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Open the HDF-EOS2 Swath File.
FILE_NAME='AIRS.2002.12.31.001.L2.CC_H.v4.0.21.0.G06100185050.hdf';
SWATH_NAME='L2_Standard_cloud-cleared_radiance_product';

file_id = hdfsw('open', FILE_NAME, 'rdonly');
swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Read data from a data field.
DATAFIELD_NAME='radiances';
[data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);
[lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
[lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

% Convert 3D data to 2D data.
data=squeeze(data1(568,:,:));

% Replace the filled value with NaN.
data(data==-9999) = NaN;

% Detach from the Swath object and close the file.
hdfsw('detach', swath_id);
hdfsw('close', file_id);

% Plot the data using surfacem() and axesm().
pole=[-90 0 0];
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f = figure('Name','AIRS.2002.12.31.001.L2.CC_H.v4.0.21.0.G06100185050_radiances_channel567','visible','off');
axesm('MapProjection','stereo','MapLatLimit',latlim,...
      'Origin',pole,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on');

coast = load('coast.mat');

surfacem(double(lat),double(lon),double(data));

colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:4:max_data);

plotm(coast.lat,coast.long,'k')

% See page 101 of "AIRS Version 5.0 Released Files Description" document [1]
% for unit specification.
units = 'mW/m**2/cm**-1/sr';


title({FILE_NAME; [DATAFIELD_NAME ' at channel=567']}, ...
      'Interpreter', 'None','FontSize',16,'FontWeight','bold');

set (get(h, 'title'), 'string', units, 'FontSize',16,'FontWeight','bold');

scrsz = get(0,'ScreenSize');
set(f,'position',scrsz,'PaperPositionMode','auto');

saveas(f, ...
       ['AIRS.2002.12.31.001.L2.CC_H.v4.0.21.0' ...
        '.G06100185050_radiances_Channel567.m.jpg']);

% References
% [1] http://disc.sci.gsfc.nasa.gov/AIRS/documentation/v5_docs/AIRS_V5_Release_User_Docs/V5_Released_ProcFileDesc.pdf