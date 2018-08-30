function fMRIAnalysis = fMRI_Preprocessing(s,volType)
    fMRIAnalysis.sub = s;
    fMRIAnalysis.baseDir = '/Users/CNDM/Dropbox/USPS2017_ET_fMRI/fMRI_USPS';
    fMRIAnalysis.ProgressPath = [fMRIAnalysis.baseDir '/mriProgress.mat'];
    fMRIAnalysis.scriptDir = [fMRIAnalysis.baseDir '/Scripts'];
    fMRIAnalysis.rawDir = [fMRIAnalysis.baseDir '/Raw'];
    fMRIAnalysis.regressorDir = [fMRIAnalysis.baseDir '/Regressors'];
    fMRIAnalysis.preProc.outputDir = [fMRIAnalysis.baseDir '/Preprocessed'];
    fMRIAnalysis.secondLevelDir = [fMRIAnalysis.baseDir '/Second_Level'];
    load(fMRIAnalysis.ProgressPath); fMRIAnalysis.Progress = Progress; clear Progress;
    fMRIAnalysis.runs = {'recog_1' 'recog_2' 'recog_3' 'brandrec' 'fmradapt_1' 'fmradapt_2' 'adview'};
    
    
    for s_idx = 1:length(fMRIAnalysis.sub)
        fMRIAnalysis.Subject(s_idx).subID = num2str(fMRIAnalysis.sub(s_idx));
        fMRIAnalysis.Subject(s_idx).mriDir = [fMRIAnalysis.preProc.outputDir,'/',fMRIAnalysis.Subject(s_idx).subID,['_' volType]];
        fMRIAnalysis.Subject(s_idx).inputfile = [fMRIAnalysis.Subject(s_idx).mriDir,'/',fMRIAnalysis.Subject(s_idx).subID,'_inputs.mat'];
        fMRIAnalysis.Subject(s_idx).regressorDir = [fMRIAnalysis.regressorDir '/' fMRIAnalysis.Subject(s_idx).subID];
        load(fMRIAnalysis.Subject(s_idx).inputfile);fMRIAnalysis.Subject(s_idx).inputs = inputs; clear inputs;
        try
            fMRIAnalysis.Subject(s_idx).Scans = getScan(fMRIAnalysis,fMRIAnalysis.Subject(s_idx));
        catch
            cd(fMRIAnalysis.scriptDir)
        end
        fMRIAnalysis.Subject(s_idx).FuncpreproBatch = fmr_Funcprepro(fMRIAnalysis,fMRIAnalysis.Subject(s_idx));
        fMRIAnalysis.Subject(s_idx).SNSBatch = fmr_SNS(fMRIAnalysis,fMRIAnalysis.Subject(s_idx));
        fMRIAnalysis.Subject(s_idx).AdView_Model_Batch = fmr_AdView_Model(fMRIAnalysis,fMRIAnalysis.Subject(s_idx));
        try
            fMRIAnalysis.Subject(s_idx).BrandRec2_Model_Batch = fmr_BrandRec2_Model(fMRIAnalysis,fMRIAnalysis.Subject(s_idx)); % pmods moved
            fMRIAnalysis.Subject(s_idx).BrandRec_Model_Batch = fmr_BrandRec_Model(fMRIAnalysis,fMRIAnalysis.Subject(s_idx));
        catch
            cd(fMRIAnalysis.scriptDir)
        end
        
        try
            fMRIAnalysis.Subject(s_idx).Recognition_Model_Batch = fmr_Recognition_Model(fMRIAnalysis,fMRIAnalysis.Subject(s_idx));
        catch
            cd(fMRIAnalysis.scriptDir)
        end
        
        
        try
            fMRIAnalysis.Subject(s_idx).fmrAdapt_Model_Batch = fmr_fmrAdapt_Model(fMRIAnalysis,fMRIAnalysis.Subject(s_idx));
            fMRIAnalysis.Subject(s_idx).fmrAdapt2_Model_Batch = fmr_fmrAdapt2_Model(fMRIAnalysis,fMRIAnalysis.Subject(s_idx));
        catch
            cd(fMRIAnalysis.scriptDir)
        end
    end
end
