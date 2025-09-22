# Multi-Otsu Thresholding Implementation

This repository contains an improved implementation of multi-level Otsu thresholding with enhanced bounds checking and optimized prefix sum computation for FPGA applications.

## Files

- `multi_otsu_fix.m` - Main function implementing multi-level Otsu thresholding with bounds checking
- `calc_prefix_sum_hdl.m` - Hardware-friendly prefix sum computation function
- `test_multi_otsu_fix.m` - Comprehensive test suite

## Key Improvements

### 1. Bounds Checking
- Prevents negative array indices through comprehensive validation
- Ensures all indices remain within valid bounds [0, 255]
- Handles edge cases like empty regions and uniform images

### 2. Optimized Coarse/Fine Sweep Logic
- **Coarse Sweep**: Efficiently searches every nth bin to identify promising regions
- **Fine Sweep**: Refines the search around the best coarse result
- All index operations are verified before use to prevent out-of-bounds errors

### 3. Prefix Sum Optimization
- Computes cumulative sums during data preparation phase
- Enables O(1) range queries during threshold optimization
- Reduces overall runtime complexity from O(n²) to O(n)
- Hardware-friendly implementation suitable for FPGA synthesis

## Usage

```matlab
% Basic usage with single threshold
image = imread('your_image.jpg');
threshold = multi_otsu_fix(image, 1);

% Multiple thresholds
thresholds = multi_otsu_fix(image, 3);

% Prefix sum computation
counts = histcounts(image(:), 0:256);
prefix_sums = calc_prefix_sum_hdl(counts);
```

## Testing

Run the comprehensive test suite:
```matlab
test_multi_otsu_fix
```

## Performance

The implementation has been optimized for:
- **Efficiency**: O(n) prefix sum computation with O(1) range queries
- **Robustness**: Comprehensive bounds checking prevents runtime errors
- **Hardware Compatibility**: Algorithms designed for FPGA implementation
- **Accuracy**: Maintains Otsu's method optimality while improving safety

## Validation

All test cases pass, including:
- Basic functionality verification
- Bounds checking validation
- Edge case handling (empty, uniform, extreme images)
- Multi-threshold scenarios
- Performance benchmarks
- Real image simulation

The implementation successfully handles all edge cases while maintaining optimal performance and accuracy.