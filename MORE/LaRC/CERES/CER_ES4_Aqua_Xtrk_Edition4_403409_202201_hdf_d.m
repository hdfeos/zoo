%
%    This example code illustrates how to access and visualize LaRC
%  CERES ES4 Aqua HDF4 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r CER_ES4_Aqua_Xtrk_Edition4_403409_202201_hdf_d
%
% Tested under: MATLAB R2023a
% Last updated: 2023-07-12

import matlab.io.hdf4.*

FILE_NAME='CER_ES4_Aqua-Xtrk_Edition4_403409.202201.hdf';
VG_NAME = '2.5 Degree Regional';
VG2_NAME = 'Daily Averages';
VG3_NAME = 'Total-Sky';
DATAFIELD_NAME='Longwave flux';

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
    if strcmp(vg2_name, VG2_NAME)
       break;
    else
      hdfv('detach', vg2_id);
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
    if strcmp(vg3_name, VG3_NAME)
       break;
    else
      hdfv('detach', vg3_id);
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

% Close the file.
sd.close(SD_id);

status = hdfv('detach', vg3_id);
status = hdfv('detach', vg2_id);
status = hdfv('detach', vgroup_id);
status = hdfv('end', file_id);
hdfh('close', file_id);

% Convert the data to double type for plot.
data = double(data);
d = size(data);
lon = double(lon);
colat = double(colat);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;
colat(data==fillvalue) = NaN;
lon(data==fillvalue) = NaN;

% Convert colat to lat.
lat = 90 - colat;
s = (lon > 20.0 & lon < 60.0 & lat > 0.0 & lat < 30.0);

for k =1:d(3)
  data_h = squeeze(data(:,:,k));
  data_s = data_h(s);
  writematrix(horzcat(k-1, mean(data_s(:), "omitmissing")), 'out_d.csv', ...
              'WriteMode','append');    
end
 

% Read filtered data to calculate average.
A = readtable('out_d.csv');
B = varfun(@mean, A, 'InputVariables', 2,...
           'GroupingVariables', 1);
% Draw plot.
f = figure('Name', FILE_NAME, ...
           'visible', 'off');
plot(B.Var1, B.mean_Var2);
xtickformat('%d');
xticks(B.Var1);
xlabel('Day');

% Put title.
s = [DATAFIELD_NAME, ' on [0N, 30N] & [20E, 60E]'];
tstring = {FILE_NAME, long_name, s};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

% The following fixed-size screen size will look better in PNG
% if your screen is too large.
scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME, '.d.m.png']);
exit;