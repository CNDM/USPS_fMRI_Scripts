function fmr=fmr_Reorient4D(fmr,sub)
    cwd = pwd;
    orientation_matrix = tdfread([fmr.baseDir '/Reorientation_parameters.txt'])
    subIDX = find(orientation_matrix.Subject==str2num(sub.subID));
    progress_sidx = find(fmr.Progress.Subject==str2num(sub.subID));
    
    if isempty(subIDX)
        sprintf('WARNING: SUBJECT %s NOT FOUND',sub.subID)
        return
    end
    
    if isnan(orientation_matrix.x(subIDX))
        sprintf('WARNING: REORIENTATION PARAMETERS NOT FOUND FOR SUBJECT %s',sub.subID)
        return
    end
    
    
    params = [orientation_matrix.x(subIDX) orientation_matrix.y(subIDX) orientation_matrix.z(subIDX)]';
        cd(sub.Scans.Anatomical.directory);
        reorientOrigin(sub.Scans.Anatomical.scan,params);
        for i = 1:length(fmr.runs)
            reorientOrigin(sub.Scans.Functional.(fmr.runs{i}).rawScans,params);
        end
        fmr.Progress.ReorientOrigin(progress_sidx) = 1;
    cd(cwd)
end

    function reorientOrigin(filename, parameters)
    if ~iscell(filename)
        st.vol = spm_vol(filename);
        st.vol.mat(1:3,4) = st.vol.mat(1:3,4) + parameters;
        spm_get_space(filename,st.vol.mat)
    else
        for i = 1:length(filename)
            st.vol = spm_vol(filename{i});
            st.vol.mat(1:3,4) = st.vol.mat(1:3,4) + parameters;
            spm_get_space(filename{i},st.vol.mat);
        end
    end
    end
    
    
    
    
    
    