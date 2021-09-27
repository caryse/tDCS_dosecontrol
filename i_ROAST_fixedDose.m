%% Run ROAST models for all the specified subject files with FIXED Dose
% (c) Carys Evans, UCL 
% carys.evans@ucl.ac.uk
% October 2019

%This script was originally run using using ROASTv2.7
%(https://www.parralab.org/roast/), but should also work on later versions
%of ROAST.

%The specified protocol applies a FIXED DOSE of tDCS to 50 MRI scans. File
%names and locations will need to be altered when using other computers.
%The ROAST protocol can be altered to meet your desired specifications. See
%README file included with ROAST for a detailed description of the ROAST
%'recipe' used here and other options available.


%% Define file names and locations

%Define folder path where MRI scans are located 
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
root    = 'D:\CFM_DirectionStudy\Models\';  

%Define individual scans being modelled (e.g. subject1.nii), excluding file
%extension '.nii'.  Scans need to be in the same folder.
subj = {...%'subject1',	'subject2',	'subject3',	'subject4',	'subject5',	'subject6',	'subject7',	'subject8',...
   % 'subject9',	'subject10',	'subject11',	'subject12',	'subject13',	'subject14',	'subject15'};%,...
   	'subject16', 'subject17', 'subject19',	'subject20',	'subject21',	...
    'subject23',	'subject24',	'subject25',	'subject26',	'subject27',    'subject28',    'subject29',...
    'subject30',	'subject31',	'subject32',	'subject33',	'subject34',	'subject35',	'subject36',...
    'subject37',	'subject38',	'subject39',	'subject40',	'subject41',	'subject42',	'subject43',...
    'subject44',	'subject45',	'subject46',	'subject47',	'subject48',	'subject49',	'subject50',...
    'subject51',	'subject52'};

%Define tag to identify simulation. This will be applied to files generated
%by ROAST.
simtag = 'CPZFC3_2mA'; 

%% Run current flow models

%Define ROAST protocol that will be applied to each individual scan
for i = 1:length(subj)
    
    %ROAST protocol: 1mA over CP5 (anode); 1mA over FC1 (cathode). MR
    %images are resampled to 1mm isotropic resolution. zeroPadding extends
    %input MRI by 30 slices in each direction to avoid complications when
    %electrodes are placed on image boundaries
    roast(([root,subj{i},'.nii']),{'CPz',2,'FC3',-2}, 'simulationTag', sprintf(simtag), 'elecsize', [17 2]);
    
    %close figures produced by ROAST
    close all
end
