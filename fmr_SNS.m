function batch = fmr_ASN(fmr, sub)
%Accepts subject number as input. Conducts Segmentation, produces warp
%fields.

% Composed by Anthony Resnick 6/14/2017


subID = num2str(sub.subID);

cd(sub.mriDir)

dname = sub.inputs.niftidir;
defaults = spm('defaults','fmri');


% SPM Directory
spm_dir = which('spm');
spm_dir = spm_dir(1:end-5);






matlabbatch{1}.spm.spatial.preproc.channel.vols = {sub.Scans.Anatomical.scanPath};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm_dir 'tpm/TPM.nii,1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm_dir 'tpm/TPM.nii,2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm_dir 'tpm/TPM.nii,3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm_dir 'tpm/TPM.nii,4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm_dir 'tpm/TPM.nii,5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm_dir 'tpm/TPM.nii,6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];

matlabbatch{2}.spm.spatial.normalise.write.subj.def = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
%%
matlabbatch{2}.spm.spatial.normalise.write.subj.resample = sub.Scans.Functional.realignedScans;
%%
matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72
                                                          90 90 108];
matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;

matlabbatch{3}.spm.spatial.smooth.data = sub.Scans.Functional.NormalizedScans;
matlabbatch{3}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{3}.spm.spatial.smooth.dtype = 0;
matlabbatch{3}.spm.spatial.smooth.im = 0;
matlabbatch{3}.spm.spatial.smooth.prefix = 's';
%% Save Segment batch file, Run job
% save(fullfile(subdir,['FuncPreProc-anat_segment-' date '.mat']),'matlabbatch');
% cd(subdir)
% spm('defaults', 'FMRI');
% spm_jobman('serial', matlabbatch);
batch = matlabbatch;
cd(fmr.scriptDir)
end