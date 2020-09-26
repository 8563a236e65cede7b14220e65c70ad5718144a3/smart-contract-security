// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "../../math/SafeMath.sol";

/// @dev The minimal example of overflow using subtraction
/// from an unsigned integer.
///
/// Single transaction overflow
/// Post-transaction effect: overflow escapes to publicly-readable
/// storage.
contract IntegerOverflowMul {
    /// @dev A 256bit unsigned integer initialized to MAX_UINT256 / 2 + 1
    /// in order to make overflow demonstration easier
    uint256 public count = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    
    /// @dev Overflow will be cause with input greater than or equal
    /// to 2. 
    /// @param input A positive number to be subtracted from the count
    /// state variable
    function run(uint256 input) public {
        count *= input;
    }
}

/// @dev Using SafeMath to guard against overflows
contract IntegerOverflowMulFixed {
    using SafeMath for uint256;
    
    /// @dev A 256bit unsigned integer initialized to MAX_UINT256 / 2 + 1
    /// in order to make overflow demonstration easier
    uint256 public count = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    
    /// @dev Overflow will cause revert with input greater than or equal
    /// to 2. 
    /// @param input A positive number to be subtracted from the count
    /// state variable
    function run(uint256 input) public {
        count = count.mul(input);
    }
}