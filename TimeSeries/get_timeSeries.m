function timeSeries = get_timeSeries(fmr,modelName,ROI_SELECTION)
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

switch nargin
    case 2
        ROI_SELECTION = 1;
end

SCALING = 'roi'; %Choose 'none','global',or 'roi'

roiDir = '/Users/CNDM/Dropbox/USPS2017_ET_fMRI/fMRI_USPS/ROI';
cd(roiDir)
%Get list of all roi images
dirData = dir('*.nii');
cd(cwd);
validIndex = ~ismember({dirData(:).name},{'.','..','.DS_Store'});

% Select ROI's...or don't, just take them all!
roiList = sort(fullfile(roiDir,{dirData(validIndex).name}))';
if ROI_SELECTION
    for index = 1:length(roiList)
        [~,roiname{index},~]=fileparts(roiList{index});
    end
    for index = 1:length(roiList)
        selectionOptions(index,1) = {roiname{index}};
    end
    
    roi_selection = listdlg('ListString',selectionOptions,...
        'SelectionMode','multiple',...
        'PromptString','Choose ROIs.');
    if isempty(roi_selection)==1; return; end
    roiList = roiList(roi_selection);
end


for roiIdx = 1:length(roiList)
    roi = roiList{roiIdx};
    for subIdx = 1:length(fmr.Subject)
        display(sprintf('ROI: %d/%d    SUBJECT: %d/%d    MODEL: %s',roiIdx,length(roiList),subIdx,length(fmr.Subject),modelName))
        spmDir = fmr.Subject(subIdx).(sprintf('%s_Batch',modelName)){1,1}.spm.stats.fmri_spec.dir;
        spmFile = [spmDir{:} '/SPM.mat'];
    
        Means = rex(spmFile,roi,'summary_measure','mean','level','rois','scaling',SCALING);
        regs = fmr.Subject(subIdx).(sprintf('%s_Batch',modelName)){1,1}.spm.stats.fmri_spec.sess.cond;
        for regIdx = 1:length(regs)
            regOnsets.(regs(regIdx).name) = floor(round(regs(regIdx).onset)/2);
            for onsetIdx = 1:length(regOnsets.(regs(regIdx).name))
                if (regOnsets.(regs(regIdx).name)(onsetIdx)+10) > length(Means)
                    timeSeries.(roiList{roiIdx}(length(roiDir)+2:length(roiList{roiIdx})-4))(subIdx).(regs(regIdx).name){onsetIdx,1} = Means([regOnsets.(regs(regIdx).name)(onsetIdx):end])';
                else
                    timeSeries.(roiList{roiIdx}(length(roiDir)+2:length(roiList{roiIdx})-4))(subIdx).(regs(regIdx).name){onsetIdx,1} = Means([regOnsets.(regs(regIdx).name)(onsetIdx):regOnsets.(regs(regIdx).name)(onsetIdx)+10])';
                end
            end
        end
    end
end

save(sprintf('%s/%s_%s_timeseries.mat',cwd,modelName,SCALING),'timeSeries')


                


