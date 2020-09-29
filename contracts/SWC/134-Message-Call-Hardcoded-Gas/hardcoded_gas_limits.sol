// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

contract CallableContract {
    function calledFunction() external {
        
    }
    
    receive() external payable {
        
    }
}

contract HardcodedGasLimits {
    address _callable;
    CallableContract callable;
    
    constructor(address _callableAddress) {
        _callable = _callableAddress;
        callable = CallableContract(payable(_callable));
    }
    
    function doTransfer(uint256 amount) public {
        payable(_callable).transfer(amount);
    }

    function doSend(uint256 amount) public {
        payable(_callable).send(amount);
    }
    
    function callLowLevel() public {
        payable(_callable).call{value: 0, gas: 10000}("");
    }
    
    function callWithArgs() public {
        callable.calledFunction{gas: 10000}();
    }
    
}

contract HardcodedGasLimitsFixed {
    address _callable;
    CallableContract callable;
    
    constructor(address _callableAddress) {
        _callable = _callableAddress;
        callable = CallableContract(payable(_callable));
    }
    
    function doCallTransfer(uint256 amount) public {
        payable(_callable).call{value: amount}("");
    }
    
    function callWithArgs(uint256 amount, string memory signature) public {
        bool success = false;
        address(callable).call{value: amount}(abi.encodeWithSignature("calledFunction()"));
    }
    
}