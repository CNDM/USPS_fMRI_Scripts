function addContrasts(modelName,fmr)
cwd = pwd;
switch modelName
        case 'AdView_Model'
            model = 'adview';
        case 'BrandRec_Model'
            model = 'brandrec';
        case 'BrandRec2_Model';
            model = 'brandrec'
        case 'Recognition_Model'
            model = 'recog_1'
        case 'fmrAdapt_Model';
            model = 'fmradapt_1';
        case 'fmrAdapt2_Model';
            model = 'fmradapt_1';
end

    for subIdx = 1:length(fmr.Subject)
        spmDir = fmr.Subject(subIdx).(sprintf('%s_Batch',modelName)){1,1}.spm.stats.fmri_spec.dir;
        spmFile = [spmDir{:} '/SPM.mat'];
        cd(spmDir{:})
        
        %CURRENTLY SET UP FOR ADAPT MODEL
        %% Add the contrasts you would like to add to your models
        matlabbatch{1}.spm.stats.con.spmmat(1) = {spmFile};
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'PHYS_FvP1';
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [-1 0 1 0 0 0 0 0];
        matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'DIG_FvP1';
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 -1 0 1 0];
        matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{1}.spm.stats.con.delete = 0;
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch);
    end
    cd(cwd)
end