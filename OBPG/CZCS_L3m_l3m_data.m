%
%  This example code illustrates how to access and visualize OBPG CZCS
% HDF4 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS  Comprehensive Examples 
% page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum 
% (http://hdfeos.org/forums).

  clear

% Opening the HDF4 File
  FILE_NAME='C19860011986008.L3m_8D_CHLO_4.hdf';
  SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Reading Data from a Data Field
  DATAFIELD_NAME='l3m_data';

  sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);

  sds_id = hdfsd('select',SD_id, sds_index);

  [name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);

  [m, n] = size(dimsizes);

  [data1, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Convert M-D data to 2-D data
  data=data1;

% Transpose the data to match the map projection
  data=data';

% Reading filledValue from the data field
  fillvalue = 65535;

% The lat and lon should be calculated using lat and lon of southwest point.
% Then we need number of lines and columns to calculate the lat and lon
% step. Assume even space between lat and lon points to get all lat and lon
% data.

  smlat_index = hdfsd('findattr', SD_id, 'SW Point Latitude');
  [smlat, status] = hdfsd('readattr',SD_id, smlat_index);

  wmlon_index = hdfsd('findattr', SD_id, 'SW Point Longitude');
  [wmlon, status] = hdfsd('readattr',SD_id, wmlon_index);

  nlat_index = hdfsd('findattr', SD_id, 'Number of Lines');
  [nlat, status] = hdfsd('readattr',SD_id, nlat_index);

  nlon_index = hdfsd('findattr', SD_id, 'Number of Columns');
  [nlon, status] = hdfsd('readattr',SD_id, nlon_index);

  latstep_index = hdfsd('findattr', SD_id, 'Latitude Step');
  [latstep, status] = hdfsd('readattr',SD_id, latstep_index);

  lonstep_index = hdfsd('findattr', SD_id, 'Longitude Step');
  [lonstep, status] = hdfsd('readattr',SD_id, lonstep_index);

  smlat = double(smlat); wmlon = double(wmlon); nlat = double(nlat);
  nlon = double(nlon); latstep = double(latstep); lonstep = double(lonstep);

  nmlat = smlat + (nlat-1)*latstep;
  emlon = wmlon + (nlon-1)*lonstep;

  lat = nmlat : (-latstep) : smlat;
  lon = wmlon : (lonstep) : emlon;

% Reading Parameter attribute from file attributes
  long_name_index = hdfsd('findattr', SD_id, 'Parameter');
  [long_name, status] = hdfsd('readattr',SD_id, long_name_index);

% Reading units from file attributes
  units_index = hdfsd('findattr', SD_id, 'Units');
  [units, status] = hdfsd('readattr',SD_id, units_index);

% Reading base_factor from file attributes
  base_index = hdfsd('findattr', sds_id, 'Base');
  [base, status] = hdfsd('readattr',sds_id, base_index);
  base = double(base);

% Reading scale_factor from file attributes
  scale_index = hdfsd('findattr', sds_id, 'Slope');
  [scale, status] = hdfsd('readattr',sds_id, scale_index);
  scale = double(scale);

% Reading add_offset from file attributes
  offset_index = hdfsd('findattr', sds_id, 'Intercept');
  [offset, status] = hdfsd('readattr',sds_id, offset_index);
  offset = double(offset);

% Terminate access to the corresponding data set
  hdfsd('endaccess', sds_id);

% Closing the File
  hdfsd('end', SD_id);

% Convert the data to double type for plot
  data=double(data);
  lon=double(lon);
  lat=double(lat);

% Replacing the filled value with NaN
  data(data == fillvalue) = NaN;

% Multiplying scale and adding offset
  data = base.^(data*scale + offset) ;

% Plot the data using contourfm and axesm
  latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
  lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
  min_data=min(min(data));
  max_data=1.0;

  f=figure('Name','C19860011986008.L3m_8D_CHLO_4_l3m_data','visible','off');

  axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','FontSize',20)
  coast = load('coast.mat');

  surfacem(lat,lon,data);
  colormap('Jet');
  caxis([min_data max_data]); 
  h=colorbar('YTick', min_data:0.15:max_data,'FontSize',20);

  plotm(coast.lat,coast.long,'k')

  title({FILE_NAME; long_name}, 'Interpreter', 'None', 'FontSize',26,'FontWeight','bold');

  set (get(h, 'title'), 'string', units, 'Interpreter', 'None', 'FontSize',26,'FontWeight','bold');

  scrsz = get(0,'ScreenSize');
  set(f,'position',scrsz,'PaperPositionMode','auto');

  saveas(f,'C19860011986008.L3m_8D_CHLO_4_l3m_data.m.jpg');

% Reference
%
% [1] http://oceancolor.gsfc.nasa.gov/ANALYSIS/PROCTEST/cr01_sr051/deep_chlor_a_images.html
% [2] http://www.dfanning.com/documents/programs.html
