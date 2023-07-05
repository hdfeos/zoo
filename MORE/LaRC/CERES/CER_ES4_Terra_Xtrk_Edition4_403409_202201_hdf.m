%
%    This example code illustrates how to access and visualize LaRC
%  CERES ES4 Terra HDF4 file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this
%  example, please use the HDF-EOS Forum
%  (http://hdfeos.org/forums). 
%
%    If you would like to see an  example of any other NASA
%  HDF/HDF-EOS data product that is not listed in the HDF-EOS
%  Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org  or
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r CER_ES4_Terra_Xtrk_Edition4_403409_202201_hdf
%
% Tested under: MATLAB R2023a
% Last updated: 2023-07-05

import matlab.io.hdf4.*

FILE_NAME='CER_ES4_Terra-Xtrk_Edition4_403409.202201.hdf';
VG_NAME = '2.5 Degree Regional';
VG2_NAME = 'Monthly (Day) Averages';
VG3_NAME = 'Total-Sky';
DATAFIELD_NAME='Longwave flux';


%  This product requires Vgroup handling because 
% there are multple datasets with same SDS names under different Vgroups.

% Open Vgroup.
file_id = hdfh('open', FILE_NAME, 'DFACC_READ', 0);
status = hdfv('start', file_id);
vgroup_ref = hdfv('find', file_id, VG_NAME);
vgroup_id = hdfv('attach', file_id, vgroup_ref, 'r');
maxsize = hdfv('ntagrefs', vgroup_id);
[tag, refs, count] = hdfv('gettagrefs', vgroup_id, maxsize);

for n = 1:count
  status = hdfv('isvg', vgroup_id, refs(n));
  if status == 1
    vg2_id = hdfv('attach', file_id, refs(n), 'r');
    [vg2_name, status] = hdfv('getname', vg2_id);
    if vg2_name == VG2_NAME
       break;
    end
  end
end

% Open Vgroup2.
maxsize = hdfv('ntagrefs', vg2_id);
[tag, refs, count] = hdfv('gettagrefs', vg2_id, maxsize);
for n = 1:count
  status = hdfv('isvg', vg2_id, refs(n));
  if status == 1
    vg3_id = hdfv('attach', file_id, refs(n), 'r');
    [vg3_name, status] = hdfv('getname', vg3_id);
    if vg3_name == VG3_NAME
       break;
    end
  end
end

% Open Vgroup3.
maxsize = hdfv('ntagrefs', vg3_id);
[tag, refs, count] = hdfv('gettagrefs', vg3_id, maxsize);

% Read datasets.
SD_id = sd.start(FILE_NAME, 'rdonly');
for n = 1:count
  sds_index = sd.refToIndex(SD_id, refs(n));
  sds_id = sd.select(SD_id, sds_index);
  [name, dims, datatype, nattrs] = sd.getInfo(sds_id);

  if strcmp(name, DATAFIELD_NAME)
    data = sd.readData(sds_id);

    fillvalue_index = sd.findAttr(sds_id, '_FillValue');
    fillvalue = sd.readAttr(sds_id, fillvalue_index);

    long_name_index = sd.findAttr(sds_id, 'long_name');
    long_name = sd.readAttr(sds_id, long_name_index);

    units_index = sd.findAttr(sds_id, 'units');
    units = sd.readAttr(sds_id, units_index);
  end 

  if strcmp(name, 'Colatitude')
     colat = sd.readData(sds_id);
  end

  if strcmp(name, 'Longitude')
     lon = sd.readData(sds_id);
  end

  % Terminate access to the corresponding data set.
  sd.endAccess(sds_id);
end
status = hdfv('detach', vg3_id);
status = hdfv('detach', vg2_id);
status = hdfv('detach', vgroup_id);
status = hdfv('end', file_id);
hdfh('close', file_id);

% Close the file.
sd.close(SD_id);

% Convert the data to double type for plot.
data = double(data);
lon = double(lon);
colat = double(colat);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;
colat(data==fillvalue) = NaN;
lon(data==fillvalue) = NaN;

% Convert colat to lat.
lat = 90 - colat;

% Plot the data using surfm and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');
axesm('MapProjection','eqdcylin', ...
      'maplonlimit', [0 360], ... % lon is 0 to 360 [1].
      'Frame','on','Grid','on', ...
      'FontSize', 8, ...
      'MeridianLabel','on','ParallelLabel','on',...
      'MLabelParallel','south');
surfm(lat, lon, data);

coast = load('coastlines.mat');
plotm(coast.coastlat, coast.coastlon,'k');

% Put color bar.
colormap('Jet');
h=colorbar();

% Set unit.
ylabel(h, units)
tightmap;

% Put title. 
tstring = {FILE_NAME; [DATAFIELD_NAME ' (' long_name ')']};
title(tstring, 'Interpreter', 'none', 'FontSize', 10, ...
      'FontWeight','bold');
saveas(f,[FILE_NAME '.m.png']);
exit;


% Reference
%
% [1] https://www.mathworks.com/matlabcentral/answers/9640-using-worldmap-in-0-to-360-longitude
