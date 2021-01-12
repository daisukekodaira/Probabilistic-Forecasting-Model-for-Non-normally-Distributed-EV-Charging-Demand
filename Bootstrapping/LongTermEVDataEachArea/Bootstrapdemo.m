function bootstrap_demo

% data
iq = [61, 88, 89, 89, 90, 92, 93,94, 98, 98, 101, 102, 105, 108,109, 113, 114, 115, 120, 138];

% compute mean, SEM (standard error of the mean) and median
mean_iq = mean(iq);
sem_iq = std(iq)/sqrt(length(iq));
median_iq = median(iq);
disp(['the mean: ' num2str(mean_iq)])
disp(['the SE of the mean: ' num2str(sem_iq)])
disp(['the median: ' num2str(median_iq)])
disp('---------------------------------')

[b_mean_sem, b_median_sem] = bootstrap(iq, 1000);
disp(['bootstrapped SE of the mean: ' num2str(b_mean_sem)])
disp(['bootstrapped SE of the median: ' num2str(b_median_sem)])

% bootstrap to compute sem of the median
function [b_mean_sem, b_median_sem] = bootstrap(x, repeats)

% placeholder (column1: mean, column2: median)
vec = zeros(2,repeats);
for i = 1:repeats
    % resample data with replacement
    re_x = x(datasample(1:length(x),length(x),'Replace',True));

    % compute mean and median of the "new" dataset
    vec(1,i) = mean(re_x);
    vec(2,i) = median(re_x);

end

% histogram of median from resampled dataset
histogram(vec(2,:))

% compute bootstrapped standard error of the mean, and standard error of
% the median
b_mean_sem = std(vec(1,:));
b_median_sem = std(vec(2,:));



