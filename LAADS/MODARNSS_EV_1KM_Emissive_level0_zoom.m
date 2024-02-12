% This example code illustrates how to access and visualize LAADS_MOD file in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Opening File
  FILE_NAME='MODARNSS.Abracos_Hill.A2000080.1515.005.2007164153544.hdf';
  SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Reading Data from a Data Field
  DATAFIELD_NAME='EV_1KM_Emissive';

  sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

  sds_id = hdfsd('select',SD_id, sds_index);

  [name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

  [m, n] = size(dimsizes);

  [data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert M-D data to 2-D data
  data=squeeze(data1(:,:,1));

% Reading filledValue from the data field
  fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
  [fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);

% Reading long_name from the data field
  long_name_index = hdfsd('findattr', sds_id, 'long_name');
  [long_name, status] = hdfsd('readattr',sds_id, long_name_index);

% Reading units from the data field
  units_index = hdfsd('findattr', sds_id, 'radiance_units');
  [units, status] = hdfsd('readattr',sds_id, units_index);

% Reading scale_factor from the data field
  scale_index = hdfsd('findattr', sds_id, 'radiance_scales');
  [scale, status] = hdfsd('readattr',sds_id, scale_index);
% The scale is an array. We need to find the corresponding one.
  scale = scale(1);
  scale = double(scale);

% Reading add_offset from the data field
  offset_index = hdfsd('findattr', sds_id, 'radiance_offsets');
  [offset, status] = hdfsd('readattr',sds_id, offset_index);
  offset = offset(1);
  offset = double(offset);

% Reading valid_range from the data field
  range_index = hdfsd('findattr', sds_id, 'valid_range');
  [range, status] = hdfsd('readattr',sds_id, range_index);

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);

% Reading lat from a Data Field
  DATAFIELD_NAME='Latitude';

  sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

  sds_id = hdfsd('select',SD_id, sds_index);

  [name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

  [m, n] = size(dimsizes);

  [lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);

% Reading lon from a Data Field
  DATAFIELD_NAME='Longitude';

  sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

  sds_id = hdfsd('select',SD_id, sds_index);

  [name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

  [m, n] = size(dimsizes);

  [lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);
% Closing the File
  hdfsd('end', SD_id);

% Convert the data to double type for plot
  data=double(data);
  lon=double(lon);
  lat=double(lat);

% Replacing the filled value with NaN
  data(data==fillvalue) = NaN;
  data(data>range(2)) = NaN;

% Multiplying scale and adding offset, the equation is scale *(data-offset).
  data = scale*(data-offset);

% Plot the data using contourfm and axesm
  latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
  lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
  min_data=floor(min(min(data)));
  max_data=ceil(max(max(data)));

  f = figure('Name','MODARNSS.Abracos_Hill.A2000080.1515.005.2007164153544_EV_1KM_Emissive_Band_1KM_Emissive0','visible','off')

  axesm('MapProjection','eqdcylin','MapLatLimit', latlim, 'MapLonLimit',lonlim, 'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelLocation',lonlim,'PLabelLocation',latlim)
  coast = load('coast.mat');

  surfacem(lat, lon, data);
  colormap('Jet');
  caxis([min(min(data)) max(max(data))]); 
  h = colorbar('YTick', min(min(data)):0.05:max(max(data)));

  plotm(coast.lat,coast.long,'k')

% title({'MODARNSS.Abracos\_Hill.A2000080.1515.005.2007164153544\_EV\_1KM\_Emissive' ; ['at Band\_1KM\_Emissive=0, units: ',units]}, 'FontSize',16,'FontWeight','bold');
  title({FILE_NAME; ['Radiance derived from ' long_name]; 'at Band_1KM_Emissive=0'}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');

  set (get(h, 'title'), 'string', units, 'FontSize',10,'FontWeight','bold');

  scrsz = get(0,'ScreenSize');
  set(f,'position',scrsz,'PaperPositionMode','auto');

  saveas(f,'MODARNSS.Abracos_Hill.A2000080.1515.005.2007164153544_EV_1KM_Emissive_Band_1KM_Emissive0_zoom.m.jpg');