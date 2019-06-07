function [out] = objective_func(in)

    global_var_declare;
      
    % n = number of particles
    % m = number of variables
    [n_,m_] = size(in);
    total_pred_load = zeros(size(g_y_true,1),1);
    out = zeros(n_,1);
    
    for i = 1:n_
        coef = repmat(in(i,:), [size(g_y_predict,1) 1]);
        
        % constraint
        if abs(1 - sum(in(i,:))) > 0.01 
            out(i) = 10^8 + abs(1 - sum(in(i,:)));
            continue
        end        
        total_pred_load = sum(coef.*g_y_predict,2);   % predicted load for each time step
        out(i) = sum(abs(total_pred_load -  g_y_true)); % total of prediction error for one particle
    end

end