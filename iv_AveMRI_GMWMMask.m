%% Create Average Structural MR Image across all individuals & a Binary Grey & White Matter Mask for analysis
% (c) Carys Evans, UCL 
% carys.evans@ucl.ac.uk
% October 2019

%This script requires SPM12

% To run this script MR images must have already been converted from native
% to standard space. This script creates:
% i) an average structural MR image of all individuals, which provides a
% useful anatomical template for visualising data: 'AllPTs_Structural.nii'
% ii) a binary grey and white matter mask based on the average structural
% image that can be applied when extracting E-field only from within the
% brain: 'GMWMBinaryMask.nii'

%% Define file names and locations

%Define folder path where MRI scans are located 
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
root    = 'C:\Users\cevans\Desktop\Data\';  

%Define individual scans being averaged (e.g. subject1.nii), excluding file
%extension '.nii'.  Scans need to be in the same folder.
subj = {'subject1',	'subject2',	'subject3',	'subject4',	'subject5',	'subject6',	'subject7',	'subject8',...
    'subject9',	'subject10',	'subject11',	'subject12',	'subject13',	'subject14',	'subject15',...
    'subject16',	'subject17',	'subject18',	'subject19',	'subject20',	'subject21',	...
    'subject23',	'subject24',	'subject25',	'subject26',	'subject27',    'subject28',    'subject29',...
    'subject30',	'subject31',	'subject32',	'subject33',	'subject34',	'subject35',	'subject36',...
    'subject37',	'subject38',	'subject39',	'subject40',	'subject41',	'subject42',	'subject43',...
    'subject44',	'subject45',	'subject46',	'subject47',	'subject48',	'subject49',	'subject50',...
    'subject51',	'subject52',	'subject53'};

%Define output directory for generated files
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
outputdir = 'C:\Users\cevans\Desktop\Data\masks\';

%Define file path for Tissue Probability Map used by SPM during
%normalisation. TPM.nii is found in spm folder: spm12\tpm\TPM.nii.
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
tpm = 'C:\Users\cevans\Documents\spm12\tpm\TPM.nii';

%% Generate a variable containing structural MR images being averaged (to be used in SPM matlabbatch)

for i = 1:length(subj)
    myscans(i,1) = {[root,sprintf('w%s.nii',subj{i}),',1']}; %Normalised structural images. IF YOU CHANGED THE PREFIX FOR NORMALISED IMAGES CHANGE THE PREFIX HERE AS WELL (current prefix 'w') 
end

%% Average Structural MRIs

spm('defaults', 'FMRI');
spm_jobman('initcfg')

matlabbatch{1}.spm.util.imcalc.input = myscans;                 %Variable defining scans being averaged
matlabbatch{1}.spm.util.imcalc.output = 'AllPTs_Structural';    %Filename of Average Structural MR Image
matlabbatch{1}.spm.util.imcalc.outdir = root;
matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)';          %Averages images
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = -7;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

%If you only wish to create an Average Structural MRI, uncomment the line
%below and run the script up until this point:
%spm_jobman('run',matlabbatch);     

%% Segment average MR image into 6 tissues: grey matter, white matter, CSF, bone, soft tissue, air/background

matlabbatch{2}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Image Calculator: ImCalc Computed Image: AllPTs_Structural', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{2}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{2}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(1).tpm = {[tpm,',1']};
matlabbatch{2}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{2}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(2).tpm = {[tpm,',2']};
matlabbatch{2}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{2}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(3).tpm = {[tpm,',3']};
matlabbatch{2}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{2}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(4).tpm = {[tpm,',4']};
matlabbatch{2}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{2}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(5).tpm = {[tpm,',5']};
matlabbatch{2}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{2}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{2}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(6).tpm = {[tpm,',6']};
matlabbatch{2}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{2}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{2}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{2}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{2}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{2}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{2}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{2}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{2}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{2}.spm.spatial.preproc.warp.write = [0 0];

%% Create Binary Grey Matter Mask

matlabbatch{3}.spm.util.imcalc.input(1) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
matlabbatch{3}.spm.util.imcalc.output = 'GMBinary';         %Filename of GM Binary Image
matlabbatch{3}.spm.util.imcalc.outdir = outputdir;          %Output Directory for image
matlabbatch{3}.spm.util.imcalc.expression = 'i1>0.0';
matlabbatch{3}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{3}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{3}.spm.util.imcalc.options.mask = 0;
matlabbatch{3}.spm.util.imcalc.options.interp = 1;
matlabbatch{3}.spm.util.imcalc.options.dtype = 4;

%% Create Binary White Matter Mask

matlabbatch{4}.spm.util.imcalc.input(1) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
matlabbatch{4}.spm.util.imcalc.output = 'WMBinary';         %Filename of WM Binary Image
matlabbatch{4}.spm.util.imcalc.outdir = outputdir;          %Output Directory for image
matlabbatch{4}.spm.util.imcalc.expression = 'i1>0.0';
matlabbatch{4}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{4}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{4}.spm.util.imcalc.options.mask = 0;
matlabbatch{4}.spm.util.imcalc.options.interp = 1;
matlabbatch{4}.spm.util.imcalc.options.dtype = 4;

%% Combine Binary Grey and White Matter Masks to create one GMWM Mask

matlabbatch{5}.spm.util.imcalc.input(1) = cfg_dep('Image Calculator: ImCalc Computed Image: GMBinary', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{5}.spm.util.imcalc.input(2) = cfg_dep('Image Calculator: ImCalc Computed Image: WMBinary', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{5}.spm.util.imcalc.output = 'GMWMBinaryMask';   %Filename of GMWM Binary Mask
matlabbatch{5}.spm.util.imcalc.outdir = outputdir;          %Output Directory for image
matlabbatch{5}.spm.util.imcalc.expression = '(i1+i2)>0.0';
matlabbatch{5}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{5}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{5}.spm.util.imcalc.options.mask = 0;
matlabbatch{5}.spm.util.imcalc.options.interp = 1;
matlabbatch{5}.spm.util.imcalc.options.dtype = 4;

spm_jobman('run',matlabbatch);
