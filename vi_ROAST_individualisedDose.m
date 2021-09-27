%% Calculate INDIVIDUALISED Dose and run ROAST models for all the specified subject files
% (c) Carys Evans, UCL
% carys.evans@ucl.ac.uk
% October 2019

%This script was originally run using ROASTv2.7
%(https://www.parralab.org/roast/), but should also work on later versions
%of ROAST.

%The specified protocol applies an INDIVIDUALISED DOSE of tDCS to 50 MRI
%scans. File names and locations will need to be altered when using other
%computers. The ROAST protocol can be altered to meet your desired
%specifications. See README file included with ROAST for a detailed
%description of the ROAST 'recipe' used here and other options available.

%See following paper for rationale for applying an individualised-dose of
%tDCS: "Evans, C., Bachmann, C., Lee, J. S.,Gregoriou, E., Ward, N., &
%Bestmann, S. (2020). Dose-controlled tDCS reduces electric field intensity
%variability at a cortical target site. Brain stimulation, 13(1), 125-136."


%% Define file names and locations

%Define folder path where MRI scans/t-test results are located
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
root = 'C:\Users\cevans\Desktop\Data\';

%Define folder path where ROAST is located
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
roastroot = 'C:\Users\cevans\Documents\MATLAB\roastV2.7';   

%Define individual scans being modelled (e.g. subject1.nii), excluding file
%extension '.nii'.  Scans need to be in the same folder.
subj = {'subject1',	'subject2',	'subject3',	'subject4',	'subject5',	'subject6',	'subject7',	'subject8',...
    'subject9',	'subject10',	'subject11',	'subject12',	'subject13',	'subject14',	'subject15',...
    'subject17',	'subject18',	'subject19',	'subject20',	'subject21',	...
    'subject23',	'subject24',	'subject25',	'subject26',	'subject27',    'subject28',    'subject29',...
    'subject30',	'subject31',	'subject32',	'subject33',	'subject34',	'subject35',	'subject36',...
    'subject37',	'subject38',	'subject39',	'subject40',	'subject41',	'subject42',	'subject43',...
    'subject44',	'subject46',	 'subject47',	'subject48',	'subject49',	'subject50',...
    'subject51',	'subject52',	'subject53'};

%Define tag to identify simulation. This will be applied to files generated
%by ROAST.
simtag = 'CP5FC1_0185Vm';

%Define output directory for stimulator output data file
%'[simtag]_StimOutput.mat'
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
outputdir = 'C:\Users\cevans\Desktop\Data\ROIdata\';

%% Define target E-field intensity in cortical target region based on data from fixed-dose models
%REQUIRES FIXED-DOSE MODELS AND T-TEST ANALYSIS TO HAVE BEEN COMPLETED

%Navigate to folder within which t-test results were saved
cd(root)    

%Load target ROI E-field magnitude across sample. VOI_LM1.mat was produced
%in one-sample t-test script: 'iv_OneSampleTtest_ROIdataextraction.mat'
load('VOI_LM1.mat');	%CHANGE IF USED DIFFERENT TARGET ROI

%Define fixed-dose applied in initial ROAST models (1=1mA)
fixedDose = 1;

%Define E-field intensity in target region for each individual 
fixedInt = Y;   %Values taken from VOI_LM1.mat   

%Define target E-field in target cortical area. 
targetInt = mean(Y);    %Currently target E-field = sample average (0.185V/m). Alternative: change to desired intensity in target cortical area, e.g. targetInt = 0.185                                
                                                                                     

%% Calculate the individualised stimulator output to obtain target E-field intensity in cortical target region

% In this example, the target intensity is the sample average in left M1
% when 1mA applied; target region is left M1

for i = 1:length(fixedInt)
    
    %Applies equation to determine individualised-dose (i.e. stimulator
    %output for each individual)
    indivDose(i,1) = (targetInt/fixedInt(i,1))* fixedDose;  %Indivualised Dose = (Target Intensity in target ROI / Actual Intensity in target ROI)*Fixed Dose
                                     
    %Rounds individualised-dose to nearest 0.025mA (to adhere to parameter limitations of NeuroConn DC-Stimulator)
    rindivDose(i,1) = round(indivDose(i,1)*40)/40;  %OPTIONAL
    
end

%Saves MR image and individualised-doses into mat file Indiv_Dose.mat
save([simtag, '_StimOutput.mat'], 'subj', 'rindivDose','fixedDose','targetInt');

%Move [simtag]_StimOutput.mat file to output directory
movefile([simtag, '_StimOutput.mat'], outputdir);

%==============================================================================================================================
%% Run current flow models

%Navigate to ROAST folder
cd(roastroot)

%Define ROAST protocol that will be applied to each individual scan
for i = 1:length(subj)

    %ROAST protocol: INDIVIDUALISED DOSE over CP5 (anode) and FC1
    %(cathode). MR images are resampled to 1mm isotropic resolution.
    %zeroPadding extends input MRI by 30 slices in each direction to avoid
    %complications when electrodes are placed on image boundaries
    roast(([root,subj{i},'.nii']),{'CP5',rindivDose(i,1),'FC1',(rindivDose(i,1)*-1)}, 'simulationTag', simtag, 'resampling', 'on', 'zeroPadding', 30); 
    
    %close figures produced by roast
    close all
end