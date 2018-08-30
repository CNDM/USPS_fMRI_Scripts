function batch = fmr_Funcprepro(fmr, sub)
%Accepts structure from fMRI_Analysis as input. Called from tbd. 

subID = num2str(sub.subID);

cd(sub.mriDir)

dname = sub.inputs.niftidir;
defaults = spm('defaults','fmri');

%-------------------------------------------------------------------------%
%   slicetiming correction
%-------------------------------------------------------------------------%
nslices = sub.inputs.nslices; %number of slices
TR = 2; %TR

tic;
% Based on Siemens 3T slice acquisition
if mod(nslices,2) == 0 % if nslices is even
    sliceorder = [2:2:nslices 1:2:nslices]; %interleaved, bottom-->top
    refslice = 1; %reference slice - middle acquired slice
else % if nslices is odd
    sliceorder = [1:2:nslices 2:2:nslices];
    refslice = 2; %reference slice - middle acquired slice
end

% Data, # Sessions = # Runs
for i = 1:length(fmr.runs)
    if i == 1
        scans = {sub.Scans.Functional.(fmr.runs{i}).rawScans};
    else
        scans = [scans,{sub.Scans.Functional.(fmr.runs{i}).rawScans}];
    end
end



matlabbatch{1}.spm.temporal.st.scans = scans';
matlabbatch{1}.spm.temporal.st.nslices = nslices;
matlabbatch{1}.spm.temporal.st.tr = TR;
matlabbatch{1}.spm.temporal.st.ta = TR - TR/nslices;
matlabbatch{1}.spm.temporal.st.so = sliceorder;
matlabbatch{1}.spm.temporal.st.refslice = refslice;
matlabbatch{1}.spm.temporal.st.prefix = 'a';


%-------------------------------------------------------------------------%
%   realignment
%-------------------------------------------------------------------------%

% Data, # Sessions = # Runs
for index = 1:size(sub.inputs.functionals',2);
    matlabbatch{2}.spm.spatial.realign.estwrite.data{index}(1) = cfg_dep(sprintf('Slice Timing: Slice Timing Corr. Images (Sess %d)',index),...
        substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{index}, '.','files'));
end

matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [0 1];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

%% Coregistration
matlabbatch{3}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{3}.spm.spatial.coreg.estimate.source = {sub.Scans.Anatomical.scanPath};
matlabbatch{3}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%% Save Pre-processing batch file, Run job
% save(fullfile(subdir,['FuncPreProc-st_realign_coreg-' date '.mat']),'matlabbatch');
% cd(subdir)
% spm('defaults', 'FMRI');
% spm_jobman('serial', matlabbatch);
batch = matlabbatch;
cd(fmr.scriptDir)
end