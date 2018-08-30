function batch = fmr_fmrAdapt2_Model(fmr, sub)
%Accepts subject number as input. Builds 1st level model, estimates, and
%builds contrasts.

% Composed by Anthony Resnick 6/26/2017

% Directory
subID = num2str(sub.subID);

cd(sub.mriDir)


movement1 = load(sub.Scans.Functional.fmradapt_1.movementParameters{:});
if ~strcmp(subID, '102')
    movement2 = load(sub.Scans.Functional.fmradapt_2.movementParameters{:});
    R = [movement1;movement2];
else
    R = [movement1];
end

scans1 = [sub.Scans.Functional.fmradapt_1.smoothNormalizedScans(:)];
if ~strcmp(subID, '102')
    scans2 = [sub.Scans.Functional.fmradapt_2.smoothNormalizedScans(:)];
    scans = [scans1;scans2];
else
    scans = [scans1];
end


%   Create Model Directory
modelDir = fullfile(sub.Scans.Functional.fmradapt_1.directory,'fmrAdapt2_Model');

if ~exist(modelDir)
    mkdir(modelDir);
end
save(sprintf('%s/movementparameter.mat',modelDir),'R')





%   Read in regressors
cd(sub.regressorDir)
Regressors = csvread(fullfile(sub.regressorDir, sprintf('fmrAdapt2Regressor%s',subID)));

Brand = Regressors(:,[1,2]);
Memory_Regressor = Regressors(:,[3,4]);
PrintA_Regressor = Brand(Regressors(:,5)==1 & Regressors(:,6)==1,:);
PrintB_Regressor = Brand(Regressors(:,5)==2 & Regressors(:,6)==1,:); 
PrintFoil_Regressor = Brand(Regressors(:,5)==3 & Regressors(:,6)==1,:); 
PrintControl_Regressor = Brand(Regressors(:,5)==4 & Regressors(:,6)==1,:); 
PrintMemory = Memory_Regressor(Regressors(:,6)==1,:);

DigitalA_Regressor = Brand(Regressors(:,5)==1 & Regressors(:,6)==2,:); 
DigitalB_Regressor = Brand(Regressors(:,5)==2 & Regressors(:,6)==2,:); 
DigitalFoil_Regressor = Brand(Regressors(:,5)==3 & Regressors(:,6)==2,:); 
DigitalControl_Regressor = Brand(Regressors(:,5)==4 & Regressors(:,6)==2,:); 
DigitalMemory = Memory_Regressor(Regressors(:,6)==2,:);


%% First Level Specification
matlabbatch{1}.spm.stats.fmri_spec.dir = {modelDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 36;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = scans;
%%  Physical Target1 Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Physical_P1';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = PrintA_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = PrintA_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;

%%  Physical Target2 Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Physical_P2';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = PrintB_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = PrintB_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;

%%  Physical Foils Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Physical_F';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = PrintFoil_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = PrintFoil_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;

%%  Physical Control Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Physical_C';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = PrintControl_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = PrintControl_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;
%%  Digital Target1 Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 'Digital_P1';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = DigitalA_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = DigitalA_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;

%%  Digital Target2 Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).name = 'Digital_P2';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).onset = DigitalB_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).duration = DigitalB_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).tmod = 0;

%%  Digital Foils Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).name = 'Digital_F';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).onset = DigitalFoil_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).duration = DigitalFoil_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).tmod = 0;

%%  Digital Control Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).name = 'Digital_C';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).onset = DigitalControl_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).duration = DigitalControl_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).tmod = 0;

%% Print Memory Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(9).name = 'Print_Memory';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(9).onset = PrintMemory(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(9).duration = PrintMemory(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(9).tmod = 0;

%% Digital Memory Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(10).name = 'Digital_Memory';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(10).onset = DigitalMemory(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(10).duration = DigitalMemory(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(10).tmod = 0;

%%
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {sprintf('%s/movementparameter.mat',modelDir)};
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
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'CvP1';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [-1 0 0 1 -1 0 0 1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'PHYSvDIG_Pairs';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [1 1 0 0 -1 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'CvF';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 -1 1 0 0 -1 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'P1';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [1 0 0 0 1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'P2';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 1 0 0 0 1 0 0];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'F';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 1 0 0 0 1 0];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'C';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 1 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'PHYS_Pairs';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [1 1 0 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'DIG_Pairs';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 0 1 1 0 0];
matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'Memory';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [0 0 0 0 0 0 0 0 1 1];
matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'PHYS_CvP1';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [-1 0 0 1 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'DIG_CvP1';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [0 0 0 0 -1 0 0 1 0];
matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = 'PHYSvDIG_C';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.weights = [0 0 0 1 0 0 0 -1 0];
matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = 'PHYSvDIG_F';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.weights = [0 0 1 0 0 0 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = 'PHYSvDIG_Memory';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.weights = [0 0 0 0 0 0 0 0 1 -1];
matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = 'PHYS_P1';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.weights = [1];
matlabbatch{3}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.name = 'DIG_P1';
matlabbatch{3}.spm.stats.con.consess{17}.tcon.weights = [0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{18}.tcon.name = 'PHYS_C';
matlabbatch{3}.spm.stats.con.consess{18}.tcon.weights = [0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{19}.tcon.name = 'DIG_C';
matlabbatch{3}.spm.stats.con.consess{19}.tcon.weights = [0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{19}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.name = 'PHYSvDIG_CvP1';
matlabbatch{3}.spm.stats.con.consess{20}.tcon.weights = [-1 0 0 1 1 0 0 -1];
matlabbatch{3}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{21}.tcon.name = 'PHYSvDIG_FvP1';
matlabbatch{3}.spm.stats.con.consess{21}.tcon.weights = [-1 0 1 0 1 0 -1 0];
matlabbatch{3}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{22}.tcon.name = 'PHYS_FvP1';
matlabbatch{3}.spm.stats.con.consess{22}.tcon.weights = [-1 0 1 0 0 0 0 0];
matlabbatch{3}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{23}.tcon.name = 'DIG_FvP1';
matlabbatch{3}.spm.stats.con.consess{23}.tcon.weights = [0 0 0 0 -1 0 1 0];
matlabbatch{3}.spm.stats.con.consess{23}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;

%% Save Pre-processing batch file, Run job
% save(fullfile(modelDir,['AI_Decision' date '.mat']),'matlabbatch');
% cd(modelDir)
% spm('defaults', 'FMRI');
% spm_jobman('serial', matlabbatch);
batch = matlabbatch;
cd(fmr.scriptDir)
end