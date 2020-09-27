// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/// @dev A contract that uses an external call in two different
/// functions. :sol:func:`callChecked` correctly checks the return
/// value while :sol:func:`callNotChecked` does not, thus allowing
/// the possibility of errors.
contract ReturnValue {
    
    /// @dev Checks the return value of the call.
    /// @param callee The address of the external contract to call
    function callChecked(address callee) public {
        bytes memory payload = abi.encodeWithSignature("myFunc()");
        (bool success, bytes memory returnData) = callee.call(payload);
        require(success, "Call Failed");
    }
    
    /// @dev Does not check the return value of the call.
    /// @param callee The address of the external contract to call
    function callNotChecked(address callee) public {
        bytes memory payload = abi.encodeWithSignature("myFunc()");
        callee.call(payload);
    }

}

/// @dev A simple contract with one function that always reverts.
/// Simulates an attacker making the call fail.
contract ReturnValueAttacker {
    
    /// @dev A function that will always revert.
    function myFunc() external pure {
        revert("Will always revert");
    }
    
}