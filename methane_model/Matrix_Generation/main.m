%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EQUIPMENT EMISSIONS FACTOR GENERATOR
% Jeff Rutherford
% last updated August 4, 2020
%
% The purpose of this code is to generate Equipment-level EF matrices which
% can be used in OPGEE's component-level fugitives tool. To explore the
% range of uncertainty in fugitives data, component counts, and fraction
% leaking, this script can generate numerous EF matrices according to the
% specified number of Monte Carlo trials.
% 
% Input data:
%   (i) Upper-bound and lower-bound fraction leaking vectors at 500 ppmv
%   and 10,000 ppmv
%   (ii) Upper-bound and lower-bound component-count matrices for oil and
%   gas systems. These matrices are contained in csv files which are
%   imported into Matlab
%   (iii) Component-level leak datasets at less than 10,000 ppmv and
%   greater than or equal to 10,000 ppmv
%
% Output data:
%   (i) Gas and oil equipment level EF matrices (number specified by
%   desired number of Monte Carlo trials
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PREPROCESSING
clear; clc; close all;

%% SPECIFY PARAMETERS

n.trial = 100; % number of matrices to generate

%% PREPROCESSING

data=importdata('Counts_Lower_Oil.csv');
CQ.LLoil = data;
data=importdata('Counts_Upper_Oil.csv');
CQ.ULoil = data;
data=importdata('Counts_Lower_Gas.csv');
CQ.LLgas = data;
data=importdata('Counts_Upper_Gas.csv');
CQ.ULgas = data;

%           CN      VL      OEL     PRV     CS      REG     PC      CIP     TK - H	TK-PRV	TK-V    OTH
% 500 pmmv
FL.LL_500 = [0.0014	0.0016	0.0121	0.0027	0.0323	0.0088	0.7500	0.0303	0.3955	0       0       0.1522];                   
FL.UL_500 = [0.0069	0.0249	0.0251	0.0310	0.0323	0.0088	0.7500	0.0303	0.3955	0.0086	0.0086	0.1522];
% 10,000 ppmv
FL.LL_10k = [0.0006	0.0012	0.0048	0.0024	0.0645	0.0088	0.7500	0.0000	0.1883	0		0		0.0612];
FL.UL_10k = [0.0029	0.0140	0.0133	0.0055	0.0645	0.0088	0.7500	0.0000	0.1883	0.0344	0.0284	0.0612];

[n.equip, n.comp] = size(CQ.ULgas);

EF_500 = zeros(n.equip, 1000, n.trial);
EF_10k = zeros(n.equip, 1000, n.trial);

CQout = zeros(n.equip, n.comp, n.trial);
FLout = zeros(n.comp,n.trial);

%% Loop gas
% Loop to build CQ and FL matrices
type = 1; % 1 = gas, 2 = oil

% Low emitters (500 - 10,000 ppmv)
size_ppmv = 1;

    for k = 1: n.trial
        for j = 1:n.comp
            for i = 1:n.equip
                if type == 1
                    CQout(i,j,k) = CQ.LLgas(i,j) + ((-CQ.LLgas(i,j) + CQ.ULgas(i,j)) * rand);
                else
                    CQout(i,j,k) = CQ.LLoil(i,j) + ((-CQ.LLoil(i,j) + CQ.ULoil(i,j)) * rand);
                end
            end
        end
    end

    CQout = ceil(CQout);

    for k = 1:n.trial
        for i = 1:n.comp
              FLout(i,k) = FL.LL_500(i) + ((-FL.LL_500(i) + FL.UL_500(i)) * rand);
        end
    end        

    for k = 1:n.trial
        ComponentCountsByEquipment = CQout(:,:,k);
        FractionLeaking = FLout(:,k)';

        PercentilesEquipment = MatBuild_v7(ComponentCountsByEquipment, FractionLeaking, size_ppmv);
        EF_500(:,:,k) = PercentilesEquipment;
    end

% High emitters (> 10,000 ppmv)
size_ppmv = 2;

    for k = 1: n.trial
        for j = 1:n.comp
            for i = 1:n.equip
                if type == 1
                    CQout(i,j,k) = CQ.LLgas(i,j) + ((-CQ.LLgas(i,j) + CQ.ULgas(i,j)) * rand);
                else
                    CQout(i,j,k) = CQ.LLoil(i,j) + ((-CQ.LLoil(i,j) + CQ.ULoil(i,j)) * rand);
                end
            end
        end
    end

    CQout = ceil(CQout);

    for k = 1:n.trial
        for i = 1:n.comp
              FLout(i,k) = FL.LL_10k(i) + ((-FL.LL_10k(i) + FL.UL_10k(i)) * rand);
        end
    end        

    for k = 1:n.trial
        ComponentCountsByEquipment = CQout(:,:,k);
        FractionLeaking = FLout(:,k)';

        PercentilesEquipment = MatBuild_v7(ComponentCountsByEquipment, FractionLeaking, size_ppmv);
        EF_10k(:,:,k) = PercentilesEquipment;
    end

    EF_500_ave2 = mean(EF_500,3);
    EF_500_ave1 = mean(EF_500_ave2,2);
    EF_10k_ave2 = mean(EF_10k,3);
    EF_10k_ave1 = mean(EF_10k_ave2,2);

for k = 1:(n.trial)
    % Superpose halves of distributions < 10k and > 10k
    EF(:,:,k) = EF_500(:,:,k) + EF_10k(:,:,k);

	% Create a text file name, and read the file.
	csvFileName = ['EquipGas' num2str(k) '.csv'];
	csvwrite(csvFileName,EF(:,:,k));
end

%% Loop oil

% Loop to build CQ and FL matrices
type = 2; % 1 = gas, 2 = oil

EF = zeros(n.equip, 1000, n.trial);
CQout = zeros(n.equip, n.comp, n.trial);
FLout = zeros(n.comp,n.trial);

% Low emitters (500 - 10,000 ppmv)
size_ppmv = 1;

    for k = 1: n.trial
        for j = 1:n.comp
            for i = 1:n.equip
                if type == 1
                    CQout(i,j,k) = CQ.LLgas(i,j) + ((-CQ.LLgas(i,j) + CQ.ULgas(i,j)) * rand);
                else
                    CQout(i,j,k) = CQ.LLoil(i,j) + ((-CQ.LLoil(i,j) + CQ.ULoil(i,j)) * rand);
                end
            end
        end
    end

    CQout = ceil(CQout);

    for k = 1:n.trial
        for i = 1:n.comp
              FLout(i,k) = FL.LL_500(i) + ((-FL.LL_500(i) + FL.UL_500(i)) * rand);
        end
    end        

    for k = 1:n.trial
        ComponentCountsByEquipment = CQout(:,:,k);
        FractionLeaking = FLout(:,k)';

        PercentilesEquipment = MatBuild_v7(ComponentCountsByEquipment, FractionLeaking, size_ppmv);
        EF_500(:,:,k) = PercentilesEquipment;
    end

% High emitters (> 10,000 ppmv)
size_ppmv = 2;

    for k = 1: n.trial
        for j = 1:n.comp
            for i = 1:n.equip
                if type == 1
                    CQout(i,j,k) = CQ.LLgas(i,j) + ((-CQ.LLgas(i,j) + CQ.ULgas(i,j)) * rand);
                else
                    CQout(i,j,k) = CQ.LLoil(i,j) + ((-CQ.LLoil(i,j) + CQ.ULoil(i,j)) * rand);
                end
            end
        end
    end

    CQout = ceil(CQout);

    for k = 1:n.trial
        for i = 1:n.comp
              FLout(i,k) = FL.LL_10k(i) + ((-FL.LL_10k(i) + FL.UL_10k(i)) * rand);
        end
    end        

    for k = 1:n.trial
        ComponentCountsByEquipment = CQout(:,:,k);
        FractionLeaking = FLout(:,k)';

        PercentilesEquipment = MatBuild_v7(ComponentCountsByEquipment, FractionLeaking, size_ppmv);
        EF_10k(:,:,k) = PercentilesEquipment;
    end

    EF_500_ave2 = mean(EF_500,3);
    EF_500_ave1 = mean(EF_500_ave2,2);
    EF_10k_ave2 = mean(EF_10k,3);
    EF_10k_ave1 = mean(EF_10k_ave2,2);
    x = 1;
for k = 1:(n.trial)
    % Superpose halves of distributions < 10k and > 10k
    EF(:,:,k) = EF_500(:,:,k) + EF_10k(:,:,k);

	% Create a text file name, and read the file.
	csvFileName = ['EquipOil' num2str(k) '.csv'];
	csvwrite(csvFileName,EF(:,:,k));
end
