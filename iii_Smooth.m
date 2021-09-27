%% Smooth electric field magnitude images for each individual
% (c) Carys Evans, UCL
% carys.evans@ucl.ac.uk
% October 2019

%This script requires SPM12

%To run this script, make sure you have normalised the E-field magnitude
%(emag) images first. This scripts smooths the normalised E-field
%magnitude images using a 4mm smoothing kernel. 


%% Define file names and locations 
%FILE NAMES MUST MATCH THOSE USED IN ROAST MODELS

%Define folder path where MRI scans are located 
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
root    = 'C:\Users\cevans\Desktop\Data\';

%Define individual normalised scans being smoothed (e.g. subject1.nii),
%excluding file extension '.nii'.  Scans need to be in the same folder.
subj = {'subject1',	'subject2',	'subject3',	'subject4',	'subject5',	'subject6',	'subject7',	'subject8',...
    'subject9',	'subject10',	'subject11',	'subject12',	'subject13',	'subject14',	'subject15',...
    'subject16',	'subject17',	'subject18',	'subject19',	'subject20',	'subject21',	...
    'subject23',	'subject24',	'subject25',	'subject26',	'subject27',    'subject28',    'subject29',...
    'subject30',	'subject31',	'subject32',	'subject33',	'subject34',	'subject35',	'subject36',...
    'subject37',	'subject38',	'subject39',	'subject40',	'subject41',	'subject42',	'subject43',...
    'subject44',	'subject45',	'subject46',	'subject47',	'subject48',	'subject49',	'subject50',...
    'subject51',	'subject52',	'subject53'};

%Define tag used by ROAST to identify simulation
simtag = 'CP5FC1_1mA'; 

%% Smooth each individual's normalised emag (E-field magnitude) image
for i = 1:length(subj)
    spm('defaults', 'FMRI');
    cd(root)
    spm_jobman('initcfg')
 
    matlabbatch{1}.spm.spatial.smooth.data = {[root, sprintf('w%s_%s_emag.nii', subj{i}, simtag) ',1']}; %Smooth emag image. IF YOU CHANGED THE PREFIX FOR NORMALISED IMAGES CHANGE THE PREFIX HERE AS WELL (current prefix is 'w')
    matlabbatch{1}.spm.spatial.smooth.fwhm = [4 4 4];   %Applies a 4mm smoothing kernel. Can be changed as desired
    matlabbatch{1}.spm.spatial.smooth.dtype = 0;
    matlabbatch{1}.spm.spatial.smooth.im = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';     %File prefix for Smoothed images. Can be changed as desired 

    spm_jobman('run', matlabbatch);
end

