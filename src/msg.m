%% Matrix Stochastic Gradient Descent for PCA
% from "Stochastic Optimization of PCA with Capped MSG", Arora et al

% very similar to incremental pca, but with better theoretical bounds
% for convergence, and it is guaranteed not to get "stuck". 

% update of the form P^(t) = P_{trace(P) = k, P<= I}(P^(t-1) + \eta_t*x*x^T)
% but stored in the form of an singular value decomposition of the 
% covariance (2nd moment) matrix as so:

function U = msg(X, k)

    X = X';               % to make things work. X is matrix of [0, 255]
    X = candN(X);         % 
%     X = normc(X); %OH GOD
    iters = 1;            % how many times to loop over entire training set
    t = 0;                % iterate
    n = size(X, 2);       % number of examples
    d = size(X, 1);       % dimensionality
    U = zeros(d, 1);      % provably better accuracy with all zeros initial
    S = zeros(1, 1);      % both U and S will grow larger...
    eta = 1/sqrt(n*iters);% seems to be good enough eta
    epsilon = 0.01;       % don't know what the significance of this is...
    warning('off','all'); %because it clutters screen as matrix initializes
   
    if(size(X, 1) ~= 32256)           %obviously change
       size(X)
       error('IPCA: bad input');
    end
    h = waitbar(0,'Initializing waitbar...');
    for i = 1:iters
        fprintf('----iteration %d\n', i);
        X(:,randperm(size(X,2)));         %good practice to shuffle:
        for t = 1:n; 
           x = X(:, t);
           
           [U,S] = msg_update(k,U,S,eta,x,epsilon);
           if (sum(S) > k)
               display('----------------');
               sum(sigma)
               sigma
               error('sum of sigmas not less than k, projection failed')
           end
           if (rank(U) > k + 20) %why +20? idk...magic number
               %this happens quite often
%                fprintf('sampling %d from rank-%d U matrix\n', k, rank(U));
               [U, S] = msgsample(k, U, S);
           end
           indices = find(S == 0);
           U(:, indices) = [];
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
% function sigma = project(d, k, n, sigma, kappa)
%     
%     [sigma, I] = sort(sigma, 'descend')
%     kappa = kappa(I); %also re-sort these
%     
%     fprintf('size of sigma in project: %d\n', length(sigma));
%     if (length(sigma) <= 2)
%         sigma
%         error('sigma is only one in project()!');
%     end
%     
%     i   = 1;
%     j   = 1;
%     s_i = 0;
%     s_j = 0;
%     c_i = 0;
%     c_j = 0;
%     S   = 0;
%     
%     while i <= n
%         if (i < j)
%            S = (k - (s_j - s_i) - (d - c_j))/(c_j - c_i)
%            b = ((sigma(i) + S >= 0) && (sigma(j-1) + S <= 1)...
%                  && ((i <= 1) || (sigma(i - 1) + S <= 0))...
%                  && ((j >= n) || (sigma(j+1) >= 1)));
%            if (b == true)
%                S
%                for i = 1:length(sigma)
%                     sigma(i) = max(0, min(1, sigma(i) - S));
%                end
%                display('returned properly');
%                return;
%            end
%         end
%         if ( (j <= n) && (sigma(j) - sigma(i) <= 1))
%             s_j = s_j + kappa(j)*sigma(j);
%             c_j = c_j + kappa(j);
%             j = j + 1;
%         else
%            s_i = s_i + kappa(i)*sigma(i);
%            c_i = c_i + kappa(i);
%            i = i + 1;
%         end
%             
%     end
%     error('projection did  NOT occur properly');
%     
%     
% 
% end

function X = candN(X)
    mean = sum(X, 2)/size(X, 2);
    stdtrain = std(X');
    Xcenter = bsxfun(@minus, X, mean);
    X = bsxfun(@rdivide, Xcenter, stdtrain');
end
