%% Produce a figure of Stimulator Output required per individual to fix intensity at cortical target
% (c) Carys Evans, UCL
% carys.evans@ucl.ac.uk
% October 2019

%This script produces one figure showing the distribution of Stimulator
%Output across the sample when dose-controlling to fix E-field intensity in
%the cortical target ROI. Using each [simtag]_StimOutput.mat file, the
%script will plot four histfits - histograms with fitted normal probaility
%density functions - of Stimulator Output based on the following current
%flow models: 1) 1mA Fixed-Dose, 2)0.185V/m Individualised-Dose, 3) 2mA
%Fixed-Dose, 4) 0.369V/m Individualised-Dose. This plot will be saved as a
%'tif' image file.

%See following paper for published version of this figure: "Evans, C.,
%Bachmann, C., Lee, J. S.,Gregoriou, E., Ward, N., & Bestmann, S. (2020).
%Dose-controlled tDCS reduces electric field intensity variability at a
%cortical target site. Brain stimulation, 13(1), 125-136."

%% Define file names and locations


%Define folder path where ROI data is stored ('[simtag]_StimOutput.mat'
%files) THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
root = 'C:\Users\cevans\Desktop\Data\ROIdata\';

%Define output directory where you wish the figure to be saved
%THIS WILL NEED TO BE CHANGED ON ANOTHER COMPUTER
outputdir = 'C:\Users\cevans\Desktop\Data\ROIdata\';

%Define simtags prefixing '[simtag]_StimOutput.mat' for data being used to
%plot the figure
simtag = {'CP5FC1_0185Vm', 'CP5FC1_0369Vm'};

%Define the name of each histogram to go in the figure legend
%NOTE: The order these are defined should match the order in which each
%plot is listed in the variable 'leglabels'
myPlots = {'1mA', '0.185V/m', '2mA', '0.369V/m'}; 

%Define the name of the plot to be saved as a 'tif' image file
plotName = 'eFieldIntensity_targetROI';

%% Generate variable containing emag files used in analyses (to be used in SPM matlabbatch)


%Changes directory to where [simtag]_StimOutput.mat files are located
cd(root)

%Saves data from each [simtag]_StimOutput.mat file into one structured
%variable
for i = 1:length(simtag)
    load([simtag{i}, '_StimOutput.mat']);
    Data.Models{i} = simtag{i};
    Data.StimOutput{i} = rindivDose;
    Data.FixedDose{i} = fixedDose;
end


%% Plots & settings for Individualised-Doses equivalent to Fixed-Dose (e.g. 0.185V/m)


%Plots histogram with fitted normal probability density function for Individualised-Dose
Vm1 = histfit(Data.StimOutput{1,1}(:,1));
hold on;

%Plots histogram with fitted normal probability density function for Individualised-Dose
Vm2 = histfit(Data.StimOutput{1,2}(:,1));
hold on;


%Set style and colour for each histogram and normal probability density function
set(Vm1(1),'DisplayName','0.185V/m','FaceAlpha',0.6,...
    'FaceColor',[0.494117647409439 0.184313729405403 0.556862771511078], 'EdgeColor', 'none');
set(Vm1(2), 'Color', [.2 .2 .2], 'LineWidth', 3); 


set(Vm2(1),'DisplayName','0.369V/m','FaceAlpha',0.6,...
    'FaceColor',[0.87058824300766 0.490196079015732 0], 'EdgeColor', 'none');
set(Vm2(2), 'Color', [.2 .2 .2], 'LineWidth', 3);

%% Set style for figure axes and size 


%Set style for figure axes
xlabel('Stimulator Output (mA)');                           %x axis title
ylabel('Frequency');                                        %y axis title
ylim([0 12]);                                               %y axis limits 
%xlim([0 0.7]);                                             %x axis limits
set(gca,'linewidth',4)                                      %axes line width

%Set style for figure size 
box off                                                     %remove outter box from figure
set(gca, 'PlotBoxAspectRatio', [1.6 0.5 0.5]);              %alter ratio of x, y, z axes
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);%change size of figure window to fill screen
set(gca,'TickLength',[0 20]);                               %keep tick labels, remove tick
set(gca, 'FontSize', 26);                                   %change font size

%% Plots for Fixed-Doses equivalent to Individualised-Doses


%Plot Fixed-Dose equivalent to the first Individualised-Dose histogram

%Produce a line representing the Fixed-Dose will be plotted that extends
%the maximum length of the y axis.
mA1 = ones(1, max(ylim))*Data.FixedDose{1,1}';

%Set style and colour for each histogram and normal probability density
%function
mA1hist = histogram(mA1,12,'BinLimits',[0.9 1.1],'FaceAlpha',0.6,'FaceColor',[0.301960796117783 0.745098054409027 0.933333337306976], 'EdgeColor', 'none');
hold on;

%Plot Fixed-Dose equivalent to the second Individualised-Dose histogram

%Produce a line representing the Fixed-Dose will be plotted that extends
%the maximum length of the y axis.
mA2 = ones(1, max(ylim))*Data.FixedDose{1,2}';

%Set style and colour for each histogram and normal probability density
%function
mA2hist = histogram(mA2,12,'BinLimits',[1.9 2.1],'FaceAlpha',0.6,'FaceColor',[0.23137255012989 0.709803938865662 0.372549027204514], 'EdgeColor', 'none');


%% Create a figure legend 

%Set the order in which each plot will be listed in the legend
leglabels = [mA1hist, Vm1(1), mA2hist, Vm2(1)]; 

%Set the name for each legend
legend(leglabels, myPlots);

%Remove box surrounding legend
legend('boxoff');

%Set the location of the legend relative to the plot
set(legend,'Orientation','horizontal','Location','northoutside');

%% saving figure

saveas(gca, fullfile(outputdir, plotName), 'tif');
