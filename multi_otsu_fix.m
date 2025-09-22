function thresholds = multi_otsu_fix(image, num_thresholds)
% MULTI_OTSU_FIX Multi-level Otsu thresholding with bounds checking
%
% Inputs:
%   image - Input grayscale image (2D array)
%   num_thresholds - Number of thresholds to find (default: 1)
%
% Outputs:
%   thresholds - Array of threshold values
%
% This function implements multi-level Otsu thresholding with improved
% bounds checking to prevent negative array indices and ensure all indices
% remain within valid bounds.

    % Input validation
    if nargin < 2
        num_thresholds = 1;
    end
    
    if ~ismatrix(image) || ndims(image) > 2
        error('Input image must be a 2D grayscale image');
    end
    
    if num_thresholds < 1 || num_thresholds > 254
        error('Number of thresholds must be between 1 and 254');
    end
    
    % Convert to double and ensure valid intensity range
    image = double(image);
    if min(image(:)) < 0 || max(image(:)) > 255
        image = mat2gray(image) * 255;
    end
    
    % Compute histogram using built-in functions (Octave compatible)
    image_uint8 = uint8(image);
    image_vec = image_uint8(:);
    
    % Manual histogram computation for Octave compatibility
    counts = zeros(1, 256);
    for i = 1:length(image_vec)
        bin_idx = double(image_vec(i)) + 1; % +1 for 1-based indexing
        if bin_idx >= 1 && bin_idx <= 256
            counts(bin_idx) = counts(bin_idx) + 1;
        end
    end
    counts = double(counts);
    
    % Remove zero bins at the ends to improve efficiency
    first_nonzero = find(counts > 0, 1, 'first');
    last_nonzero = find(counts > 0, 1, 'last');
    
    if isempty(first_nonzero) || isempty(last_nonzero)
        error('Image appears to be empty or uniform');
    end
    
    % Ensure valid bounds
    first_nonzero = max(1, first_nonzero);
    last_nonzero = min(256, last_nonzero);
    
    % Trim histogram
    counts = counts(first_nonzero:last_nonzero);
    valid_range = (first_nonzero:last_nonzero) - 1; % 0-255 range
    
    % Compute prefix sums for efficient calculation
    prefix_sums = calc_prefix_sum_hdl(counts);
    
    % Initialize thresholds
    thresholds = zeros(1, num_thresholds);
    
    % Find optimal thresholds using coarse-to-fine search
    for t = 1:num_thresholds
        if t == 1
            % Single threshold case
            thresholds(t) = find_single_threshold(counts, valid_range, prefix_sums);
        else
            % Multiple thresholds - use previous thresholds as constraints
            prev_thresholds = sort(thresholds(1:t-1));
            thresholds(t) = find_additional_threshold(counts, valid_range, prefix_sums, prev_thresholds);
        end
    end
    
    % Sort thresholds and convert to original intensity range
    thresholds = sort(thresholds) + (first_nonzero - 1);
    
    % Ensure thresholds are within valid bounds
    thresholds = max(0, min(255, thresholds));
end

function threshold = find_single_threshold(counts, valid_range, prefix_sums)
% Find single optimal threshold using Otsu's method with bounds checking
    
    n_bins = length(counts);
    if n_bins < 2
        threshold = valid_range(1);
        return;
    end
    
    total_pixels = sum(counts);
    total_intensity = sum(counts .* (0:n_bins-1));
    
    max_variance = -1;
    threshold = valid_range(1);
    
    % Coarse sweep - check every 4th bin for efficiency
    coarse_step = max(1, floor(n_bins / 64));
    for i = coarse_step:coarse_step:n_bins-coarse_step
        % Ensure index is within bounds
        if i < 1 || i >= n_bins
            continue;
        end
        
        variance = compute_between_class_variance(i, counts, prefix_sums, total_pixels, total_intensity);
        if variance > max_variance
            max_variance = variance;
            threshold = valid_range(i);
        end
    end
    
    % Fine sweep around the best coarse result
    coarse_threshold_idx = find(valid_range == threshold, 1);
    if isempty(coarse_threshold_idx)
        coarse_threshold_idx = 1;
    end
    
    fine_start = max(1, coarse_threshold_idx - coarse_step);
    fine_end = min(n_bins - 1, coarse_threshold_idx + coarse_step);
    
    for i = fine_start:fine_end
        % Double-check bounds
        if i < 1 || i >= n_bins
            continue;
        end
        
        variance = compute_between_class_variance(i, counts, prefix_sums, total_pixels, total_intensity);
        if variance > max_variance
            max_variance = variance;
            threshold = valid_range(i);
        end
    end
end

function threshold = find_additional_threshold(counts, valid_range, prefix_sums, prev_thresholds)
% Find additional threshold considering existing thresholds
    
    n_bins = length(counts);
    max_variance = -1;
    threshold = valid_range(1);
    
    % Convert previous thresholds to indices
    prev_indices = zeros(size(prev_thresholds));
    for i = 1:length(prev_thresholds)
        idx = find(valid_range == prev_thresholds(i), 1);
        if ~isempty(idx)
            prev_indices(i) = idx;
        else
            prev_indices(i) = 1; % Fallback
        end
    end
    prev_indices = sort(prev_indices);
    
    % Search in gaps between existing thresholds
    search_ranges = [1, prev_indices, n_bins];
    
    for r = 1:length(search_ranges)-1
        range_start = max(1, search_ranges(r) + 1);
        range_end = min(n_bins - 1, search_ranges(r+1) - 1);
        
        if range_start >= range_end
            continue;
        end
        
        % Coarse search in this range
        range_size = range_end - range_start + 1;
        coarse_step = max(1, floor(range_size / 16));
        
        for i = range_start:coarse_step:range_end
            if i < 1 || i >= n_bins
                continue;
            end
            
            variance = compute_multi_class_variance(i, counts, prefix_sums, prev_indices);
            if variance > max_variance
                max_variance = variance;
                threshold = valid_range(i);
            end
        end
        
        % Fine search around best result in this range
        best_idx = find(valid_range == threshold, 1);
        if ~isempty(best_idx)
            fine_start = max(range_start, best_idx - coarse_step);
            fine_end = min(range_end, best_idx + coarse_step);
            
            for i = fine_start:fine_end
                if i < 1 || i >= n_bins
                    continue;
                end
                
                variance = compute_multi_class_variance(i, counts, prefix_sums, prev_indices);
                if variance > max_variance
                    max_variance = variance;
                    threshold = valid_range(i);
                end
            end
        end
    end
end

function variance = compute_between_class_variance(threshold_idx, counts, prefix_sums, total_pixels, total_intensity)
% Compute between-class variance for two classes
    
    if threshold_idx < 1 || threshold_idx >= length(counts)
        variance = 0;
        return;
    end
    
    % Class 1: [0, threshold_idx-1]
    w1 = prefix_sums.count(threshold_idx);
    if w1 == 0
        variance = 0;
        return;
    end
    
    mu1 = prefix_sums.intensity(threshold_idx) / w1;
    
    % Class 2: [threshold_idx, end]
    w2 = total_pixels - w1;
    if w2 == 0
        variance = 0;
        return;
    end
    
    mu2 = (total_intensity - prefix_sums.intensity(threshold_idx)) / w2;
    
    % Between-class variance
    variance = w1 * w2 * (mu1 - mu2)^2;
end

function variance = compute_multi_class_variance(new_threshold_idx, counts, prefix_sums, existing_indices)
% Compute variance for multiple classes
    
    if new_threshold_idx < 1 || new_threshold_idx >= length(counts)
        variance = 0;
        return;
    end
    
    % Combine and sort all threshold indices
    all_indices = sort([existing_indices, new_threshold_idx]);
    all_indices = unique(all_indices); % Remove duplicates
    
    n_classes = length(all_indices) + 1;
    class_weights = zeros(1, n_classes);
    class_means = zeros(1, n_classes);
    
    total_pixels = sum(counts);
    
    % Compute class statistics
    prev_idx = 0;
    for c = 1:n_classes
        if c <= length(all_indices)
            end_idx = all_indices(c);
        else
            end_idx = length(counts);
        end
        
        % Ensure bounds
        start_idx = max(1, prev_idx + 1);
        end_idx = min(length(counts), end_idx);
        
        if start_idx <= end_idx
            if start_idx == 1
                class_weights(c) = prefix_sums.count(end_idx);
                if class_weights(c) > 0
                    class_means(c) = prefix_sums.intensity(end_idx) / class_weights(c);
                end
            else
                class_weights(c) = prefix_sums.count(end_idx) - prefix_sums.count(start_idx - 1);
                if class_weights(c) > 0
                    class_means(c) = (prefix_sums.intensity(end_idx) - prefix_sums.intensity(start_idx - 1)) / class_weights(c);
                end
            end
        end
        
        prev_idx = end_idx;
    end
    
    % Normalize weights
    class_weights = class_weights / total_pixels;
    
    % Compute overall mean
    overall_mean = sum(class_weights .* class_means);
    
    % Compute between-class variance
    variance = sum(class_weights .* (class_means - overall_mean).^2);
end