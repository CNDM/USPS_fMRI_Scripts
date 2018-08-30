function fmr = fmr_BrainExtraction(fmr,sub)
    cwd=pwd;
    
        %Anatomical First
        BrainExtract(sub.Scans.Anatomical,'Anatomical')


        %Now let's try the functionals...
%         for i = 1:length(fmr.runs)
%             BrainExtract(sub.Scans.Functional.(fmr.runs{i}),'Functional')
%         end

    cd(cwd);
end

function BrainExtract(scan,type)
    switch type
        case 'Anatomical'
            options = '-R -f 0.35 -g 0';
            scanPath = scan.scanPath;
        case 'Functional'
            options = '-F -f 0.35 -g 0';
            scanPath = scan.rawScans{:};
            cmd4 = sprintf('rm %s', [scanPath(1:-4) '.mat'])
            cmd5 = sprintf('rm %s', [scanPath(1:-4) '_mask.nii.gz'])
    end
    cd(scan.directory);
    cmd1 = sprintf('bet %s %s %s', ...
        scanPath, ...
        scanPath, ...
        options);
    cmd2 = sprintf('mv %s %s', ...
        scanPath,...
        [scanPath(1:end-4) '_wholeBrain.nii']);
    cmd3 = sprintf('gunzip -f %s',...
        [scanPath '.gz']);
    system(cmd1);
    system(cmd2);
    system(cmd3);
    if type == 'Functional'
        system(cmd4);
        system(cmd5);
    end
end
    