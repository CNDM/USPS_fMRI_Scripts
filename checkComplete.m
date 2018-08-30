function complete = checkComplete(sub,progress,task)
%%%%% INPUT: subID (int), progress file (.mat), task (string)
%%%%% OUTPUT: 1 = complete, 0 = not complete, -1 = not found (error)

%%%%% Given the subject id, progress.mat file, and task, it will let you
%%%%% know if a given step has been completed for that subject. To be used
%%%%% in conjunction with the fMRI_Analysis scripts

    sub_idx = find(progress.Subject==sub);
    if sub_idx == isempty(sub_idx)
        print 'Subject ID Not found in progress file'
        complete = -1;
        return
    end
    try
        complete = progress.(task)(sub_idx);
        return
    catch ME
        switch ME.identifier
        case 'MATLAB:nonExistentField'
            complete = -1;
            warning('Task is not defined in the progress file');
        otherwise
            rethrow(ME)
    end
    end

end