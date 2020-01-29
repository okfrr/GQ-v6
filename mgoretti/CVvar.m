function [meanRMSETe, meanRMSETr] = CVvar(Data, p, constant, idxCV)

% STEP 1: Generate Matrixies for SUR Representation
Y=(Data(p+1:end,:));          % lose first p lags 
X = lagmatrix(Data,1:p);      % generate lagged values 
X(1:p,:)=[];                  % Lose one osb for each lag
 
if constant==1;
  X=[ones(size(X,1),1) X];    % add the constant if needed
end
  
% Isolate the p inital elements of Data
%Y_start=(Data(1:p,:)); 

K = size(idxCV,1);

numObs = size(X, 1);

% K-fold CV

for m = 1:size(idxCV,3)
    for k = 1:K
        % get k'th subgroup in test, others in train

        idxTe = idxCV(k,:, m);
        idxTr = idxCV([1:k-1 k+1:end],:, m);


        % remove out of bound values from the CV (we have less obs depending on the
        % num of lags

        idxTe = idxTe(idxTe <= numObs);
        idxTr = idxTr(idxTr <= numObs);

        idxTr = idxTr(:);
        YTe = Y(idxTe, :);
        XTe = X(idxTe,:);
        YTr = Y(idxTr, :);
        XTr = X(idxTr,:);

        % STEP 2: estimate the model 
        MLE=((XTr'*XTr)\(XTr'*YTr))'; 

        YTr_hat=XTr*MLE';
        eTr = YTr-YTr_hat;
        
        % predict test values and compute the MSE
        YTe_hat=XTe*MLE';
        eTe = YTe-YTe_hat;

        % store the RMSE
        RMSETr(k, :, m) = sqrt( sum(eTr.^2) );
        RMSETe(k, :, m) = sqrt( sum(eTe.^2) );
    end
end
meanRMSETr = mean(mean(RMSETr, 1), 3);
meanRMSETe = mean(mean(RMSETe, 1), 3);

end