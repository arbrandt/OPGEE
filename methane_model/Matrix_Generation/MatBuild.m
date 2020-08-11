function [PercentilesEquipment] = MatBuild(ComponentCountsByEquipment, FractionLeaking, size_ppmv)

% NOTE:
% There is a line of code at ~284 which outputs labelled component vectors
% for preparing the component distributions. This code is normally
% suppressed

% How many trials to perform?
Trials = 10000;

%% Import data using external .m file

if size_ppmv == 1   
    load 'SMemitters'; 
else
    load 'LGemitters'; 
end


%% Analyze data

Component = cellstr(Component);
Equipment = cellstr(Equipment);
Study = cellstr(Study);

% Extract data from datafile
StudyName = Study;
StudyEmissions = EmissionsKgD;

%% Create lists of emissions by study
% API 1993
% Allen2013
% Allen2014a
% Bell2017
% ERG2011
% Thoma2017
% Pasci 2019

API1993 = StudyEmissions(find(ismember(StudyName,'API1993')));
API1993 = API1993(isfinite(API1993));

Allen2013 = StudyEmissions(find(ismember(StudyName,'Allen2013')));
Allen2013 = Allen2013(isfinite(Allen2013));

Allen2014a = StudyEmissions(find(ismember(StudyName,'Allen2014a')));
Allen2014a = Allen2014a(isfinite(Allen2014a));

Bell2017 = StudyEmissions(find(ismember(StudyName,'Bell2017')));
Bell2017 = Bell2017(isfinite(Bell2017));

ERG2011 = StudyEmissions(find(ismember(StudyName,'ERG2011')));
ERG2011 = ERG2011(isfinite(ERG2011));

Thoma2017 = StudyEmissions(find(ismember(StudyName,'Thoma2017')));
Thoma2017 = Thoma2017(isfinite(Thoma2017));

Pasci2019 = StudyEmissions(find(ismember(StudyName,'Pasci2019')));
Pasci2019 = Pasci2019(isfinite(Pasci2019));


%% Create lists of emissions for component types
%OTH
%REG
%VL
%TC
%OEL
%PRV
%PC
%CS
%CIP
%TK - H	
%TK-PRV	
%TK-V
%TH

OTH = StudyEmissions(find(ismember(Component,'OTH')));
OTH = OTH(isfinite(OTH));

REG = StudyEmissions(find(ismember(Component,'REG')));
REG = REG(isfinite(REG));

VL = StudyEmissions(find(ismember(Component,'VL')));
VL = VL(isfinite(VL));

TC = StudyEmissions(find(ismember(Component,'TC')+ismember(Component,'F')));
TC = TC(isfinite(TC));

OEL = StudyEmissions(find(ismember(Component,'OEL')));
OEL = OEL(isfinite(OEL));

PRV = StudyEmissions(find(ismember(Component,'PRV')));
PRV = PRV(isfinite(PRV));

PC = StudyEmissions(find(ismember(Component,'PC')));
PC = PC(isfinite(PC));

CS = StudyEmissions(find(ismember(Component,'CS')));
CS = CS(isfinite(CS));

CIP = StudyEmissions(find(ismember(Component,'CIP')));
CIP = CIP(isfinite(CIP));

TK_H = StudyEmissions(find(ismember(Component,'TH')));
TK_H = TK_H(isfinite(TK_H));

TK_P = StudyEmissions(find(ismember(Component,'TP')));
TK_P = TK_P(isfinite(TK_P));

TK_V = StudyEmissions(find(ismember(Component,'TV')));
TK_V = TK_V(isfinite(TK_V));

% ALL = [OTH; REG; VL; TC; OEL; PRV; PC; CS; NR; CIP; TK];

ALL = [OTH; REG; VL; TC; OEL; PRV; PC; CIP; TK_H; TK_P; TK_V];

% Sum results for component types
SumOTH = nansum(OTH);
SumREG = nansum(REG);
SumVL = nansum(VL);
SumTC = nansum(TC);
SumOEL = nansum(OEL);
SumPRV = nansum(PRV);
SumPC = nansum(PC);
SumCS = nansum(CS);
SumCIP = nansum(CIP);
SumTK_H = nansum(TK_H);
SumTK_P = nansum(TK_P);
SumTK_V = nansum(TK_V);
SumALL = nansum(ALL);

% Sort component-level results
SortOTH = sort(OTH,'descend');
SortREG = sort(REG,'descend');
SortVL = sort(VL,'descend');
SortTC = sort(TC,'descend');
SortOEL = sort(OEL,'descend');
SortPRV = sort(PRV,'descend');
SortPC = sort(PC,'descend');
SortCS = sort(CS,'descend');
SortCIP = sort(CIP,'descend');
SortTK_H = sort(TK_H,'descend');
SortTK_P = sort(TK_P,'descend');
SortTK_V = sort(TK_V,'descend');
SortALL = sort(ALL,'descend');

% Normalize sorted component-level results
NormSortOTH = SortOTH/SumOTH;
NormSortREG = SortREG/SumREG;
NormSortVL = SortVL/SumVL;
NormSortTC = SortTC/SumTC;
NormSortOEL = SortOEL/SumOEL;
NormSortPRV = SortPRV/SumPRV;
NormSortPC = SortPC/SumPC;
NormSortCS = SortCS/SumCS;
NormSortCIP = SortCIP/SumCIP;
NormSortTK_H = SortTK_H/SumTK_H;
NormSortTK_P = SortTK_P/SumTK_P;
NormSortTK_V = SortTK_V/SumTK_V;
NormSortALL = SortALL/SumALL;

% Cumulate the normalized sorted values of component categories
CumOTH = cumsum(NormSortOTH);
CumREG = cumsum(NormSortREG);
CumVL = cumsum(NormSortVL);
CumTC = cumsum(NormSortTC);
CumOEL = cumsum(NormSortOEL);
CumPRV = cumsum(NormSortPRV);
CumPC = cumsum(NormSortPC);
CumCS = cumsum(NormSortCS);
CumCIP = cumsum(NormSortCIP);
CumTK_H = cumsum(NormSortTK_H);
CumTK_P = cumsum(NormSortTK_P);
CumTK_V = cumsum(NormSortTK_V);
CumALL = cumsum(NormSortALL);

% Create x-vectors of appropriate length
xOTH = (0:1/(length(OTH)-1):1);
xREG = (0:1/(length(REG)-1):1);
xVL = (0:1/(length(VL)-1):1);
xTC = (0:1/(length(TC)-1):1);
xOEL = (0:1/(length(OEL)-1):1);
xPRV = (0:1/(length(PRV)-1):1);
xPC = (0:1/(length(PC)-1):1);
xCS = (0:1/(length(CS)-1):1);
xCIP = (0:1/(length(CIP)-1):1);
xTK_H = (0:1/(length(TK_H)-1):1);
xTK_P = (0:1/(length(TK_P)-1):1);
xTK_V = (0:1/(length(TK_V)-1):1);
xALL = (0:1/(length(ALL)-1):1);

% 5% contribution

% OTH
if ~isempty(OTH)
	Perc5LocationOTH = ceil(length(OTH)*0.05);
	ContributionPerc5OTH = CumOTH(Perc5LocationOTH);
	OTH_SE = SortOTH(Perc5LocationOTH);
else
	OTH = 0;
end

% REG
if ~isempty(REG)
	Perc5LocationREG = ceil(length(REG)*0.05);
	ContributionPerc5REG = CumREG(Perc5LocationREG);
	REG_SE = SortREG(Perc5LocationREG);
else
	REG = 0;
end

% VL
if ~isempty(VL)
	Perc5LocationVL = ceil(length(VL)*0.05);
	ContributionPerc5VL = CumVL(Perc5LocationVL);
	VL_SE = SortVL(Perc5LocationVL);
else
	VL = 0;
end

% TC
if ~isempty(TC)
	Perc5LocationTC = ceil(length(TC)*0.05);
	ContributionPerc5TC = CumTC(Perc5LocationTC);
	TC_SE = SortTC(Perc5LocationTC);
else
	TC = 0;
end

% OEL

if ~isempty(OEL)
	Perc5LocationOEL = ceil(length(OEL)*0.05);
	ContributionPerc5OEL = CumOEL(Perc5LocationOEL);
	OEL_SE = SortOEL(Perc5LocationOEL);
else
	OEL = 0;
    Perc5LocationOEL = 0;
	ContributionPerc5OEL = 0;
	OEL_SE = 0;
end

% PRV
if ~isempty(PRV)
	Perc5LocationPRV = ceil(length(PRV)*0.05);
	ContributionPerc5PRV = CumPRV(Perc5LocationPRV);
	PRV_SE = SortPRV(Perc5LocationPRV);
else
	PRV = 0;
end

% PC
if ~isempty(PC)
	Perc5LocationPC = ceil(length(PC)*0.05);
	ContributionPerc5PC = CumPC(Perc5LocationPC);
	PC_SE = SortPC(Perc5LocationPC);
else
	PC = 0;
end

% CS
if ~isempty(CS)
	Perc5LocationCS = ceil(length(CS)*0.05);
	ContributionPerc5CS = CumCS(Perc5LocationCS);
	CS_SE = SortCS(Perc5LocationCS);
else
	CS = 0;
end

% CIP
if ~isempty(CIP)
	Perc5LocationCIP = ceil(length(CIP)*0.05);
	ContributionPerc5CIP = CumCIP(Perc5LocationCIP);
	CIP_SE = SortCIP(Perc5LocationCIP);
else
	CIP = 0;
    Perc5LocationCIP = 0;
	ContributionPerc5CIP = 0;
	CIP_SE = 0;
end

% TK
if ~isempty(TK_H)
	Perc5LocationTK_H = ceil(length(TK_H)*0.05);
	ContributionPerc5TK_H = CumTK_H(Perc5LocationTK_H);
	TK_H_SE = SortTK_H(Perc5LocationTK_H);
else
	TK_H = 0;
end

% TK
if ~isempty(TK_P)
	Perc5LocationTK_P = ceil(length(TK_P)*0.05);
	ContributionPerc5TK_P = CumTK_P(Perc5LocationTK_P);
	TK_P_SE = SortTK_P(Perc5LocationTK_P);
else
	TK_P = 0;
end

% TK
if ~isempty(TK_V)
	Perc5LocationTK_V = ceil(length(TK_V)*0.05);
	ContributionPerc5TK_V = CumTK_V(Perc5LocationTK_V);
	TK_V_SE = SortTK_V(Perc5LocationTK_V);
else
	TK_V = 0;
end

% ALL
if ~isempty(ALL)
	Perc5LocationALL = ceil(length(ALL)*0.05);
	ContributionPerc5ALL = CumALL(Perc5LocationALL);
	ALL_SE = SortALL(Perc5LocationALL);
else
	ALL = 0;
end

% GENERATE component level summary table
 % Generate results tables for device-level classifications
  ResultsTabDevice = [
    size(CS,1), min(CS), max(CS), mean(CS), median(CS), ContributionPerc5CS  
    size(OEL,1), min(OEL), max(OEL), mean(OEL), median(OEL), ContributionPerc5OEL
    size(OTH,1), min(OTH), max(OTH), mean(OTH), median(OTH), ContributionPerc5OEL
    size(PC,1), min(PC), max(PC), mean(PC), median(PC), ContributionPerc5PC
    size(PRV,1), min(PRV), max(PRV), mean(PRV), median(PRV), ContributionPerc5PRV
    size(REG,1), min(REG), max(REG), mean(REG), median(REG), ContributionPerc5REG
    size(TC,1), min(TC), max(TC), mean(TC), median(TC), ContributionPerc5TC
    size(VL,1), min(VL), max(VL), mean(VL), median(VL), ContributionPerc5VL
    size(CIP,1), min(CIP), max(CIP), mean(CIP), median(CIP), ContributionPerc5CIP
    size(TK_H,1), min(TK_H), max(TK_H), mean(TK_H), median(TK_H), ContributionPerc5TK_H
    size(TK_P,1), min(TK_P), max(TK_P), mean(TK_P), median(TK_P), ContributionPerc5TK_P
    size(TK_V,1), min(TK_V), max(TK_V), mean(TK_V), median(TK_V), ContributionPerc5TK_V    
    size(ALL,1), min(ALL), max(ALL), mean(ALL), median(ALL), ContributionPerc5ALL
    ];
  
% save('Components_allstudies_v5.mat','TC','VL','OEL','PRV','REG','PC','CIP','TK');
% save('Components_allstudies_SE_v5.mat','TC_SE','VL_SE','OEL_SE','PRV_SE','REG_SE','PC_SE','CIP_SE','TK_SE');
% 
%% Analysis of study-aggregated results

% Sum study-level results, starting with all sources regardless of study
SumAPI1993 = nansum(API1993);
SumAllen2013 = nansum(Allen2013);
SumAllen2014a = nansum(Allen2014a);
SumBell2017 = nansum(Bell2017);
SumERG2011 = nansum(ERG2011);
SumThoma2017 = nansum(Thoma2017);
SumPasci2019 = nansum(Pasci2019);

% Sort study-level results in descending order
SortAPI1993 = sort(API1993,'descend');
SortAllen2013 = sort(Allen2013,'descend');
SortAllen2014a = sort(Allen2014a,'descend');
SortBell2017 = sort(Bell2017,'descend');
SortERG2011 = sort(ERG2011,'descend');
SortThoma2017 = sort(Thoma2017,'descend');
SortPasci2019 = sort(Pasci2019,'descend');

% Normalize sorted results by total
NormSortAPI1993 = SortAPI1993/SumAPI1993;
NormSortAllen2013 = SortAllen2013/SumAllen2013;
NormSortAllen2014a = SortAllen2014a/SumAllen2014a;
NormSortBell2017 = SortBell2017/SumBell2017;
NormSortERG2011 = SortERG2011/SumERG2011;
NormSortThoma2017 = SortThoma2017/SumThoma2017;
NormSortPasci2019 = SortPasci2019/SumPasci2019;

% Cumulate the normalized sorted results
CumAPI1993 = cumsum(NormSortAPI1993);
CumAllen2013 = cumsum(NormSortAllen2013);
CumAllen2014a = cumsum(NormSortAllen2014a);
CumBell2017 = cumsum(NormSortBell2017);
CumERG2011 = cumsum(NormSortERG2011);
CumThoma2017 = cumsum(NormSortThoma2017);
CumPasci2019 = cumsum(NormSortPasci2019);

% Create x-vector of appropriate length
xAPI1993 = (0:1/(length(API1993)-1):1);
xAllen2013 = (0:1/(length(Allen2013)-1):1);
xAllen2014a = (0:1/(length(Allen2014a)-1):1);
xBell2017 = (0:1/(length(Bell2017)-1):1);
xERG2011 = (0:1/(length(ERG2011)-1):1);
xThoma2017 = (0:1/(length(Thoma2017)-1):1);
xPasci2019 = (0:1/(length(Pasci2019)-1):1);

% API 1993
if ~isempty(API1993)
	Perc5LocationAPI1993 = ceil(length(API1993)*0.05);
	ContributionPerc5API1993 = CumAPI1993(Perc5LocationAPI1993);
else
	API1993 = 0;
	Perc5LocationAPI1993 = 0;
	ContributionPerc5API1993 = 0;
end

% Allen 2013
if ~isempty(Allen2013)
	Perc5LocationAllen2013 = ceil(length(Allen2013)*0.05);
	ContributionPerc5Allen2013 = CumAllen2013(Perc5LocationAllen2013);
else
	Allen2013 = 0;
	Perc5LocationAllen2013 = 0;
	ContributionPerc5Allen2013 = 0;
end

% Allen 2014a
if ~isempty(Allen2014a)
	Perc5LocationAllen2014a = ceil(length(Allen2014a)*0.05);
	ContributionPerc5Allen2014a = CumAllen2014a(Perc5LocationAllen2014a);
else
	Allen2014a = 0;
	Perc5LocationAllen2014a = 0;
	ContributionPerc5Allen2014a = 0;
end

% Bell 2017
if ~isempty(Bell2017)
	Perc5LocationBell2017 = ceil(length(Bell2017)*0.05);
	ContributionPerc5Bell2017 = CumBell2017(Perc5LocationBell2017);
else
	Bell2017 = 0;
	Perc5LocationBell2017 = 0;
	ContributionPerc5Bell2017 = 0;
end

% ERG 2011
if ~isempty(ERG2011)
	Perc5LocationERG2011 = ceil(length(ERG2011)*0.05);
	ContributionPerc5ERG2011 = CumERG2011(Perc5LocationERG2011);
else
	ERG2011 = 0;
	Perc5LocationERG2011 = 0;
	ContributionPerc5ERG2011 = 0;
end

% Thoma 2017
if ~isempty(Thoma2017)
	Perc5LocationThoma2017 = ceil(length(Thoma2017)*0.05);
	ContributionPerc5Thoma2017 = CumThoma2017(Perc5LocationThoma2017);
else
	Thoma2017 = 0;
	Perc5LocationThoma2017 = 0;
	ContributionPerc5Thoma2017 = 0;
end

% Pacsi 2019
if ~isempty(Pasci2019)
	Perc5LocationPasci2019 = ceil(length(Pasci2019)*0.05);
	ContributionPerc5Pasci2019 = CumPasci2019(Perc5LocationPasci2019);
else
	Pasci2019 = 0;
	Perc5LocationPasci2019 = 0;
	ContributionPerc5Pasci2019 = 0;
end

% Create results summary table for study-specific emissions 
 ResultsTabStudy = [
     size(API1993,1), min(API1993), max(API1993), mean(API1993), median(API1993), ContributionPerc5API1993
     size(Allen2013,1), min(Allen2013), max(Allen2013), mean(Allen2013), median(Allen2013), ContributionPerc5Allen2013
     size(Allen2014a,1), min(Allen2014a), max(Allen2014a), mean(Allen2014a), median(Allen2014a), ContributionPerc5Allen2014a
     size(Bell2017,1), min(Bell2017), max(Bell2017), mean(Bell2017), median(Bell2017), ContributionPerc5Bell2017
     size(ERG2011,1), min(ERG2011), max(ERG2011), mean(ERG2011), median(ERG2011), ContributionPerc5ERG2011
     size(Thoma2017,1), min(Thoma2017), max(Thoma2017), mean(Thoma2017), median(Thoma2017), ContributionPerc5Thoma2017
     size(Pasci2019,1), min(Pasci2019), max(Pasci2019), mean(Pasci2019), median(Pasci2019), ContributionPerc5Pasci2019
     ];

%% Compute emissions per piece of equipment and per site


% Rows: Equipment List
% Well
% Header
% Heater
% Separator
% Meter
% Tank - Leaks
% TAnk - Vents
% Compressor - Recip
% Dehydrator
% Injection Pump
% Pneumatic Controller

% Columns: Component list 
% Connectors	Valve	Open-ended line	Pressure-relief valve	Compressor seal	Regulator	Vents	Pump	Pneumatic controller/actuator	Tank vent/hatch	Injection Pump Other/Not specified
% CN	VL      OEL     PRV     CS      REG           PC      CIP   TK_H  TK_P  TK_V  OTH

ComponentsAtEquipment = ComponentCountsByEquipment;

NinetyPercCutoffTrials = zeros(Trials,size(ComponentsAtEquipment,1));

% 3D array for leak count by equipment (row), component (column), trial
% (depth)
LeakerCountAtEquipment = zeros(size(ComponentsAtEquipment,1),size(ComponentsAtEquipment,2),Trials);

% For each trial
for ll = 1:Trials
    % How many leaks?
    for ii=1:size(ComponentsAtEquipment,1)
        for jj = 1:size(ComponentsAtEquipment,2)
            if ComponentsAtEquipment(ii,jj) > 0
                for kk = 1:ComponentsAtEquipment(ii,jj)
                    RandomNum =  rand;
                    if RandomNum <= FractionLeaking(jj)
                        LeakerCountAtEquipment(ii,jj,ll) = LeakerCountAtEquipment(ii,jj,ll)+1;
                    end
                end
            end
        end
    end
end 


 % Create emitter list

    EmitterListAtEquipment = [];
    EmitterTypeAtEquipment = [];
    EmissionsAtEquipment = zeros(size(LeakerCountAtEquipment,1),size(LeakerCountAtEquipment,2),size(LeakerCountAtEquipment,3));
   
    for ii = 1:size(LeakerCountAtEquipment,1)
        for jj = 1:size(LeakerCountAtEquipment,2)
            for ll = 1:size(LeakerCountAtEquipment,3)
                
                % Only count leakers if there is a leaker of type ii,jj in
                % realization ll
                if LeakerCountAtEquipment(ii,jj,ll) > 0
                
                % Loop through the count of leaks
                
                for kk = 1:LeakerCountAtEquipment(ii,jj,ll)
                    
                    if jj == 1
                        RandomIndex = ceil(rand*size(TC,1));
                        EmissionsAtEquipment(ii,jj,ll) = EmissionsAtEquipment(ii,jj,ll)+TC(RandomIndex);
                    end

                    if jj == 2
                        RandomIndex = ceil(rand*size(VL,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+VL(RandomIndex);
                    end

                    if jj == 3
                        RandomIndex = ceil(rand*size(OEL,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+OEL(RandomIndex);
                    end

                    if jj == 4
                        RandomIndex = ceil(rand*size(PRV,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+PRV(RandomIndex);
                    end

                    if jj == 5
                        RandomIndex = ceil(rand*size(CS,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+CS(RandomIndex);
                    end

                    if jj == 6
                        RandomIndex = ceil(rand*size(REG,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+REG(RandomIndex);
                    end

                    if jj == 7
                        RandomIndex = ceil(rand*size(PC,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+PC(RandomIndex);
                    end

                    if jj == 8
                        RandomIndex = ceil(rand*size(CIP,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+CIP(RandomIndex);
                    end


                    if jj == 9
                        RandomIndex = ceil(rand*size(TK_H,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+TK_H(RandomIndex);
                    end

                    if jj == 10
                        RandomIndex = ceil(rand*size(TK_P,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+TK_P(RandomIndex);
                    end
                    
                    if jj == 11
                        RandomIndex = ceil(rand*size(TK_V,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+TK_V(RandomIndex);
                    end
                    
                    if jj == 12
                        RandomIndex = ceil(rand*size(OTH,1));
                        EmissionsAtEquipment(ii,jj,ll) =  EmissionsAtEquipment(ii,jj,ll)+OTH(RandomIndex);
                    end
                
                % End loop over leak count
                end
                
                % End if statement for checking if there are leaks
                end
            % End loop over realizations/trials    
            end
        % End loop over componenent types
        end
    % End loop over equipment types    
    end

    % Collapse emissions at each piece of equipment, by summing across
    % components
    TotalEmissionsAtEquipment = squeeze(sum(EmissionsAtEquipment,2));
    
    
    % Compute the 0.1%ile through 100th percentiles for each type of equipment    
    PercentilesEquipment = prctile(TotalEmissionsAtEquipment,[0.1:0.1:100],2);

    MeanEquipment = mean(TotalEmissionsAtEquipment,2);






