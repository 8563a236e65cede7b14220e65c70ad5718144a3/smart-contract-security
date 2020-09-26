// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "../../math/SafeMath.sol";

/// @dev This contract shows a simple overflow by taking an
/// uninitialized mapping (values default to the zero value for
/// the type) and subtracts a value from it. Since the mapping
/// maps to an unsigned 256 bit integer that is zero, any subtraction
/// will cause an overflow.
///
/// Single transaction overflow.
contract IntegerOverflowMappingSym1 {
    mapping(uint256 => uint256) public map;
    
    /// @dev Subtracts v from value at index k.
    /// @param k The index supplied to the mapping
    /// @param v The value to subtract
    function init(uint256 k, uint256 v) public {
        map[k] -= v;
    }
}

/// @dev The fixed version of this contract using SafeMath. Now
/// subtraction should revert.
contract IntegerOverflowMappingSym1Fixed {
    using SafeMath for uint256;
    
    mapping(uint256 => uint256) public map;
    
    /// @dev Subtracts v from value at index k.
    /// @param k The index supplied to the mapping
    /// @param v The value to subtract
    function init(uint256 k, uint256 v) public {
        map[k] = map[k].sub(v);
    }
}