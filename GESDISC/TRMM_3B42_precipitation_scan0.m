% This example code illustrates how to access and visualize GESDISC_TRMM file in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use the HDF-EOS 
% Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not 
% listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to 
% contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

  clear

% Opening the HDF4 File
  file_name='3B42.100331.21.6A.HDF';
  SD_id = hdfsd('start',file_name, 'rdonly');

% Reading Data from a Data Field
  datafield_name='precipitation';

  sds_index = hdfsd('nametoindex', SD_id, datafield_name);

  sds_id = hdfsd('select',SD_id, sds_index);

  [name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

  [m, n] = size(dimsizes);

  [data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert M-D data to 2-D data
  data=data1;

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);

% Closing the File
  hdfsd('end', SD_id);

% The lat and lon should be calculated manually.
% More information can be found at:
% http://disc.sci.gsfc.nasa.gov/additional/faq/precipitation_faq.shtml#lat_lon

  lat = -49.875 : 0.25 : 49.875;
  lon = -179.875 : 0.25 : 179.875;

% Convert the data to double type for plot
  data=double(data);
  lon=double(lon);
  lat=double(lat);

% Replacing the filled value 0 with NaN
  data(data == 0) = NaN;

% Plot the data using contourfm and axesm
  latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
  lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
  min_data=floor(min(min(data)));
  max_data=ceil(max(max(data)));

  f=figure('Name','3B42.100331.21.6A_precipitation_scale0','visible','off')

  axesm('MapProjection','eqdcylin','Frame','on','Grid','on',  ...
    'MeridianLabel','on','ParallelLabel','on')
  coast = load('coast.mat');

  surfacem(lat,lon,data);
  colormap('Jet');
  caxis([min_data max_data]); 
  h=colorbar('YTick', min_data:5:max_data);

  plotm(coast.lat,coast.long,'k')

  units = 'mm/hr';

  title({file_name; [datafield_name ' at scan=0']}, 'Interpreter', 'None', 'FontSize',16,'FontWeight','bold');

  set (get(h, 'title'), 'string', units, 'FontSize',16,'FontWeight','bold');

  scrsz = get(0,'ScreenSize');
  set(f,'position',scrsz,'PaperPositionMode','auto');

  saveas(f,'3B42.100331.21.6A_precipitation_scale0.m.jpg');