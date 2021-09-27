%% Produce a figure of E-field in target ROI containing four histograms with fitted normal probability density functions
% (c) Carys Evans, UCL
% carys.evans@ucl.ac.uk
% October 2019

%This script produces one figure showing the distribution of E-field
%intensity across the sample in the target ROI. Using each
%[simtag]_ROIdata.mat file, the script will plot four histfits - histograms
%with fitted normal probability density functions - of E-field for
%target ROI based on the following current flow models for 1) 1mA
%Fixed-Dose, 2)0.185V/m Individualised-Dose, 3) 2mA Fixed-Dose, 4) 0.369V/m
%Individualised-Dose. This plot will be saved as a 'tif' image file.

%See following paper for rationale for these models and published version
%of this figure: "Evans, C., Bachmann, C., Lee, J. S.,Gregoriou, E., Ward,
%N., & Bestmann, S. (2020). Dose-controlled tDCS reduces electric field
%intensity variability at a cortical target site. Brain stimulation, 13(1),
%125-136."


%% Define file names and locations


%Define folder path where ROI data is stored ('[simtag]_ROIdata.mat' files)
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
root = 'C:\Users\cevans\Desktop\Data\ROIdata\';

%Define output directory where you wish the figure to be saved
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
outputdir = 'C:\Users\cevans\Desktop\Data\ROIdata\';

%Define simtags prefixing '[simtag]_ROIdata.mat' for data being used to plot the figure
simtag = {'CP5FC1_1mA', 'CP5FC1_0185Vm', 'CP5FC1_2mA', 'CP5FC1_0369Vm'};

%Define the name of each histogram to go in the figure legend
%NOTE: The order these are defined should match the order in which each
%plot is listed in the variable 'leglabels'
myPlots = {'1mA', '0.185V/m', '2mA', '0.369V/m'}; 

%Define the name of the plot to be saved as a 'tif' image file
plotName = 'eFieldIntensity_targetROI';

%% Generate variable containing emag files used in analyses (to be used in SPM matlabbatch)


%Changes directory to where [simtag]_ROIdata.mat files are located
cd(root)

%Saves data from each [simtag]_ROIdata.mat file into one structured
%variable
for i = 1:length(simtag)
    load([simtag{i}, '_ROIdata.mat']);
    Data.Models{i} = simtag{i};
    Data.Efield{i} = ROIdata;
    Data.ROI{i} = ROI_locations;
end


%% Plots & settings for: Fixed-Dose (e.g. 1mA) and Individualised-Dose equivalent to Fixed-Dose (e.g. 0.185V/m)


%Plots histogram with fitted normal probability density function for Fixed-Dose
mA1 = histfit(Data.Efield{1,1}(:,1));
hold on;

%Plots histogram with fitted normal probability density function for Individualised-Dose
Vm1 = histfit(Data.Efield{1,2}(:,1));

%Set style and colour for each histogram and normal probability density function
set(mA1(1),'DisplayName','1mA','FaceAlpha',0.6,...
    'FaceColor',[0.301960796117783 0.745098054409027 0.933333337306976], 'EdgeColor', 'none');
set(mA1(2), 'Color', [.2 .2 .2], 'LineWidth', 3);

set(Vm1(1),'DisplayName','0.185V/m','FaceAlpha',0.8,...
    'FaceColor',[0.494117647409439 0.184313729405403 0.556862771511078], 'EdgeColor', 'none');
set(Vm1(2), 'Color', [.2 .2 .2], 'LineWidth', 3);


%% Plots & settings for: Fixed-Dose (e.g. 2mA) and Individualised-Dose equivalent to Fixed-Dose (e.g. 0.369V/m)


%Plots histogram with fitted normal probability density function for Fixed-Dose
mA2 = histfit(Data.Efield{1,3}(:,1));
hold on;

%Plots histogram with fitted normal probability density function for Individualised-Dose
Vm2 = histfit(Data.Efield{1,4}(:,1));

%Set style and colour for each histogram and normal probability density function
set(mA2(1),'DisplayName','2mA','FaceAlpha',0.6,...
    'FaceColor',[0.23137255012989 0.709803938865662 0.372549027204514], 'EdgeColor', 'none');
set(mA2(2), 'Color', [.2 .2 .2], 'LineWidth', 3);

set(Vm2(1),'DisplayName','0.369V/m','FaceAlpha',0.8,...
    'FaceColor',[0.87058824300766 0.490196079015732 0], 'EdgeColor', 'none');
set(Vm2(2), 'Color', [.2 .2 .2], 'LineWidth', 3);


%% Set style for figure axes and size 


%Set style for figure axes
xlabel('Intensity (V/m)');                                  %x axis title
ylabel('Frequency');                                        %y axis title
ylim([0 20]);                                               %y axis limits
xlim([0 0.7]);                                              %x axis limits
set(gca,'linewidth',4)                                      %axes line width

%Set style for figure size 
box off                                                     %remove outter box from figure
set(gca, 'PlotBoxAspectRatio', [1.6 0.5 0.5]);              %alter ratio of x, y, z axes
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);%change size of figure window to fill screen
%set(gca,'ytick',[]);                                       %remove ticks from y axis
%set(gca,'yticklabel',[]);                                  %remove labels from y axis
set(gca,'TickLength',[0 20]);                               %keep tick labels, remove tick
set(gca, 'FontSize', 26);                                   %change font size


%% Create a figure legend

%Set the order in which each plot will be listed in the legend
leglabels = [mA1(1), Vm1(1), mA2(1), Vm2(1)];

%Set the name for each legend
legend(leglabels, myPlots);

%Remove box surrounding legend
legend('boxoff');

%Set the location of the legend relative to the plot
set(legend,'Orientation','horizontal','Location','northoutside');

%% Save the figure

%Plot is saved as a tif file in specified directory
saveas(gca, fullfile(outputdir, plotName), 'tif');

