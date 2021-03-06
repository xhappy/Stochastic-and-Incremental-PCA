%% Matrix Stochastic Gradient Descent for PCA
% from "Stochastic Optimization of PCA with Capped MSG", Arora et al

% very similar to incremental pca, but with better theoretical bounds
% for convergence, and it is guaranteed not to get "stuck". 

% update of the form P^(t) = P_{trace(P) = k, P<= I}(P^(t-1) + \eta_t*x*x^T)
% but stored in the form of an singular value decomposition of the 
% covariance (2nd moment) matrix.

% Depends on msgupdate.m and msgsample.m

function U = msg(X, k)

    X = X';                 % to make things work. X is matrix of [0, 255]
    iters = 75;             % how many times to loop over entire training set
    t = 0;                  % iterate
    n = size(X, 2);         % number of examples
    d = size(X, 1);         % dimensionality
    U = zeros(d, 1);        % provably better accuracy with all zeros initial
    S = zeros(1, 1);        % both U and S will grow larger...
    etas = [10];
    eta = sqrt(k/(n*iters));% seems to be good enough eta
    epsilon = 0.000001;     
    warning('off','all');   %because it clutters screen
    error = 10;
    tempError = 10;
   
    if(size(X, 1) ~= 32256)         
       size(X)
       error('IPCA: bad input');
    end
    h = waitbar(0,'Initializing waitbar...');
    for i = 1:iters
        fprintf('----iteration %d\n', i);
        X(:,randperm(size(X,2)));         %good practice to shuffle:
        for t = 1:n; 
           x = X(:, t);
           eta = etas(1)/nthroot((i-1)*n + t, 2);
           [U,S] = msg_update(k,U,S,eta,x,epsilon);
           if (sum(S) > 1)
               [U, S] = msgsample(k, U, S);   
           end
           
           %magic number +20?, bc this happens quite often and can blow up
           if (rank(U) > k + 20) 
               [U, S] = msgsample(k, U, S); %so take top k components again
           end
           if (mod(t, 300) == 0)                %output some progress
                   error = tempError;
                   tempError = calcError(U, X);
                   fprintf('--train error: %d, diff: %d, eta: %d\n', ...
                       tempError, abs(error - tempError), eta); 
           end
           waitbar((n*(i-1) + t)/(iters*n),h);
        end
        
    end
    [U, S] = msgsample(k, U, S);
    domain = [1:k];
    scatter(domain, S); hold on;
    title('eigenvalues of msg');
    hold off;
    close(h);
    
end


%% variance defined as reconstruction error
function obj = calcError(U, X) 
    obj = norm(X - U*(U'*X));
end

