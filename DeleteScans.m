function DeleteScans()
subs = [201,202,210,215,219,301:305,307:309,311,315:322,324,325,330];
PreProcessing = fMRI_Preprocessing(subs,'4D');

for s_idx = 1:length(PreProcessing.sub)
    subfunc_DeleteScans(PreProcessing, PreProcessing.Subject(s_idx))
end
end


function subfunc_DeleteScans(fmr, sub)
            cmd = sprintf('rm %s',[strjoin(cellstr(sub.Scans.Functional.realignedScans'))]);
            system(cmd);
            cmd = sprintf('rm %s',[strjoin(cellstr(sub.Scans.Functional.NormalizedScans'))]);
            system(cmd);
        
        for i = 1:length(fmr.runs)
            filename1 = [sub.Scans.Functional.(fmr.runs{i}).rawScans{1,1}(1:end-10) '_4D.nii'];
            %filename2 = [sub.Scans.Functional.(fmr.runs{i}).rawScans{1,1}(1:end-10) '_mask.nii.gz'];
            filename3 = [sub.Scans.Functional.(fmr.runs{i}).rawScans{1,1}(1:end-10) '_wholeBrain.nii'];
            cmd = sprintf('rm %s %s %s',filename1, filename3);
            system(cmd);
        end
        end
