%% Code used to estimate a favar model
% IRFS and VDs are for Cholesky Ordered shocks in Factor Model
% Factors can be identified using restrictions on factor loadings
% HY US Corp Default Rate is Exogenous and is an observed factor

%TODO : supprimer les variables inutiles 

clear all; % clear workspace
path = '/Users/morgane/Desktop/Etudes/Master/M2 IEF 2019 - 2020/Gestion quantitative/Projet/CodeProjetGQ/';
addpath(genpath(path)); % to use functions
load([path 'data_set.mat'])
%% favar model parameters 
model.data_param.nb_series = size(data_set.final_series,2); % nb of series (1 default rate dans 136 macro series)
model.data_param.start_date = [1996 4];            % start date of the estimation
model.data_param.end_date = [2005 12];             % end date of the estimation
model.data_param.nb_obs_per = 12;                  % obs / year
model.data_param.nb_obs = model.data_param.nb_obs_per*(model.data_param.end_date(1)-model.data_param.start_date(1)-1)+model.data_param.end_date(2)+(model.data_param.nb_obs_per+1-model.data_param.start_date(2)); % nbr of observations
model.data_param.date_vector = linspace(model.data_param.start_date(1)+(model.data_param.start_date(2)-1)/model.data_param.nb_obs_per,model.data_param.end_date(1)+(model.data_param.end_date(2)-1)/model.data_param.nb_obs_per,model.data_param.nb_obs)'; % date vector
model.data_param.start_obs = colnumber(model.data_param.date_vector(1),data_set.date_vec); % start on the data set 
model.data_param.end_obs = colnumber(model.data_param.date_vector(model.data_param.nb_obs),data_set.date_vec); % end on the data set 
model.data_param.data = data_set.final_series(model.data_param.start_obs:model.data_param.end_obs,:); % data 
model.data_param.data_id = data_set.final_series_id; % data id
%% lag selection
[InformationCriterion, aicL, bicL, hqcL, fpeL, CVabs, CVrel, CVrelTr] = AicBicHqcFpe(model.data_param.data(:,colnumber('HYCORPDR',model.data_param.data_id)), 12);
p = CVrel % cross validation method 
% Ici ils appliquent la méthode de cross validation (voir les ref)
%% PCA 
%https://fr.mathworks.com/matlabcentral/answers/299221-how-pca-function-works-in-matlab
[~,~,C,~,pca_perc] = pca(model.data_param.data(:,1:120));
%%
%TODO : faire tourner un code pour le nombre de facteurs !!!! 
model.esti_param.nb_unobsv_fac = 7;                % nb of unobserved factors
model.esti_param.nb_obsv_fac = 1;                  % nb of observed factors (default rate)
model.esti_param.nb_tot_fac = model.esti_param.nb_obsv_fac + model.esti_param.nb_unobsv_fac; % nb of factors
model.esti_param.obsv_fac = data_set.final_series(:,colnumber('HYCORPDR',data_set.final_series_id)); % observet factor (HY default rates serie)
rownumber(model.data_param.date_vector(model.data_param.nb_obs),data_set.date_vec)
%TODO : trouver comment choisir le nombre de lagss
%TODO : trouver // constant
%TODO : trouver // companion
model.esti_param.nb_lag   = p;            % number of lags  
model.esti_param.nb_const = 1;             % include constant 
model.esti_param.nb_comp  = 1;             % compute Companion form of model .. excluding constant
model.esti_param.nb_uarlag  = 12;          % Number of arlags for uniqueness
model.decomp_param.var_cumu = 0;      % don't use cumulative variance -- here show VDs, shock-by-shock (here one shock)
model.decomp_param.cannon_corr = 0;   % se cannonical correlations -- identification is via "named factor" etc.
model.decomp_param.horiz    = 17;     % horizodon't un for impulse responses and variance decomposition
%% construct estimates of factors (PCA analysis)
%pca_output.









%% %%%%%%
factors_estimation = factor_estimation_ls_full(data_set,model);% estimation



%%
irf_vdecomp_out = dynamic_factor_irf_vdecomp(fac_est_out,est_par,decomp_par,data_set.bptcodevec);      % variance decomposition

%%
% -- Compute Standard Errors for IRFs and VDs using parametric bootstrap
% simulations (PREND DU TMPS)
n_rep = 500;   % Number of bootstap simulations for computing SEs
se_irf_vdecomp_out = se_dynamic_factor_irf_vdecomp(data_set,fac_est_out,est_par,decomp_par,n_rep); 
