% This example code illustrates how to access and visualize NSIDC_AMSR Grid file in Matlab. 
% If you have any questions, suggestions, comments  on this example, please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% If you would like to see an  example of any other NASA HDF/HDF-EOS data product that is not listed in the HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Opening the HDF-EOS2 Grid File
  FILE_NAME = 'AMSR_E_L3_SeaIce6km_V11_20050118.hdf';
  file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Reading Data from a Data Field
  GRID_NAME = 'NpPolarGrid06km';
  grid_id = hdfgd('attach', file_id, GRID_NAME);

  DATAFIELD_NAME = 'SI_06km_NH_89V_DAY';

  [data1, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

% Convert M-D data to 2-D data
  data = data1;

% Convert the data to double type for plot
  data = double(data);

% Transpose the data to match the map projection
  data = data';

% This file contains coordinate variables that will not properly plot. 
% To properly display the data, the latitude/longitude must be remapped.

  [xdimsize, ydimsize, upleft, lowright, status] = hdfgd('gridinfo', grid_id);

% Detaching from the Grid Object
  hdfgd('detach', grid_id);

% Closing the File
  hdfgd('close', file_id);

% The file contains PS projection. We need to use eosdump to generate 1D lat and lon
% and then convert them to 2D lat and lon accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this URL http://hdfeos.org/zoo/note_non_geographic.php

  lat1D = load('lat_AMSR_E_L3_SeaIce6km_V11_20050118_NpPolarGrid06km.output');
  lon1D = load('lon_AMSR_E_L3_SeaIce6km_V11_20050118_NpPolarGrid06km.output');

% lat = zeros(ydimsize, xdimsize);
% lon = zeros(ydimsize, xdimsize);

  lat = reshape(lat1D, xdimsize, ydimsize);
  lon = reshape(lon1D, xdimsize, ydimsize);

  clear lat1D lon1D;

  lat = lat';
  lon = lon';

% Replacing the filled value with NaN
  data(data==0) = NaN;

% Multiply scale by 0.1 to get Kelvin according to 
% http://nsidc.org/data/docs/daac/ae_si6_6km_tbs.gd.html#2
  data = data * 0.1;

% Plot the data using contourfm and axesm
  pole = [90 0 0];
  latlim = [floor(min(min(lat))),ceil(max(max(lat)))];
  lonlim = [floor(min(min(lon))),ceil(max(max(lon)))];
  min_data = floor(min(min(data)));
  max_data = ceil(max(max(data)));

  f = figure('Name','AMSR_E_L3_SeaIce6km_V11_20050118_SI_06km_NH_89V_DAY','visible','off')

  axesm('MapProjection','stereo','MapLatLimit',latlim,'MapLonLimit',lonlim,'Origin',pole,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel','south')
  coast = load('coast.mat');

  surfacem(lat,lon,data);
  colormap('Jet');
  caxis([min_data max_data]); 
  h = colorbar('YTick', min_data:10:max_data);

  plotm(coast.lat,coast.long,'k')

  title({FILE_NAME; 'SI 06km NH 89V DAY'}, 'Interpreter', 'None', ...
      'FontSize',16,'FontWeight','bold');

  set (get(h, 'title'), 'string', 'Kelvin', 'FontSize',12,'FontWeight','bold');

  scrsz = get(0,'ScreenSize');
  set(f,'position',scrsz,'PaperPositionMode','auto');

  saveas(f,'AMSR_E_L3_SeaIce6km_V11_20050118_SI_06km_NH_89V_DAY.m.jpg');