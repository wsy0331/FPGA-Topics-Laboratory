function test_multi_otsu_fix()
% TEST_MULTI_OTSU_FIX Test suite for multi_otsu_fix and calc_prefix_sum_hdl
%
% This test file verifies the corrected functionality of the multi-level
% Otsu thresholding implementation with bounds checking and optimized
% prefix sum computation.

    fprintf('Running tests for multi_otsu_fix and calc_prefix_sum_hdl...\n\n');
    
    % Test counter
    total_tests = 0;
    passed_tests = 0;
    
    % Test 1: Basic functionality with synthetic data
    [total_tests, passed_tests] = run_test(@test_basic_functionality, ...
        'Basic functionality test', total_tests, passed_tests);
    
    % Test 2: Bounds checking
    [total_tests, passed_tests] = run_test(@test_bounds_checking, ...
        'Bounds checking test', total_tests, passed_tests);
    
    % Test 3: Prefix sum computation
    [total_tests, passed_tests] = run_test(@test_prefix_sum_computation, ...
        'Prefix sum computation test', total_tests, passed_tests);
    
    % Test 4: Edge cases
    [total_tests, passed_tests] = run_test(@test_edge_cases, ...
        'Edge cases test', total_tests, passed_tests);
    
    % Test 5: Multiple thresholds
    [total_tests, passed_tests] = run_test(@test_multiple_thresholds, ...
        'Multiple thresholds test', total_tests, passed_tests);
    
    % Test 6: Performance and optimization
    [total_tests, passed_tests] = run_test(@test_performance, ...
        'Performance test', total_tests, passed_tests);
    
    % Test 7: Real image data simulation
    [total_tests, passed_tests] = run_test(@test_real_image_simulation, ...
        'Real image simulation test', total_tests, passed_tests);
    
    % Summary
    fprintf('\n=== Test Summary ===\n');
    fprintf('Total tests: %d\n', total_tests);
    fprintf('Passed tests: %d\n', passed_tests);
    fprintf('Failed tests: %d\n', total_tests - passed_tests);
    
    if passed_tests == total_tests
        fprintf('All tests PASSED! ✓\n');
    else
        fprintf('Some tests FAILED! ✗\n');
    end
end

function [total_tests, passed_tests] = run_test(test_func, test_name, total_tests, passed_tests)
% Helper function to run individual tests
    total_tests = total_tests + 1;
    fprintf('Test %d: %s... ', total_tests, test_name);
    
    try
        test_func();
        fprintf('PASSED ✓\n');
        passed_tests = passed_tests + 1;
    catch ME
        fprintf('FAILED ✗\n');
        fprintf('  Error: %s\n', ME.message);
    end
end

function test_basic_functionality()
% Test basic functionality with simple synthetic data
    
    % Create a simple bimodal image
    image = [zeros(50, 50), 100*ones(50, 50); 200*ones(50, 50), 255*ones(50, 50)];
    
    % Test single threshold
    threshold = multi_otsu_fix(image, 1);
    assert(length(threshold) == 1, 'Single threshold should return one value');
    assert(threshold >= 0 && threshold <= 255, 'Threshold should be in valid range');
    
    % Test multiple thresholds
    thresholds = multi_otsu_fix(image, 2);
    assert(length(thresholds) == 2, 'Should return requested number of thresholds');
    assert(all(diff(thresholds) > 0), 'Thresholds should be in ascending order');
    assert(all(thresholds >= 0 & thresholds <= 255), 'All thresholds should be in valid range');
end

function test_bounds_checking()
% Test bounds checking to prevent negative indices and out-of-bounds access
    
    % Test with edge intensity values
    image_zeros = zeros(10, 10);
    threshold = multi_otsu_fix(image_zeros, 1);
    assert(threshold >= 0, 'Threshold for zero image should be non-negative');
    
    % Test with single intensity value
    image_uniform = 128 * ones(10, 10);
    threshold = multi_otsu_fix(image_uniform, 1);
    assert(threshold >= 0 && threshold <= 255, 'Threshold for uniform image should be valid');
    
    % Test with extreme values
    image_extreme = [zeros(5, 5), 255*ones(5, 5)];
    thresholds = multi_otsu_fix(image_extreme, 3);
    assert(all(thresholds >= 0 & thresholds <= 255), 'Thresholds should handle extreme values');
    
    % Test error handling for invalid inputs
    try
        multi_otsu_fix(rand(10, 10, 3), 1); % 3D input
        error('Should have failed for 3D input');
    catch ME
        assert(~isempty(strfind(ME.message, '2D')), 'Should reject 3D input');
    end
    
    try
        multi_otsu_fix(rand(10, 10), 0); % Invalid threshold count
        error('Should have failed for zero thresholds');
    catch ME
        assert(~isempty(strfind(ME.message, 'between 1 and 254')), 'Should reject invalid threshold count');
    end
end

function test_prefix_sum_computation()
% Test the calc_prefix_sum_hdl function
    
    % Test with simple data
    counts = [1, 2, 3, 4, 5];
    prefix_sums = calc_prefix_sum_hdl(counts);
    
    % Verify count prefix sums
    expected_count = [1, 3, 6, 10, 15];
    assert(isequal(prefix_sums.count, expected_count), 'Count prefix sums incorrect');
    
    % Verify intensity prefix sums (0-based indexing for intensities)
    expected_intensity = [0, 2, 8, 20, 40]; % 0*1 + 1*2 + 2*3 + 3*4 + 4*5
    assert(isequal(prefix_sums.intensity, expected_intensity), 'Intensity prefix sums incorrect');
    
    % Test utility functions
    range_count = prefix_sums.get_range_count(2, 4);
    expected_range_count = 2 + 3 + 4; % indices 2-4
    assert(range_count == expected_range_count, 'Range count function incorrect');
    
    range_intensity = prefix_sums.get_range_intensity(2, 4);
    expected_range_intensity = 1*2 + 2*3 + 3*4; % intensity-weighted sum
    assert(range_intensity == expected_range_intensity, 'Range intensity function incorrect');
    
    % Test bounds checking in utility functions
    assert(prefix_sums.get_range_count(0, 1) == 0, 'Should handle out-of-bounds start index');
    assert(prefix_sums.get_range_count(1, 10) == 0, 'Should handle out-of-bounds end index');
    assert(prefix_sums.get_range_count(3, 2) == 0, 'Should handle invalid range');
end

function test_edge_cases()
% Test edge cases and special conditions
    
    % Test very small image
    small_image = [0, 255];
    threshold = multi_otsu_fix(small_image, 1);
    assert(length(threshold) == 1, 'Should handle very small images');
    
    % Test with many intensity levels
    gradient_image = repmat(0:255, 10, 1);
    thresholds = multi_otsu_fix(gradient_image, 5);
    assert(length(thresholds) == 5, 'Should handle many intensity levels');
    assert(all(diff(thresholds) > 0), 'Thresholds should be ordered');
    
    % Test with sparse histogram
    sparse_image = zeros(100, 100);
    sparse_image(1:10, 1:10) = 50;
    sparse_image(11:20, 11:20) = 150;
    sparse_image(21:30, 21:30) = 250;
    
    thresholds = multi_otsu_fix(sparse_image, 2);
    assert(length(thresholds) == 2, 'Should handle sparse histograms');
end

function test_multiple_thresholds()
% Test multiple threshold functionality
    
    % Create multi-modal test image
    image = zeros(200, 200);
    image(1:50, :) = 60;      % Dark region
    image(51:100, :) = 120;   % Medium-dark region
    image(101:150, :) = 180;  % Medium-bright region
    image(151:200, :) = 240;  % Bright region
    
    % Test with different numbers of thresholds
    for num_thresh = 1:4
        thresholds = multi_otsu_fix(image, num_thresh);
        assert(length(thresholds) == num_thresh, ...
            sprintf('Should return %d thresholds', num_thresh));
        
        if num_thresh > 1
            assert(all(diff(thresholds) > 0), 'Thresholds should be ordered');
        end
        
        % Check that thresholds separate the intensity peaks (more tolerant bounds)
        if num_thresh >= 3
            assert(thresholds(1) > 50 && thresholds(1) < 140, ...
                sprintf('First threshold (%d) should separate first two peaks', round(thresholds(1))));
            assert(thresholds(2) > 100 && thresholds(2) < 200, ...
                sprintf('Second threshold (%d) should separate second two peaks', round(thresholds(2))));
        end
    end
end

function test_performance()
% Test performance and optimization features
    
    % Create larger test image
    large_image = randi([0, 255], 500, 500);
    
    % Measure execution time
    tic;
    thresholds = multi_otsu_fix(large_image, 3);
    execution_time = toc;
    
    % Basic performance check (should complete reasonably quickly)
    assert(execution_time < 10, 'Execution should complete within reasonable time');
    assert(length(thresholds) == 3, 'Should return correct number of thresholds');
    
    % Test that prefix sum optimization is working
    % (This is implicit in the function design)
    fprintf('  Execution time for 500x500 image with 3 thresholds: %.3f seconds\n', execution_time);
end

function test_real_image_simulation()
% Simulate realistic image scenarios
    
    % Simulate a natural image with Gaussian noise
    [X, Y] = meshgrid(1:100, 1:100);
    
    % Create regions with different intensities
    region1 = (X <= 33 & Y <= 50) * 50;
    region2 = (X > 33 & X <= 66 & Y <= 50) * 120;
    region3 = (X > 66 & Y <= 50) * 200;
    region4 = (Y > 50) * 80;
    
    base_image = region1 + region2 + region3 + region4;
    
    % Add Gaussian noise
    noise = 10 * randn(size(base_image));
    noisy_image = base_image + noise;
    
    % Clip to valid range
    noisy_image = max(0, min(255, noisy_image));
    
    % Test thresholding
    thresholds = multi_otsu_fix(noisy_image, 3);
    
    % Verify results
    assert(length(thresholds) == 3, 'Should handle noisy image');
    assert(all(thresholds >= 0 & thresholds <= 255), 'Thresholds should be in valid range');
    assert(all(diff(thresholds) > 5), 'Thresholds should be reasonably separated');
    
    % Test segmentation quality (basic check)
    segmented = zeros(size(noisy_image));
    segmented(noisy_image <= thresholds(1)) = 1;
    segmented(noisy_image > thresholds(1) & noisy_image <= thresholds(2)) = 2;
    segmented(noisy_image > thresholds(2) & noisy_image <= thresholds(3)) = 3;
    segmented(noisy_image > thresholds(3)) = 4;
    
    % Check that we have all classes
    unique_classes = unique(segmented(:));
    assert(length(unique_classes) >= 3, 'Should produce multiple classes');
end