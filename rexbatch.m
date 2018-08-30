function [results, alt_results] = rexbatch()
% This function allows you to run multiple conditions through several ROIs and
% puts it together into a nice structure. It also accounts for conditions
% that do not include all subjects by inserting nans for missing subjects. 
% 
% [results, alt_results] = rexbatch
% results is a cell-containing structure: roi_summary.roi_name={cond_name1,cond_name2,...}
% alt_results is an element by element structure: roi_summary.roi_name.condition_name
%
% Each ROI with multiple clusters must be run individually.
%
% To use this function, download rex for ROI analysis from http://gablab.mit.edu/downloads/rex.m
% Read the documentation to change the default parameters as needed. 
%
% Email Lynn Ma at d327.lhma@yahoo.com for help if necessary. Or just run
% rex through all the conditions one-by-one. ¯\_(?)_/¯ 

%EDITED By Anthony Resnick (resnick.anthony@gmail.com). It will write out
%the ROI values using xlwrite. If xlwrite does not work, go to the folder
%(just type 'edit xlwrite' and change the current folder to find it, should
%be in the MATLAB folder in Documents, if not go download it yourself!), if it 
%doesn't work run the xlwrite test. 



cwd = pwd;
mainDir = uigetdir(pwd,'Choose 2nd lvl stats directory containing folders for every contrast and regressor.');
roiDir = '/Users/CNDM/Dropbox/USPS2017_ET_fMRI/fMRI_USPS/ROI';

%Get list of all 2nd lvl condition folders    
dirData = dir(mainDir);
validIndex = ~ismember({dirData(:).name},{'.','..','.DS_Store'});
batchList = sort({dirData(validIndex).name})';

%Get list of all roi images
cd(roiDir)
dirData = dir('*.nii');
validIndex = ~ismember({dirData(:).name},{'.','..','.DS_Store'});
roiList = sort(fullfile(roiDir,{dirData(validIndex).name}))';
cd(cwd)

% Creating selection List for conditions
for index = 1:length(batchList)
    selectionOptions(index,1) = {batchList{index}};
end

source_selection = listdlg('ListString',selectionOptions,...
    'SelectionMode','multiple',...
    'PromptString','Choose conditions to analyze.');

% Creating selection List for rois
clear selectionOptions
for index = 1:length(roiList)
    [~,roiname{index},~]=fileparts(roiList{index});
end
for index = 1:length(roiList)
    selectionOptions(index,1) = {roiname{index}};
end

roi_selection = listdlg('ListString',selectionOptions,...
    'SelectionMode','multiple',...
    'PromptString','Choose ROIs.');

% input number of clusters in ROI
clusternum = inputdlg('Input the number of clusters in your ROI');

% getting SPM.mat files from condition folders
cond=batchList(source_selection);
source=cell(length(source_selection),1);
for i=1:length(source_selection)
    [source(i,:),~]=get_any_files('SPM.mat',fullfile(mainDir,cond{i}));
end

if str2num(cell2mat(clusternum)) == 1
    roi = cell(length(roi_selection),1);
    for i = 1:length(roi_selection)
        roi{i,:}=roiname{roi_selection(i)};
    end
else
    for i = 1:str2num(cell2mat(clusternum)) 
        roi{i,:}=sprintf('%s_%d',roiname{roi_selection},i);
    end
end

% checking SPM.mat nscans all equal 
sub_num=zeros(length(source));
for i=1:length(source)
    load(source{i})
    sub_num(i,:)=SPM.nscan;
end

% generate subid list
[~, ia, ~]=unique(sub_num); % getting index of unique nscans
sub=cell(length(ia),1);
for i=1:length(ia)
    load(source{ia(i)})
    temp=strsplit(SPM.xY.P{1},'/');
    idx=strfind(SPM.xY.P{1},temp{9}); % 9 to match whichever cell contains the subID
    for j=1:length(SPM.xY.P)
        sub{i,:}(j,:)=SPM.xY.P{j}(idx:idx+4); % +4 to match the length of the subID
    end
    sub{i,:}=cellstr(sub{i});
end
% if nscans not equal for all conditions
if length(unique(sub_num)) > 1
    for i=1:length(ia)-1
        [A(i),ix(i)]=setdiff(sub{length(ia)},sub{i}); % gets ID and index for missing subject, last sub array used as bar for comparison because it's assumed to have the greatest # of sub
    end
end

% setting up final structure array
if str2num(cell2mat(clusternum)) == 1
    level='ROIs';
else
    level='clusters';
end
for i = 1:size(roi,1);
    loop = 1:length(source_selection);
    if length(unique(sub_num)) > 1 % if nscans not equal for all conditions
        if str2num(cell2mat(clusternum)) == 1
            for m=1:length(ia)-1 % run rex separately for unique nscan
                sep_roi.(roi{i})(:,m)=rex(source{ia(m)},char(roiList{roi_selection(i)}),'level',level,'output_type','none','select_clusters',0);
                loop (ia(m)) = []; % remove unique dim index from source
            end
            for m=1:length(ia)-1 % fill in nan for missing subject
                ins_roi.(roi{i})(:,m)=[sep_roi.(roi{i})(1:ix(m)-1,m); nan; sep_roi.(roi{i})(ix(m):end,m)];
            end
            for j = loop % run rex for remaining conditions
                roi_sum.(roi{i})(:,j)=rex(source{j},char(roiList{roi_selection(i)}),'level',level,'output_type','none','select_clusters',0);
                alt_results.(roi{i}).(cond{j})=rex(source{j},char(roiList{roi_selection(i)}),'level',level,'output_type','none','select_clusters',0); % output not saved in separate txt or tal file
            end
            for m=1:length(ia)-1 % insert now dim matching cond with other conditions
                roi_sum.(roi{i})(:,ia(m))=ins_roi.(roi{i})(:,m);
                alt_results.(roi{i}).(cond{ia(m)})=ins_roi.(roi{i})(:,m);
            end
        else
            for m=1:length(ia)-1 % run rex separately for unique nscan
                temproi=rex(source{ia(m)},char(roiList{roi_selection}),'level',level,'output_type','none','select_clusters',0); % output not saved in separate txt or tal file
                sep_roi.(roi{i})=temproi(:,i);
                loop (ia(m)) = []; % remove unique dim index from source
            end
            for m=1:length(ia)-1 % fill in nan for missing subject
                ins_roi.(roi{i})(:,m)=[sep_roi.(roi{i})(1:ix(m)-1,m); nan; sep_roi.(roi{i})(ix(m):end,m)];
            end
            for j = loop % run rex for remaining conditions
                temproi=rex(source{j},char(roiList{roi_selection}),'level',level,'output_type','none','select_clusters',0); % output not saved in separate txt or tal file
                roi_sum.(roi{i})(:,j)=temproi(:,i);
                alt_results.(roi{i}).(cond{j})=temproi(:,i);
                clear temproi
            end
            for m=1:length(ia)-1 % insert now dim matching cond with other conditions
                roi_sum.(roi{i})(:,ia(m))=ins_roi.(roi{i})(:,m);
                alt_results.(roi{i}).(cond{ia(m)})=ins_roi.(roi{i})(:,m);
            end
        end
    else
        if str2num(cell2mat(clusternum)) == 1
            for j=loop
                roi_sum.(roi{i})(:,j)=rex(source{j},char(roiList{roi_selection(i)}),'level',level,'output_type','none','select_clusters',0); % output not saved in separate txt or tal file
                alt_results.(roi{i}).(cond{j})=rex(source{j},char(roiList{roi_selection(i)}),'level',level,'output_type','none','select_clusters',0); % output not saved in separate txt or tal file
            end
        else
            for j=loop
                temproi=rex(source{j},char(roiList{roi_selection}),'level',level,'output_type','none','select_clusters',0); % output not saved in separate txt or tal file
                roi_sum.(roi{i})(:,j)=temproi(:,i);
                alt_results.(roi{i}).(cond{j})=temproi(:,i);
                clear temproi
            end
        end
    end
    
    % adding cond header and subID row names
    results.(roi{i})(:,1)=['SubID'; sub{end}];
    results.(roi{i})(1,2:length(cond)+1)=cond';
    results.(roi{i})(2:end,2:end)=num2cell(roi_sum.(roi{i}));
end

if ~exist(fullfile(roiDir,mainDir(51:end)))
    mkdir(fullfile(roiDir,mainDir(51:end)));4
end
for idx = 1:length(roi)
    xlwrite(fullfile(roiDir,mainDir(51:end),[roi{idx} '.xlsx']),results.(roi{idx}));
end



end


% Khoi's sub-func
function [yourFiles,filenames] = get_any_files(targetFile,mainDir)

%Get any files you want from any directory. This script will spider through
%your directories to retrieve the "targetFile". Script compiled by Khoi Vo

cwd = pwd;
switch nargin
    case 1
        mainDir = uigetdir(cwd, 'Select main directory that contains yours files');
end
[fileList,names] = get_files(mainDir);

for j = 1:size(fileList,1)
    if strfind(fileList{j},targetFile) > 0
        yourFiles{j,1} = fileList{j};
    end
end

for j = 1:size(names,1)
    if strfind(names{j},targetFile) > 0
        filenames{j,1} = names{j};
    end
end

yourFiles(cellfun(@isempty,yourFiles)) = [];
filenames(cellfun(@isempty,filenames)) = [];

    function [fileList,names] = get_files(dname)
        
        data = dir(dname);      % current directory
        index = [data.isdir];  % directory index
        fileList = {data(~index).name}';  % get file list
        names = {data(~index).name}';  % get file list
        
        if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dname,x),...  %add full path to data
        fileList,'UniformOutput',false);
end

subdir = {data(index).name};  % get subdirectory list
subindex = ~ismember(subdir,{'.','..'});  % index of subdirectories that are not '.' or '..'

for i = find(subindex)             
    nextdir = fullfile(dname,subdir{i});
    [temp1,temp2] = get_files(nextdir);
    fileList = [fileList; temp1];   %#ok<*AGROW>
    names = [names; temp2];   %#ok<*AGROW>
end
    end






end

