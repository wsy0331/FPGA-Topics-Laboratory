function prefix_sums = calc_prefix_sum_hdl(counts)
% CALC_PREFIX_SUM_HDL Compute prefix sums for histogram data
%
% Input:
%   counts - Histogram count array (1D array)
%
% Output:
%   prefix_sums - Structure containing cumulative count and intensity sums
%                 .count - cumulative sum of counts
%                 .intensity - cumulative sum of intensity-weighted counts
%
% This function computes prefix sums during data preparation to reduce
% runtime complexity of threshold optimization. The hardware-friendly
% implementation ensures efficient computation suitable for FPGA implementation.

    % Input validation
    if ~isvector(counts) || ~isnumeric(counts)
        error('Input must be a numeric vector');
    end
    
    % Ensure counts is a row vector
    counts = double(counts(:)');
    n_bins = length(counts);
    
    if n_bins == 0
        error('Input counts array cannot be empty');
    end
    
    % Ensure non-negative counts
    counts = max(0, counts);
    
    % Initialize output structure
    prefix_sums = struct();
    
    % Pre-allocate arrays for efficiency
    prefix_sums.count = zeros(1, n_bins);
    prefix_sums.intensity = zeros(1, n_bins);
    
    % Compute prefix sums using hardware-friendly approach
    % This implementation is optimized for potential FPGA synthesis
    
    % Running sum variables
    cumulative_count = 0;
    cumulative_intensity = 0;
    
    for i = 1:n_bins
        % Add current bin contribution
        cumulative_count = cumulative_count + counts(i);
        cumulative_intensity = cumulative_intensity + counts(i) * (i - 1); % i-1 for 0-based indexing
        
        % Store cumulative values
        prefix_sums.count(i) = cumulative_count;
        prefix_sums.intensity(i) = cumulative_intensity;
    end
    
    % Validate results
    if prefix_sums.count(end) ~= sum(counts)
        warning('Prefix sum validation failed for counts');
    end
    
    expected_intensity_sum = sum(counts .* (0:n_bins-1));
    if abs(prefix_sums.intensity(end) - expected_intensity_sum) > 1e-10
        warning('Prefix sum validation failed for intensity');
    end
    
    % Add utility functions for common operations
    prefix_sums.get_range_count = @(start_idx, end_idx) get_range_count_impl(prefix_sums.count, start_idx, end_idx);
    prefix_sums.get_range_intensity = @(start_idx, end_idx) get_range_intensity_impl(prefix_sums.intensity, start_idx, end_idx);
end

function range_count = get_range_count_impl(count_prefix, start_idx, end_idx)
% Get count sum for a specific range [start_idx, end_idx] (1-based indexing)
    
    % Input validation and bounds checking
    if start_idx < 1 || end_idx > length(count_prefix) || start_idx > end_idx
        range_count = 0;
        return;
    end
    
    % Compute range sum using prefix sums
    if start_idx == 1
        range_count = count_prefix(end_idx);
    else
        range_count = count_prefix(end_idx) - count_prefix(start_idx - 1);
    end
    
    % Ensure non-negative result
    range_count = max(0, range_count);
end

function range_intensity = get_range_intensity_impl(intensity_prefix, start_idx, end_idx)
% Get intensity sum for a specific range [start_idx, end_idx] (1-based indexing)
    
    % Input validation and bounds checking
    if start_idx < 1 || end_idx > length(intensity_prefix) || start_idx > end_idx
        range_intensity = 0;
        return;
    end
    
    % Compute range sum using prefix sums
    if start_idx == 1
        range_intensity = intensity_prefix(end_idx);
    else
        range_intensity = intensity_prefix(end_idx) - intensity_prefix(start_idx - 1);
    end
    
    % Ensure non-negative result
    range_intensity = max(0, range_intensity);
end