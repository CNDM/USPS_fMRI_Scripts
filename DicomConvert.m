function [] = DicomConvert()
%Adapted from the Shop task (Sangsuk), with was adapted from USPS project.
%Looks like originally written by Khoi Vo around 2015.
%Adapted by C.Reeck May 2017 for SaTC 3 project. This script is used ONLY
%for reconstruction. 
%Assumes 6 disdaqs. 
%NOTE: Must be run with spm and mricron installed. 

scriptdir = pwd;

cd('..')
maindir = pwd;
rawdir = [maindir, '/Raw']
%Laptop Setup. 
outputdir = [maindir, '/Preprocessed']; %Where should images be output? 

%Can instead use GUI:
%mainDir = uigetdir(pwd,'Choose source directory for all subjects in batch named "Raw Dicoms"    ');
%outputdir = uigetdir(pwd,'Choose output directory named "Preprocessed"');

%Removes .DS_Store files, which are hidden and sometimes accidentally added
try
    dstore = get_any_files('.DS_Store',rawdir);
    for i = 1:length(dstore)
        delete(dstore{i});
    end
catch
end

matlabmainpath = userpath; %Where matlab is stored on analysis machine. 
%Patch to MRICron on analysis machine
%If MRICron path is not recognized, Matlab will request user input

%CNDM set up
mricrondname = '/Users/CNDM/Documents/MATLAB/CNDMToolbox/MRICron';


%Get list of all folders containing dicoms (one per subject)
dirData = dir(rawdir);     
dirIndex = [dirData.isdir];  
subDirs = {dirData(dirIndex).name};  
validIndex = ~ismember(subDirs,{'.','..'});
batchList = {dirData(validIndex).name};

%Creating selection List
for index = 1:length(batchList)
    selectionOptions(index,1) = {batchList{index}};
end

subject_selection = listdlg('ListString',selectionOptions,...
    'SelectionMode','multiple',...
    'PromptString','Choose subjects to preprocess');

temp = batchList; clear batchList
batchList = temp(subject_selection);

%ALWAYS RUN WITH CONVERSION ONLY!!!
preprocChoice = questdlg('What do you want to do?',...
    'Preprocessing option',...
    'Convert DICOM ONLY','Preprocess ONLY','Convert & Preprocess','Convert & Preprocess');

for i = 1:size(batchList,2)
    subjectID = batchList{i};
    sourcename = fullfile(rawdir,batchList{i});
    try
        switch preprocChoice
            case 'Convert DICOM ONLY'
                display(sprintf('Converting DICOM for subject: %s',subjectID));
                
                dicom_convert(sourcename, subjectID,outputdir,mricrondname);
            case 'Preprocess ONLY'
                display(sprintf('Preprocessing for subject: %s',subjectID));
                
                Funcprepro(fullfile(outputdir,strcat(subjectID,'_3D'),strcat(subjectID,'_inputs.mat'))); 
            otherwise
                display(sprintf('Converting DICOM & Preprocessing for subject: %s',subjectID));
                
                dicom_convert(sourcename, subjectID,outputdir,mricrondname);
                Funcprepro(fullfile(outputdir,strcat(subjectID,'_3D'),strcat(subjectID,'_inputs.mat'))); 
        end                
        display(sprintf('Procedure successful for: %s',subjectID));
    catch ME %#ok<*NASGU>
        display(sprintf('Procedure failed for: %s',subjectID));
    end
end


function [] = dicom_convert(sourcename, subjectID,outputdir,mricrondname)

%-------------------------------------------------------------------------%
%   creates user input dialog for key parameters
%-------------------------------------------------------------------------%    

inputs.subjectID = subjectID;

inputs.cfgfile = 2; % change to 2 for 4D images
    if inputs.cfgfile == 2
        cfgfile = '4D.ini';
    else cfgfile = '3D.ini';
    end
    
subjectID = strcat(subjectID,'_',cfgfile(1:end-4));
inputs.dicomdir = sourcename;
inputs.niftidir = fullfile(outputdir,subjectID);

tic;
try
    %-------------------------------------------------------------------------%
    %   anon & converting dicoms --> nifti
    %-------------------------------------------------------------------------%
    
    display('Anonymizing & converting DICOM files');
    
    %Create output folder
    if exist(fullfile(outputdir,subjectID),'dir')==0
        mkdir(fullfile(outputdir,subjectID));
    end
    
    %Calling dcm2nii (works on both PC and unix-based systems)
    if ispc
        anoncmd = ['"' mricrondname '\dcm2nii" -a y -b "' mricrondname '\' cfgfile '" -o "' ...
            fullfile(outputdir,['/' subjectID '"']) ' "' sourcename '"'];
        system(anoncmd);
    else
        anoncmd = [mricrondname '/dcm2nii -a y -b ' mricrondname '/' cfgfile ' -o ''' fullfile(outputdir,subjectID) ''' ''' sourcename ''''];
        unix(anoncmd);
    end
    
    %-------------------------------------------------------------------------%
    %   Read a number of dicom headers to obtain information on series and
    %   series name for folder creation purposes
    %-------------------------------------------------------------------------%
    display('Moving anonymized & converted NIFTI files');
    
    dicomList = get_dicoms(sourcename);
    
    % Is there a DICOMDIR that was imported as well?
    temp = dicomList{1,1};
    if strcmp(temp(size(temp,2)-7:end),'DICOMDIR')
        dicomList = dicomList(2:end,1);
    end
    
    index = 1:3:size(dicomList,1); %sample every 20th dicom for header information
    
    %key step in this process - if the headers are incomplete, then this
    %step will fail
    images = char(dicomList(index,1));
    try
        for i = 1:size(images,1)
            hdrs{1,i} = dicominfo(images(i,:)); %this function is included in image processing toolbox for Matlab
        end
    catch
        hdrs = spm_dicom_headers(images);
    end
    
    for i = 1:size(hdrs,2)
        seriesNum(i,1) = hdrs{1,i}.SeriesNumber;
        seriesName{i,1} = hdrs{1,i}.SeriesDescription;
        if seriesNum(i,1) < 10
            num_name{i,1} = lower(strcat('0',num2str(seriesNum(i,1)),'_',seriesName{i,1}));
        else
            num_name{i,1} = lower(strcat(num2str(seriesNum(i,1)),'_',seriesName{i,1}));
        end
    end
    
    folders = unique(num_name);
    
    inputs.series = folders;
    inputs.moco_index = zeros(size(folders,1),1);
    inputs.nonmoco_index = zeros(size(folders,1),1);
    
    for i = 1:size(folders,1)
        if strfind(folders{i,1},'t1')
            if exist(fullfile(outputdir,subjectID,'T1'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,'T1'));
            end
            movefile(fullfile(outputdir,subjectID,sprintf('s0%s*.nii',folders{i}(1:2))),...
                fullfile(outputdir,subjectID,'t1'));
            T1 = dir(fullfile(outputdir,subjectID,'T1','*.nii'));
            inputs.T1 = char(fullfile(outputdir,subjectID,'T1',{T1.name}));
        end
        if strfind(folders{i,1},'localizer')
            if exist(fullfile(outputdir,subjectID,'Localizer'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,'Localizer'));
            end
            movefile(fullfile(outputdir,subjectID,sprintf('s0%s*.nii',folders{i}(1:2))),...
                fullfile(outputdir,subjectID,'localizer'));
            localizer = dir(fullfile(outputdir,subjectID,'Localizer','*.nii'));
            inputs.localizer = char(fullfile(outputdir,subjectID,'Localizer',{localizer.name}));
        end
        if strfind(folders{i,1},'gre')
            if exist(fullfile(outputdir,subjectID,'GRE'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,'GRE'));
            end
            movefile(fullfile(outputdir,subjectID,sprintf('s0%s*.nii',folders{i}(1:2))),...
                fullfile(outputdir,subjectID,'gre'));
            GRE = dir(fullfile(outputdir,subjectID,'GRE','*.nii'));
            inputs.GRE = char(fullfile(outputdir,subjectID,'GRE',{GRE.name}));
        end
        if strfind(folders{i,1},'fieldmap')
            if exist(fullfile(outputdir,subjectID,'SMS_FIELDMAP'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,'SMS_FIELDMAP'));
            end
            movefile(fullfile(outputdir,subjectID,sprintf('s0%s*.nii',folders{i}(1:2))),...
                fullfile(outputdir,subjectID,'fieldmap'));
            GRE = dir(fullfile(outputdir,subjectID,'SMS_FIELDMAP','*.nii'));
            inputs.GRE = char(fullfile(outputdir,subjectID,'SMS_FIELDMAP',{GRE.name}));
        end
        if strfind(folders{i,1},'recog_1')
            try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
            end
        end
        if strfind(folders{i,1},'recog_2')
            try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
            end
        end
        if strfind(folders{i,1},'recog_3')
            try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
            end
        end
        if strfind(folders{i,1},'brandrec')
            try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
           end
        end
        if strfind(folders{i,1},'fmradapt_1')
           try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
           end
        end
        if strfind(folders{i,1},'fmradapt_2')
           try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
           end
        end
        if strfind(folders{i,1},'adview')
           try
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1:2));
            catch
                inputs.nonmoco_index(i,1) = str2num(folders{i,1}(1));
           end
        end
    end
    
    if sum(inputs.moco_index)>0
        inputs.moco_index = sort(inputs.moco_index(inputs.moco_index ~=0,1));
    end
    inputs.nonmoco_index = sort(inputs.nonmoco_index(inputs.nonmoco_index ~=0,1)); 
    
    runNames = {'recog_1','recog_2','recog_3','brandrec','fmradapt_1','fmradapt_2','adview'};

    
    %Move functionals
    for i = 1:size(inputs.nonmoco_index,1)
        if exist(fullfile(outputdir,subjectID,runNames{i}),'dir')==0
            mkdir(fullfile(outputdir,subjectID,runNames{i}));
        end
        
        %Creating sub-folders for each run
        if exist(fullfile(outputdir,subjectID,runNames{i},'NonMoCo'),'dir')==0
            mkdir(fullfile(outputdir,subjectID,runNames{i},'NonMoCo'));
        end
        if sum(inputs.moco_index) > 0
            if exist(fullfile(outputdir,subjectID,runNames{i},'MoCo'),'dir')==0
                mkdir(fullfile(outputdir,subjectID,runNames{i},'MoCo'));
            end
        end
            
        %Non-MoCo files
        movefile(fullfile(outputdir,subjectID,sprintf('s0%02d*.nii',inputs.nonmoco_index(i))),...
            fullfile(outputdir,subjectID,runNames{i},'NonMoCo'));
        
        %MoCo files
        if sum(inputs.moco_index) > 0
            movefile(fullfile(outputdir,subjectID, sprintf('s0%02d*.nii',inputs.moco_index(i))),...
                fullfile(outputdir,subjectID,runNames{i},'MoCo'));
            
            rmdir(fullfile(outputdir,subjectID,runNames{i},'MoCo'),'s');
        end
        
        images = dir(fullfile(outputdir,subjectID,runNames{i},'NonMoCo','s0**.nii')); %change accordingly based on file name
        inputs.functionals{i,1} = sort(fullfile(outputdir,subjectID,runNames{i},'NonMoCo',{images.name})); %#ok<*AGROW>
    end
    
    % Throwing away the first TR (if 3D images)
    if inputs.cfgfile == 1
        for i = 1:size(inputs.functionals,1)
            inputs.functionals{i,1} = inputs.functionals{i,1}(3:end)'; % excluded 1 TR
        end
    end
    %-------------------------------------------------------------------------%
    %   finalizing analyses
    %-------------------------------------------------------------------------%
    
    images = dir(fullfile(outputdir,subjectID,'recog_1','NonMoCo','*001.nii')); %change accordingly based on file name
    volinfo = spm_vol(fullfile(outputdir,subjectID,'recog_1','NonMoCo',char(images(1,1).name)));
    inputs.nslices = volinfo(1,1).dim(3); % get information of the number of slices from one selected file
    inputs.nruns = size(inputs.nonmoco_index,1);
        
    save(fullfile(outputdir,subjectID,strcat(inputs.subjectID,'_inputs.mat')),'inputs');
catch ME %#ok<*NASGU>
    display('Error converting DICOMS to NIFTI. Please check your files.');
    display(['Error from: ' sourcename]);
end
toc;

function fileList = get_dicoms(dname)

switch nargin
    case 0
        dname = uigetdir('Choose directory of dicoms');
end

data = dir(dname);      % current directory
index = [data.isdir];  % directory index
fileList = {data(~index).name}';  % get file list

if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dname,x),...  %add full path to data
        fileList,'UniformOutput',false);
end

subdir = {data(index).name};  % get subdirectory list
subindex = ~ismember(subdir,{'.','..'});  % index of subdirectories that are not '.' or '..'

for i = find(subindex)             
    nextdir = fullfile(dname,subdir{i});
    fileList = [fileList; get_dicoms(nextdir)];   %#ok<*AGROW>
end


