function Scans = getScan(fmr, sub)
% For scan, currently accepts:
% 'Anatomical' to return    AnatomicalDir,
%                           AnatomicalScan,
%                           Anatomical_DeformationField

% 'Realigned_Funcs' to return realigned functions


startIndex = regexp(sub.inputs.T1,'T1');
Scans.Anatomical.directory = [sub.mriDir '/T1'];
Scans.Anatomical.scan = sub.inputs.T1(startIndex+3:end);
Scans.Anatomical.scanPath = fullfile(Scans.Anatomical.directory, Scans.Anatomical.scan);
Scans.Anatomical.deformationField = [Scans.Anatomical.directory '/y_' Scans.Anatomical.scan];

session = [];
for i = 1:length(fmr.runs)
    Scans.Functional.(fmr.runs{i}).directory = [sub.mriDir '/' fmr.runs{i} '/NonMoCo'];
    Scans.Functional.(fmr.runs{i}).rawScans = grabScans(Scans.Functional.(fmr.runs{i}).directory,'s0*.nii',fmr.runs{i});
    Scans.Functional.(fmr.runs{i}).realignedScans = grabSpecificScans(Scans.Functional.(fmr.runs{i}).directory,'s0*.nii',fmr.runs{i},'a');
    Scans.Functional.(fmr.runs{i}).NormalizedScans = grabSpecificScans(Scans.Functional.(fmr.runs{i}).directory,'s0*.nii',fmr.runs{i},'wa');
    Scans.Functional.(fmr.runs{i}).smoothNormalizedScans = grabSpecificScans(Scans.Functional.(fmr.runs{i}).directory,'s0*.nii',fmr.runs{i},'swa');
    Scans.Functional.(fmr.runs{i}).movementParameters = grabScans(Scans.Functional.(fmr.runs{i}).directory,'rp*.txt',fmr.runs{i});
end
for i = 1:length(fmr.runs)
    if i == 1
        Scans.Functional.rawScans = [Scans.Functional.(fmr.runs{i}).rawScans(:)];
        Scans.Functional.realignedScans = [Scans.Functional.(fmr.runs{i}).realignedScans(:)];
        Scans.Functional.NormalizedScans = [Scans.Functional.(fmr.runs{i}).NormalizedScans(:)];
        Scans.Functional.smoothNormalizedScans = [Scans.Functional.(fmr.runs{i}).smoothNormalizedScans(:)];
    else
        Scans.Functional.rawScans = [Scans.Functional.rawScans;Scans.Functional.(fmr.runs{i}).rawScans(:)];
        Scans.Functional.realignedScans = [Scans.Functional.realignedScans;Scans.Functional.(fmr.runs{i}).realignedScans(:)];
        Scans.Functional.NormalizedScans = [Scans.Functional.NormalizedScans;Scans.Functional.(fmr.runs{i}).NormalizedScans(:)];
        Scans.Functional.smoothNormalizedScans = [Scans.Functional.smoothNormalizedScans;Scans.Functional.(fmr.runs{i}).smoothNormalizedScans(:)];
    end
end
end


function functionals = grabScans(directory,identifier,runs)
cwd=pwd;
session={};
%% Grabbing Scans
cd(directory);
funcFiles = struct2cell(dir(identifier));
tempsession = funcFiles(1,:)';
tempsession2={};
for i = 1:length(tempsession)
    if ~isempty(regexp(tempsession{i}(1:end-4),'\d$'))
        tempsession2 = [tempsession2;tempsession(i)];
    end
end
tempsession = tempsession2;
tempsession = fullfile(directory,tempsession);
if length(tempsession) > 1
    while str2num(tempsession{1}(end-4)) < 3
        tempsession = tempsession(2:end);
    end
end
cd(cwd);
functionals = tempsession;
return
end

function functionals = grabSpecificScans(directory,identifier,runs,specType)
cwd=pwd;
session={};
%% Grabbing Scans
cd(directory);
funcFiles = struct2cell(dir(identifier));
tempsession = funcFiles(1,:)';
tempsession2={};
for i = 1:length(tempsession)
    if ~isempty(regexp(tempsession{i}(1:end-4),'\d$'))
        tempsession2 = [tempsession2;tempsession(i)];
    end
end
tempsession = tempsession2;
tempsession = cellstr([repmat(specType,[length(tempsession),1]) cell2mat(tempsession)]);
tempsession = fullfile(directory,tempsession);
if length(tempsession) > 1
    while str2num(tempsession{1}(end-4)) < 3
        tempsession = tempsession(2:end);
    end
end
cd(cwd);
functionals = tempsession;
return
end