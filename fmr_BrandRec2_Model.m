function batch = fmr_BrandRec2_Model(fmr, sub)
%Accepts subject number as input. Builds 1st level model, estimates, and
%builds contrasts.

% Composed by Anthony Resnick 6/26/2017

% Directory
subID = num2str(sub.subID);

cd(sub.mriDir)


movement = sub.Scans.Functional.brandrec.movementParameters;


%   Create Model Directory
modelDir = fullfile(sub.Scans.Functional.brandrec.directory,'BrandRec2_Model');

if ~exist(modelDir)
    mkdir(modelDir);
end


%   Read in regressors
cd(sub.regressorDir)
Regressors = csvread(fullfile(sub.regressorDir, sprintf('BrandRec2Regressor%s',subID)));
Regressors(:,[1,3,5]) = Regressors(:,[1,3,5]) - 4;

BrandName_Regressor = Regressors(:,[1,2]);

PE_Regressor = Regressors(Regressors(:,8)==1 & Regressors(:,9)==1,[3,4,10]);
PF_Regressor = Regressors(Regressors(:,8)==2 & Regressors(:,9)==1,[3,4,10]);
PM_Regressor = Regressors(Regressors(:,8)==3 & Regressors(:,9)==1,[3,4,10]);
DE_Regressor = Regressors(Regressors(:,8)==1 & Regressors(:,9)==2,[3,4,10]);
DF_Regressor = Regressors(Regressors(:,8)==2 & Regressors(:,9)==2,[3,4,10]);
DM_Regressor = Regressors(Regressors(:,8)==3 & Regressors(:,9)==2,[3,4,10]);

Ratings_Regressor = Regressors(:,[5,6]);
%% First Level Specification
matlabbatch{1}.spm.stats.fmri_spec.dir = {modelDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 36;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = sub.Scans.Functional.brandrec.smoothNormalizedScans;
%%  Brand Name Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Brand_Name_Shown';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = BrandName_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = BrandName_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
%%  Physical Emotional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Physical_Emotional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = PE_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = PE_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod.name = 'PhysEmo_Vividness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod.param = PE_Regressor(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).orth = 1;

%%  Physical Functional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Physical_Functional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = PF_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = PF_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod.name = 'PhysFunc_Vividness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod.param = PF_Regressor(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).orth = 1;

%%  Physical Metaphorical Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Physical_Metaphorical';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = PM_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = PM_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod.name = 'PhysMeta_Vividness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod.param = PM_Regressor(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).orth = 1;

%%  Digital Emotional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 'Digital_Emotional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = DE_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = DE_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).pmod.name = 'DigEmo_Vividness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).pmod.param = DE_Regressor(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).orth = 1;

%%  Digital Functional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).name = 'Digital_Functional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).onset = DF_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).duration = DF_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).pmod.name = 'DigFunc_Vividness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).pmod.param = DF_Regressor(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).orth = 1;

%%  Digital Metaphorical Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).name = 'Digital_Metaphorical';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).onset = DM_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).duration = DM_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).pmod.name = 'DigMeta_Vividness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).pmod.param = DM_Regressor(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).orth = 1;
%%  Vividness Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).name = 'Vividness_Rating';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).onset = Ratings_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).duration = Ratings_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).tmod = 0;


%%
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = movement;
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'none';

%% Estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% Contrasts
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'VivRate_Physical_Emotional';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 0 1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'VivRate_Physical_Functional';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'VivRate_Physical_Metaphorical';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'VivRate_Digital_Emotional';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'VivRate_Digital_Functional';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'VivRate_Digital_Metaphorical';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'VivRate_PhysEmo - DigEmo';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 0 1 0 0 0 0 0 -1 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'VivRate_PhysFunc - DigFunc';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [0 0 0 0 1 0 0 0 0 0 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'VivRate_PhysMeta - DigMeta';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 0 0 1 0 0 0 0 0 -1];
matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'VivRate_Physical - Digital';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [0 0 1 0 1 0 1 0 -1 0 -1 0 -1];
matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'VivRate_Functional - Emotional';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [0 0 -1 0 1 0 0 0 -1 0 1 0 0];
matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'VivRate_Functional - Metaphorical';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 0 1 0 -1 0 0 0 1 0 -1];
matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = 'VivRate_Emotional - Metaphorical';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.weights = [0 0 1 0 0 0 -1 0 1 0 0 0 -1];
matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = 'Brand Name';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.weights = [1];
matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = 'Vividness Duration';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = 'Physical_Emotional';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.name = 'Physical_Functional';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.weights = [0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{18}.tcon.name = 'Physical_Metaphorical';
matlabbatch{3}.spm.stats.con.consess{18}.tcon.weights = [0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{19}.tcon.name = 'Digital_Emotional';
matlabbatch{3}.spm.stats.con.consess{19}.tcon.weights = [0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{19}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.name = 'Digital_Functional';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.weights = [0 0 0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{21}.tcon.name = 'Digital_Metaphorical';
matlabbatch{3}.spm.stats.con.consess{21}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{22}.tcon.name = 'PhysEmo - DigEmo';
matlabbatch{3}.spm.stats.con.consess{22}.tcon.weights = [0 1 0 0 0 0 0 -1 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{23}.tcon.name = 'PhysFunc - DigFunc';
matlabbatch{3}.spm.stats.con.consess{23}.tcon.weights = [0 0 0 1 0 0 0 0 0 -1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{23}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{24}.tcon.name = 'PhysMeta - DigMeta';
matlabbatch{3}.spm.stats.con.consess{24}.tcon.weights = [0 0 0 0 0 1 0 0 0 0 0 -1 0];
matlabbatch{3}.spm.stats.con.consess{24}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{25}.tcon.name = 'Physical - Digital';
matlabbatch{3}.spm.stats.con.consess{25}.tcon.weights = [0 1 0 1 0 1 0 -1 0 -1 0 -1 0];
matlabbatch{3}.spm.stats.con.consess{25}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{26}.tcon.name = 'Functional - Emotional';
matlabbatch{3}.spm.stats.con.consess{26}.tcon.weights = [0 -1 0 1 0 0 0 -1 0 1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{26}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{27}.tcon.name = 'Functional - Metaphorical';
matlabbatch{3}.spm.stats.con.consess{27}.tcon.weights = [0 0 0 1 0 -1 0 0 0 1 0 -1 0];
matlabbatch{3}.spm.stats.con.consess{27}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{28}.tcon.name = 'Emotional - Metaphorical';
matlabbatch{3}.spm.stats.con.consess{28}.tcon.weights = [0 1 0 0 0 -1 0 1 0 0 0 -1 0];
matlabbatch{3}.spm.stats.con.consess{28}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;

%% Save Pre-processing batch file, Run job
% save(fullfile(modelDir,['AI_Decision' date '.mat']),'matlabbatch');
% cd(modelDir)
% spm('defaults', 'FMRI');
% spm_jobman('serial', matlabbatch);
batch = matlabbatch;
cd(fmr.scriptDir)
end