// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

/// @dev A contract that demonstrates unprotected Ether withdrawals.
contract SimpleEtherDrain {
    /// @dev This function is unguarded meaning that anyone can withdraw
    /// the entire balance of the contract.
    function withdrawAllAnyone() external {
        msg.sender.transfer(address(this).balance);
    }

    /// @dev A receive function to fund the contract. 
    receive() external payable {
        
    }
}

contract SimpleEtherDrainFixed {
    
    address private _owner;
    
    /// @dev The constructor sets the owner as the address which 
    /// deployed the contract.
    constructor() {
        _owner = msg.sender;
    }
    
    /// @dev The function is guarded so that only the owner may
    /// withdraw from the contract.
    function withdrawAllAnyone() external {
        require(msg.sender == _owner, "Only the owner can make withdrawals");
        msg.sender.transfer(address(this).balance);
    }
    
    /// @dev A receive function to fund the contract.
    receive() external payable {
        
    }    
}
