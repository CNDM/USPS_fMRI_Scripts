function theData = Build_RecogRegressor(s,overwrite)

%%%% Takes Subject number as input, builds 3 files of onsets, Responses,
%%%% and RT, saves these into the saveDir as csv files. Please change the
%%%% dataDir and saveDir to match where your data is, and where you want to
%%%% save the new files. Will create folders for each sub number

% Composed by Anthony Resnick, June 8 2017



cwd = pwd;

%---------------------------------------------------------------
% ****************************************************************************
% *** Please change these to your data and save directories ***
% ****************************************************************************

% Anthony's Directory
if s < 200
    dataDir = '/Users/CNDM/Dropbox/USPS 2017/Results/Main_Study/Millenials';
elseif s < 300
    dataDir = '/Users/CNDM/Dropbox/USPS 2017/Results/Main_Study/GenX';
elseif s > 299
    dataDir = '/Users/CNDM/Dropbox/USPS 2017/Results/Main_Study/Baby_Boomers';
end
    
    saveDir = '/Users/CNDM/Dropbox/USPS2017_ET_fMRI/fMRI_USPS/Regressors';


%---------------------------------------------------------------

    subjectID = num2str(s);
    sourcename = fullfile(dataDir,subjectID);
    cd(sourcename)

    Recog1 = tdfread(sprintf('Recog_Run1_%s.tsv',subjectID));
    Recog2 = tdfread(sprintf('Recog_Run2_%s.tsv',subjectID));
    Recog3 = tdfread(sprintf('Recog_Run3_%s.tsv',subjectID));
    
    foilIdx = [cellstr(Recog1.Group);cellstr(Recog2.Group);cellstr(Recog3.Group)];
     
    Recog1.FormatOnset = clean(Recog1.FormatOnset);    Recog2.FormatOnset = clean(Recog2.FormatOnset);    Recog3.FormatOnset = clean(Recog3.FormatOnset);
    Recog1.FormatRT = clean(Recog1.FormatRT); Recog2.FormatRT = clean(Recog2.FormatRT); Recog3.FormatRT = clean(Recog3.FormatRT); 
    Recog1.BrandOnset = clean(Recog1.BrandOnset); Recog2.BrandOnset = clean(Recog2.BrandOnset); Recog3.BrandOnset = clean(Recog3.BrandOnset); 
    Recog1.BrandRT = clean(Recog1.BrandRT); Recog2.BrandRT = clean(Recog2.BrandRT); Recog3.BrandRT = clean(Recog3.BrandRT); 
    
    Times1 = [Recog1.AdOnset,Recog1.RecogOnset,Recog1.RecogRT,Recog1.FormatOnset,Recog1.FormatRT,Recog1.BrandOnset,Recog1.BrandRT];
    Times2 = [Recog2.AdOnset,Recog2.RecogOnset,Recog2.RecogRT,Recog2.FormatOnset,Recog2.FormatRT,Recog2.BrandOnset,Recog2.BrandRT];
    Times3 = [Recog3.AdOnset,Recog3.RecogOnset,Recog3.RecogRT,Recog3.FormatOnset,Recog3.FormatRT,Recog3.BrandOnset,Recog3.BrandRT];
    
    Times1 = Times1 + 4;
    Times2 = Times2 + 316 + 4;
    Times3 = Times3 + 316 + 316 + 4;
    timeTotal = [Times1;Times2;Times3] ;
    timeTotal = timeTotal(~strcmp(foilIdx,'foil'),:);
    
        Header = {'AdOnset','RecogOnset','RecogDuration','FormatOnset','FormatDuration','BrandOnset','BrandDuration','Type','Format'};
        AdOnset = timeTotal(:,1);
        RecogOnset = timeTotal(:,2);
        RecogDuration = timeTotal(:,3) - timeTotal(:,2);
        FormatOnset = timeTotal(:,4);
        FormatDuration = timeTotal(:,5)-timeTotal(:,4);
        BrandOnset = timeTotal(:,6);
        BrandDuration = timeTotal(:,7)-timeTotal(:,6);
        
        RecType = [Recog1.Type;Recog2.Type;Recog3.Type];
        RecType = RecType(~strcmp(foilIdx,'foil'),:)
        RecogType = cellstr(RecType);
        
        RecFormat = [Recog1.Format;Recog2.Format;Recog3.Format];
        RecFormat = RecFormat(~strcmp(foilIdx,'foil'),:);
        RecogFormat = cellstr(RecFormat);
        
        
        for i = 1:length(timeTotal)
            switch RecogType{i}
                case 'Emotional'
                    Type(i) = 1;
                case 'Functional'
                    Type(i) = 2;
                case 'Metaphorical'
                    Type(i) = 3;
            end
            switch RecogFormat{i}
                case 'Physical'
                    Format(i) = 1;
                case 'Digital'
                    Format(i) = 2;
            end
        end
        
                
        
        
        Recognition = [AdOnset,RecogOnset,RecogDuration,FormatOnset,FormatDuration,BrandOnset,BrandDuration,Type',Format'];
                
        cd(saveDir)
        
        if exist(fullfile(saveDir,subjectID),'dir')==0
            mkdir(fullfile(saveDir,subjectID));
        end
        
        if overwrite == 1
            csvwrite(fullfile(saveDir,subjectID,sprintf('RecogRegressor%s',subjectID)),Recognition)
        else
            if exist(fullfile(saveDir,subjectID,sprintf('RecogRegressor%s',subjectID)))==2
                overwrite = input('WARNING: This file already exists \n Would you like to Overwrite it? (y/n)\n','s');
                if overwrite=='n'
                    cd(cwd)
                    return
                else
                    csvwrite(fullfile(saveDir,subjectID,sprintf('RecogRegressor%s',subjectID)),Recognition)
                end
            else
                csvwrite(fullfile(saveDir,subjectID,sprintf('RecogRegressor%s',subjectID)),Recognition)
            end
        end
       
    display(sprintf('Procedure successful for: %s',subjectID));
cd(cwd)
end



function cleanedData = clean(data)
    if ~ischar(data)
        cleanedData = data;
        return
    end
    
    temp = cellstr(data);
    for idx = 1:length(temp)
        if strcmp(temp{idx},'N/A')
            cleanedData(idx,1) = [NaN];
        else
            cleanedData(idx,1) = str2num(temp{idx});
        end
    end
    return
end