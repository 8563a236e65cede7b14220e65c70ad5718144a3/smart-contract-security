pragma solidity ^0.7.0;

/// @dev User can add pay in and withdraw Ether.
/// The constructor is wrongly named, so anyone can become 'creator' and withdraw all funds. 
contract WalletWrongConstructor {
    address creator;
    
    mapping(address => uint256) balances;

    /// @dev This initialization function can be called multiple times.
    function initWallet() public {
        creator = msg.sender;
    }

    function deposit() public payable {
        assert(balances[msg.sender] + msg.value > balances[msg.sender]);
        balances[msg.sender] += msg.value;
    }
    
    function withdraw(uint256 amount) public {
        require(amount <= balances[msg.sender]);
        msg.sender.transfer(amount);
        balances[msg.sender] -= amount;
    }

    /// @dev This function will allow the attacker to transfer the
    /// contract balance to any address of their choosing
    function migrateTo(address to) public {
        require(creator == msg.sender);
        payable(to).transfer(address(this).balance);
    }
    
    /// @dev Receive function for funding purposes in test environment
    receive() external payable {
        
    }

}

/// @dev User can add pay in and withdraw Ether.
/// The constructor is wrongly named, so anyone can become 'creator' and withdraw all funds. 
contract WalletWrongConstructorFixed {
    address creator;
    
    mapping(address => uint256) balances;

    /// @dev Constructors are not stored with the runtime code and
    /// hence this initialization is inaccessible.
    constructor () {
        creator = msg.sender;
    }

    function deposit() public payable {
        assert(balances[msg.sender] + msg.value > balances[msg.sender]);
        balances[msg.sender] += msg.value;
    }
    
    function withdraw(uint256 amount) public {
        require(amount <= balances[msg.sender]);
        msg.sender.transfer(amount);
        balances[msg.sender] -= amount;
    }

    /// @dev Since the attacker cannot reinitialize the contract,
    /// this function is now safe.
    function migrateTo(address to) public {
        require(creator == msg.sender);
        payable(to).transfer(address(this).balance);
    }

    /// @dev Receive function for funding purposes in test environment
    receive() external payable {
        
    }
    
}
