// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "../../math/SafeMath.sol";

/// @dev The minimal example of overflow using subtraction
/// from an unsigned integer.
///
/// Single transaction overflow
/// Post-transaction effect: overflow escapes to publicly-readable
/// storage.
contract IntegerOverflowMinimal {
    /// @dev A 256bit unsigned integer initialized to 1
    uint256 public count = 1;
    
    /// @dev Overflow will be cause with input greater than or equal
    /// to 2. 
    /// @param input A positive number to be subtracted from the count
    /// state variable
    function run(uint256 input) public {
        count -= input;
    }
}

/// @dev Using SafeMath to guard against overflows
contract IntegerOverflowMinimalFixed {
    using SafeMath for uint256;
    
    /// @dev A 256bit unsigned integer initialized to 1
    uint256 public count = 1;
    
    /// @dev Overflow will cause revert with input greater than or equal
    /// to 2. 
    /// @param input A positive number to be subtracted from the count
    /// state variable
    function run(uint256 input) public {
        count = count.sub(input);
    }
}