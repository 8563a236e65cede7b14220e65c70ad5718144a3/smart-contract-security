// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/// @dev This contract illustrates the dangers of not explicitly
/// setting visibility for functions. Critical private functions
/// then become exposed to malicious intent
contract HashForEtherVisibilityNotSet {
    
    /// @dev A function intended to be external
    /// but no visibility set. This calls _sendWinnings()
    /// which is intended to be a private function. Without
    /// visibility withdrawWinnings is public but will work
    /// as intended.
    function withdrawWinnings() public { // compiler errors with 0.7.0 if no visibility set
        require(uint32(msg.sender) == 0);
        _sendWinnings();
    }
    
    /// @dev A function intended to be internal. Without visibility
    /// specified, it is now public meaning that a malicious user
    /// could transfer the remainder of the contract balance
    /// to themselves by calling this function
    function _sendWinnings() public { // compiler errors with 0.7.0 if no visibility set
        msg.sender.transfer(address(this).balance);
    }
    
    /// @dev Receive function to fund with some balance
    receive() external payable {
        
    }
}

/// @dev The fixed version of this contract. 
contract HashForEtherVisibilityNotSetFixed {
    
    /// @dev Proper external visibility applied.
    /// Now the function can only be called from outside of
    /// the contract.
    function withdrawWinnings() external {
        require(uint32(msg.sender) == 0);
        _sendWinnings();
    }
    
    /// @dev Proper internal visibility applied. Now only
    /// this contract and contracts that inherit from it
    /// can access _sendWinnings(). [private disallows use
    /// of the function by inheriting contracts]
    function _sendWinnings() internal {
        msg.sender.transfer(address(this).balance);
    }
    
    /// @dev Receive function to fund with some balance
    receive() external payable {
        
    }
}