% This example code illustrates how to access and visualize LAADS_MOD swath file in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Read data field
  FILE_NAME='MODATML2.A2000055.0000.005.2006253045900.hdf';
  SWATH_NAME='atml2';

% Opening the HDF-EOS2 Swath File
  file_id = hdfsw('open', FILE_NAME, 'rdonly');
% Open swath
  swath_id = hdfsw('attach', file_id, SWATH_NAME);

% Reading Data from a Data Field
  DATAFIELD_NAME='Cloud_Fraction';

  [data1, fail] = hdfsw('readfield', swath_id, DATAFIELD_NAME, [], [], []);

% Reading lat and lon data
  [lon, status] = hdfsw('readfield', swath_id, 'Longitude', [], [], []);
  [lat, status] = hdfsw('readfield', swath_id, 'Latitude', [], [], []);

% Detaching from the Swath Object
  hdfsw('detach', swath_id);
  hdfsw('close', file_id);

% Convert M-D data to 2-D data
  data=data1;

% Convert the data to double type for plot
  data=double(data);
  lon=double(lon);
  lat=double(lat);

% Reading attributes from the data field
  FILE_NAME='MODATML2.A2000055.0000.005.2006253045900.hdf';
  SD_id = hdfsd('start',FILE_NAME, 'rdonly');
  DATAFIELD_NAME='Cloud_Fraction';

  sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

  sds_id = hdfsd('select',SD_id, sds_index);

% Reading filledValue from the data field
  fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
  [fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Reading units from the data field
  units_index = hdfsd('findattr', sds_id, 'units');
  [units, status] = hdfsd('readattr',sds_id, units_index);

% Reading scale_factor from the data field
  scale_index = hdfsd('findattr', sds_id, 'scale_factor');
  [scale, status] = hdfsd('readattr',sds_id, scale_index);
  scale = double(scale);

% Reading add_offset from the data field
  offset_index = hdfsd('findattr', sds_id, 'add_offset');
  [offset, status] = hdfsd('readattr',sds_id, offset_index);
  offset = double(offset);

% Reading long_name from the data field
  long_name_index = hdfsd('findattr', sds_id, 'long_name');
  [long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);

% Reading attributes from the lat
  DATAFIELD_NAME='Latitude';

  sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

  sds_id = hdfsd('select',SD_id, sds_index);

% Reading filledValue from the data field
  fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
  [lat_fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Reading scale_factor from the data field
  scale_index = hdfsd('findattr', sds_id, 'scale_factor');
  [lat_scale, status] = hdfsd('readattr',sds_id, scale_index);
  lat_scale = double(lat_scale);

% Reading add_offset from the data field
  offset_index = hdfsd('findattr', sds_id, 'add_offset');
  [lat_offset, status] = hdfsd('readattr',sds_id, offset_index);
  lat_offset = double(lat_offset);

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);

% Reading attributes from the lon
  DATAFIELD_NAME='Longitude';

  sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

  sds_id = hdfsd('select',SD_id, sds_index);

% Reading filledValue from the data field
  fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
  [lon_fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Reading scale_factor from the data field
  scale_index = hdfsd('findattr', sds_id, 'scale_factor');
  [lon_scale, status] = hdfsd('readattr',sds_id, scale_index);
  lon_scale = double(lon_scale);

% Reading add_offset from the data field
  offset_index = hdfsd('findattr', sds_id, 'add_offset');
  [lon_offset, status] = hdfsd('readattr',sds_id, offset_index);
  lon_offset = double(lon_offset);

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);

% Closing the File
  hdfsd('end', SD_id);

% Replacing the filled value with NaN
  data(data==fillvalue) = NaN;
  lat(lat==lat_fillvalue) = NaN;
  lon(lon==lon_fillvalue) = NaN;

% Multiplying scale and adding offset, the equation is scale *(data-offset).
  data = scale*(data-offset);
  lat = lat_scale*(lat-lat_offset);
  lon = lon_scale*(lon-lon_offset);

% Plot the data using contourfm and axesm
  latlim = [floor(min(min(lat))),ceil(max(max(lat)))];
  lonlim = [floor(min(min(lon))),ceil(max(max(lon)))];
  min_data = floor(min(min(data)));
  max_data = ceil(max(max(data)));

  f = figure('Name','MODATML2.A2000055.0000.005.2006253045900_Cloud_Fraction','visible','off')

  axesm('MapProjection','eqdcylin','MapLatLimit', latlim, 'MapLonLimit',lonlim, 'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on')
  coast = load('coast.mat');

  surfacem(lat, lon, data);
  colormap('Jet');
  caxis([min(min(data)) max(max(data))]); 
  h = colorbar('YTick', min(min(data)):0.01:max(max(data)));

  plotm(coast.lat,coast.long,'k')

  title({FILE_NAME; long_name}, 'Interpreter', 'None', ...
      'FontSize',16,'FontWeight','bold');

  set (get(h, 'title'), 'string', units, 'FontSize',16,'FontWeight','bold');

  scrsz = get(0,'ScreenSize');
  set(f,'position',scrsz,'PaperPositionMode','auto');

  saveas(f,'MODATML2.A2000055.0000.005.2006253045900_Cloud_Fraction_zoom.m.jpg');