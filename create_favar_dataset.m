%% Code used to create our dataset (for a FAVAR MODEL)
clear all; clc; % clear workspace
path = 'C:\Users\Philippe ZABAR\Desktop\M2\GQ\Code\GQ TEST V5\';%'/Users/morgane/Desktop/Etudes/Master/M2 IEF 2019 - 2020/Gestion quantitative/Projet/CodeProjetGQ/';
addpath(genpath(path)); % to use functions
%% data parameters (for transformation etc)
input_data.start_month = [1971 1];  % first month of the data 
input_data.end_month = [2019 11];   % last month of the data
input_data.nb_obs_per = 12;         % monthly data 
input_data.nbr_obs = input_data.nb_obs_per*(input_data.end_month(1)-input_data.start_month(1)-1)+input_data.end_month(2)+(input_data.nb_obs_per+1-input_data.start_month(2))-1; % nbr of observations 
input_data.date_vec = linspace(input_data.start_month(1)+(input_data.start_month(2)-1)/input_data.nb_obs_per,input_data.end_month(1)+(input_data.end_month(2)-1)/input_data.nb_obs_per,input_data.nbr_obs)'; % date vector
%% read in monthly data 
xlsname = [path 'variablesN.xlsx']; % file containing data 
empty_excel = 1.0e+32;          % missing value code for entries in Excel Fle;
input_data.nb_series = 104;     % number of series
input_data.nb_desc_rows = 1;    % number of "description" rows in Excel file
input_data.nb_codes_rows = 2;   % number of rows of "codes" in Excel file
[input_data.series_id,input_data.slowfast,input_data.descriptions,~,input_data.data] = readxls(xlsname,4,input_data.nb_series,input_data.nbr_obs,input_data.nb_desc_rows,input_data.nb_codes_rows); % import excel data
%% manipulate data 
input_data.data(input_data.data == empty_excel) = NaN; % replace missing values with NaN
%% data transformation
for i = 1:input_data.nb_series;
  if input_data.descriptions(2,i) ~= 0; % only for included series                  
      y(:,i) = transform(input_data.data(:,i),input_data.descriptions(1,i));% Transform .. log, first difference, etc.
  end;
end;
%% data saving (only used series)    
for i = 1:input_data.nb_series;
  if input_data.descriptions(2,i) ~= 0; % only for included series  
      if i == 1; % 1st serie
          final_series = y(:,i); % transformed serie, without outliers
          final_series_id = input_data.series_id(i,1);      % series id 
          final_series_sf = input_data.slowfast(i,1);      % series S/F 
      else; % other series 
          final_series = [final_series y(:,i)]; % transformed serie, without outliers
          final_series_id = [final_series_id input_data.series_id(i,1)];      % series id 
          final_series_sf = [final_series_sf input_data.slowfast(i,1)];      % series S/F 
      end;
  end;
end;      
%% eliminate low_frequency by local demeaning
for i = 1:size(final_series,2);
    final_series_trend(:,i) = trend(final_series(:,i));
    final_series(:,i) = final_series(:,i) - final_series_trend(:,i);
end;
%% stationarity test 
for i = 1:size(final_series,2);
    if i==1; % 1st serie 
        [final_series_df_h final_series_df_pval] = adftest(final_series(:,i)); % df test  
    else; % other series 
        [final_series_df_h_tmp final_series_df_pval_tmp] = adftest(final_series(:,i)); % df test  
        final_series_df_h = [final_series_df_h final_series_df_h_tmp]; % df test 
        final_series_df_pval = [final_series_df_pval final_series_df_pval_tmp]; % df test 
    end;
end;
% GS10_tb3m stationary at the 10% threshold

%% standardization

xmean = nanmean(final_series)';                                        
mult = sqrt((sum(~isnan(final_series))-1)./sum(~isnan(final_series)));     
xstd = (nanstd(final_series).*mult)';                                  
final_series = (final_series - repmat(xmean',input_data.nbr_obs,1))./repmat(xstd',input_data.nbr_obs,1); 

%% save series in data_set 
data_set.final_series = final_series;
data_set.final_series_id = final_series_id;
data_set.nbr_obs = input_data.nbr_obs;
data_set.date_vec = input_data.date_vec;
data_set.slow_fast = final_series_sf;
save([path 'data_set.mat'],'data_set'); % save data_set