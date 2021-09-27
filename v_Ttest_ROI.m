%% Run one-sample t-test & extract eigenvariates from ROIs
% (c) Carys Evans, UCL
% carys.evans@ucl.ac.uk
% October 2019

%This script requires SPM12

%Run this script on the smoothed normalised emag files. This script runs a
%one-sample t-test on the E-field magnitude images. The script also
%extracts the eigenvariates from the target ROI and additional ROIs,
%including an ROI where the global maximum is located (i.e. the statistical
%maximum with least variance in E-field).

%T-test: one-sample t-test analysis with family-wise error correction at an
%alpha cut-off of 0.05 identifies brain regions where E-field is
%significantly above zero.

%Eigenvariates: these were extracted from each ROI to assess variance in
%E-field intensity in these regions between individuals. The eigenvariate
%values can be found in Y variable of the VOI_[ROI].mat files produced by
%this script. These values will also be saved in a separate
%[simtag]_ROIdata.mat file with the following label: '[simtag]_ROIdata.mat'

%ROIs: centre of each ROI is defined using MNI coordinates. The ROI is a
%sphere (5mm radius). In current example, target ROI is left M1 (MNI: -38
%-20 50). Additional ROIs: anode (left AnG; -54 -46 22), cathode (left PMC;
%-24 -4 66), contralateral right M1 (MNI: 38 -18 48), and region where
%global maximum is located


%% Define file names and locations
%FILE NAMES MUST MATCH THOSE USED IN ROAST MODELS

%Define folder path where emag (E-field magnitude) images are located 
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
root    = 'C:\Users\cevans\Desktop\Data\';

%Define individual scans being used in analysis (e.g. subject1.nii),
%excluding file extension '.nii'.  Scans need to be in the same folder.
subj = {'subject1',	'subject2',	'subject3',	'subject4',	'subject5',	'subject6',	'subject7',	'subject8',...
    'subject9',	'subject10',	'subject11',	'subject12',	'subject13',	'subject14',	'subject15',...
    'subject17',	'subject18',	'subject19',	'subject20',	'subject21',	...
    'subject23',	'subject24',	'subject25',	'subject26',	'subject27',    'subject28',    'subject29',...
    'subject30',	'subject31',	'subject32',	'subject33',	'subject34',	'subject35',	'subject36',...
    'subject37',	'subject38',	'subject39',	'subject40',	'subject41',	'subject42',	'subject43',...
    'subject44',	'subject46',	 'subject47',	'subject48',	'subject49',	'subject50',...
    'subject51',	'subject52',	'subject53'};

%Define tag used by ROAST to identify simulation
simtag = 'CP5FC1_1mA'; 

%Define file path for Grey-White Matter Binary Mask
GMWMmask = 'C:\Users\cevans\Desktop\Data\masks\GMWMBinaryMask.nii'; %Alternative: use ICV explicit mask (GM/WM/CSF mask)included in SPM (spm12\tpm\mask_ICV.nii)

%Define ROIs to extract data from:
%Target
targetROI = [-38 -20 50];       %MNI coordinates for cortical target ROI
tnameROI = 'LM1';               %Target ROI name
radROI = 5;                     %ROI sphere radius (mm)

%Cortex underneath anode
anodeROI = [-54 -46 22];
anameROI = 'leftAnG';

%Cortex underneath cathode
cathodeROI = [-24 -4 66];
cnameROI = 'leftPMC';

%Contralateral M1
contROI = [38 -18 48];
conameROI = 'RM1';

%Define output directory for ROI data file '[simtag]_ROIdata.mat'
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
outputdir = 'C:\Users\cevans\Desktop\Data\ROIdata\';

%% Generate variable containing emag files used in analyses (to be used in SPM matlabbatch)
for i = 1:length(subj)
    myscans(i,1) = {[root,sprintf('sw%s_%s_emag.nii',subj{i},simtag),',1']}; %Smoothed/Normalised E-field images. IF YOU CHANGED THE PREFIX FOR SMOOTHED/NORMALISED IMAGES CHANGE THE PREFIX HERE AS WELL (current prefix 'sw')
end

%% Run one-sample t-test through SPM

spm('defaults', 'FMRI');
spm_jobman('initcfg')

%Specify 2nd-level analysis
matlabbatch{1}.spm.stats.factorial_design.dir = {root};   %File directory

%Select files from variable generated above
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = myscans;   

%Factorial design specifications
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {[GMWMmask,',1']};  %Apply Grey-White Matter Binary Mask
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

%Model estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));   %calls SPM file generated above
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 't';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;

%Define contast (i.e. one-sample t-test with family-wise error correction)
matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
matlabbatch{4}.spm.stats.results.conspec.contrasts = 1;         %Specifies one-sample t-test
matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'FWE';    %Family-wise error correction
matlabbatch{4}.spm.stats.results.conspec.thresh = 0.05;         %Alpha threshold 0.05
matlabbatch{4}.spm.stats.results.conspec.extent = 0;
matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.ps = true;


%=============================================================================================================
%% Extract eigenvariates from target region of interest (left M1)
matlabbatch{5}.spm.util.voi.spmmat = {[root,'SPM.mat']};
matlabbatch{5}.spm.util.voi.adjust = 0;
matlabbatch{5}.spm.util.voi.session = 1;
matlabbatch{5}.spm.util.voi.name = tnameROI;                             %Target ROI name (defined above)
matlabbatch{5}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{5}.spm.util.voi.roi{1}.spm.contrast = 1;
matlabbatch{5}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{5}.spm.util.voi.roi{1}.spm.threshdesc = 'FWE';
matlabbatch{5}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{5}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{5}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{5}.spm.util.voi.roi{2}.sphere.centre = targetROI;            %Target ROI defined by MNI coordinates (defined above)
matlabbatch{5}.spm.util.voi.roi{2}.sphere.radius = radROI;               %ROI sphere radius (mm) (defined above)
matlabbatch{5}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{5}.spm.util.voi.expression = 'i1 & i2';


%% Extract eigenvariates from other regions of interest 
%ROIs: anode (leftAnG); cathode(leftPMC); right M1

%anode (leftAnG)
matlabbatch{6}.spm.util.voi.spmmat = {[root,'SPM.mat']};
matlabbatch{6}.spm.util.voi.adjust = 0;
matlabbatch{6}.spm.util.voi.session = 1;
matlabbatch{6}.spm.util.voi.name = anameROI;
matlabbatch{6}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{6}.spm.util.voi.roi{1}.spm.contrast = 1;
matlabbatch{6}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{6}.spm.util.voi.roi{1}.spm.threshdesc = 'FWE';
matlabbatch{6}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{6}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{6}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{6}.spm.util.voi.roi{2}.sphere.centre = anodeROI;
matlabbatch{6}.spm.util.voi.roi{2}.sphere.radius = radROI;
matlabbatch{6}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{6}.spm.util.voi.expression = 'i1 & i2';

%right M1
matlabbatch{7}.spm.util.voi.spmmat = {[root,'SPM.mat']};
matlabbatch{7}.spm.util.voi.adjust = 0;
matlabbatch{7}.spm.util.voi.session = 1;
matlabbatch{7}.spm.util.voi.name = conameROI;
matlabbatch{7}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{7}.spm.util.voi.roi{1}.spm.contrast = 1;
matlabbatch{7}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{7}.spm.util.voi.roi{1}.spm.threshdesc = 'FWE';
matlabbatch{7}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{7}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{7}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{7}.spm.util.voi.roi{2}.sphere.centre = contROI;
matlabbatch{7}.spm.util.voi.roi{2}.sphere.radius = radROI;
matlabbatch{7}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{7}.spm.util.voi.expression = 'i1 & i2';

%cathode (left PMC)
matlabbatch{8}.spm.util.voi.spmmat = {[root,'SPM.mat']};
matlabbatch{8}.spm.util.voi.adjust = 0;
matlabbatch{8}.spm.util.voi.session = 1;
matlabbatch{8}.spm.util.voi.name = cnameROI;
matlabbatch{8}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{8}.spm.util.voi.roi{1}.spm.contrast = 1;
matlabbatch{8}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{8}.spm.util.voi.roi{1}.spm.threshdesc = 'FWE';
matlabbatch{8}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{8}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{8}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{8}.spm.util.voi.roi{2}.sphere.centre = cathodeROI;
matlabbatch{8}.spm.util.voi.roi{2}.sphere.radius = radROI;
matlabbatch{8}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{8}.spm.util.voi.expression = 'i1 & i2';


spm_jobman('run', matlabbatch);

%% Extract values from cortical region with global maximum (i.e. the statistical maximum with least variance in E-field)

%Save MNI coordinates for global maximum 
GMcoord = TabDat.dat{1,12}';    %TabDat.dat contains MNI coordinates for region with global maximum (GM)
save('GM.mat', 'GMcoord');      %Saves GM coordinates into mat file GM.mat

clear matlabbatch

%Extract values from GM ROI 
spm('defaults', 'FMRI');
spm_jobman('initcfg')

load('GM.mat')

matlabbatch{1}.spm.util.voi.spmmat = {[root,'SPM.mat']};
matlabbatch{1}.spm.util.voi.adjust = 0;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = 'GM';
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''};
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.conjunction = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'FWE';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = 0.05;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0;
matlabbatch{1}.spm.util.voi.roi{1}.spm.mask = struct('contrast', {}, 'thresh', {}, 'mtype', {});
matlabbatch{1}.spm.util.voi.roi{2}.sphere.centre = GMcoord;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.radius = radROI;
matlabbatch{1}.spm.util.voi.roi{2}.sphere.move.fixed = 1;
matlabbatch{1}.spm.util.voi.expression = 'i1 & i2';

spm_jobman('run', matlabbatch);

%% Save ROI E-field data to new file and move to output directory

%Puts all ROI names into one variable
ROI_locations = {tnameROI, anameROI, cnameROI, conameROI, 'GM'};

%Transpose subject variable
subj = subj';

%Open each VOI_[ROI].mat file and save Y variable (E-field values for all
%individuals) in one variable 'ROIdata'
for i = 1:length(ROI_locations)
    load(['VOI_', ROI_locations{i}, '.mat'], 'Y');
    ROIdata(:,i) = Y;
end

%Save ROIdata variable as new .mat file prefixed by simulation tag.
save([simtag, '_ROIdata.mat'], 'ROI_locations', 'ROIdata', 'subj');

%Move [simtag]_ROIdata.mat file to output directory
movefile([simtag, '_ROIdata.mat'], outputdir);
