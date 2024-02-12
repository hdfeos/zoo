% This example code illustrates how to access and visualize GESDISC_TRMM file in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use the HDF-EOS 
% Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not 
% listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), feel free to 
% contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

  clear

% Opening the HDF4 File
  file_name='2A12.100402.70512.6.HDF';
  SD_id = hdfsd('start',file_name, 'rdonly');

% Reading Data from a Data Field
  datafield_name='cldWater';

  sds_index = hdfsd('nametoindex', SD_id, datafield_name);

  sds_id = hdfsd('select',SD_id, sds_index);

  [name, rank, dimsizes, data_type, nattrs, status] = hdfsd('getinfo', sds_id);

  [m, n] = size(dimsizes);

  [data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert M-D data to 2-D data
  data=squeeze(data1(10,:,:));

% Reading scale_factor from a Data Field
  scale_index = hdfsd('findattr', sds_id, 'scale_factor');
  [scale, status] = hdfsd('readattr',sds_id, scale_index);

% Convert to double type for plot
  scale = double(scale);

% Reading add_offset from a Data Field
  offset_index = hdfsd('findattr', sds_id, 'add_offset');
  [offset, status] = hdfsd('readattr',sds_id, offset_index);
% Convert to double type for plot
  offset = double(offset);

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);

% Reading GEO information from a Data Field
  geo_name='geolocation';

  sds_index = hdfsd('nametoindex', SD_id, geo_name);

  sds_id = hdfsd('select',SD_id, sds_index);

  [name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

  [m, n] = size(dimsizes);

  [geo, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

  lat=squeeze(geo(1,:,:));
  lon=squeeze(geo(2,:,:));

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);
% Closing the File
  hdfsd('end', SD_id);

% Convert the data to double type for plot
  data=double(data);
  lon=double(lon);
  lat=double(lat);

% Replacing the filled value -9999 with NaN
  data(data == -9999) = NaN;

% Multiplying scale and adding offset
  data = data / scale + offset;

% Plot the data using contourfm and axesm
  latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
  lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
  min_data=min(min(data));
  max_data=max(max(data));

  f=figure('Name','2A12.100402.70512.6_cldWater_layer9','visible','off')

  axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on')
  coast = load('coast.mat');

  surfacem(lat,lon,data);
  colormap('Jet');
  caxis([min_data max_data]); 

% Change the value if you want to have more than 10 tick marks.
  ntickmarks = 10;
  granule = (max_data - min_data) / ntickmarks;
  
  h=colorbar('YTick', min_data:granule:max_data);

  plotm(coast.lat,coast.long,'k')

  units = 'g/m^-^3';

  title({file_name; [datafield_name ' at layer=9']}, 'Interpreter', 'None', 'FontSize',16,'FontWeight','bold');

  set (get(h, 'title'), 'string', units, 'FontSize',16,'FontWeight','bold');

  scrsz = get(0,'ScreenSize');
  set(f,'position',scrsz,'PaperPositionMode','auto');

  saveas(f,'2A12.100402.70512.6_cldWater_lvl9.m.jpg');

% References: 
% Range is 0.00 ~ 10.00 with unit g/m(-3).
% See http://disc.sci.gsfc.nasa.gov/precipitation/documentation/TRMM_README/TRMM_2A12_readme.shtml