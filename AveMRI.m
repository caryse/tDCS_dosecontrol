%% Create Average Structural MR Image across all individuals
% (c) Carys Evans, UCL 
% carys.evans@ucl.ac.uk
% October 2019

%This script requires SPM12

%In order to create the average structural MRI, scans must first be
%converted from native to standard space. This script creates an anatomical
%template in order to visualise data, by averaging structural MR images of
%all individuals. The average image is saved under the name
%"AllPTs_Structural.nii".

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

%% Generate variable containing structural MRI images being averaged (to be used in SPM matlabbatch)
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

spm_jobman('run', matlabbatch);
