134-Message-Call-Hardcoded-Gas
==============================

Adapted From
`SWC 134 <https://swcregistry.io/docs/SWC-134>`_.

Description
-----------

The transfer() and send() functions forward only 2300 gas. This means
that contracts that make assumptions about fixed gas costs can be
broken. This has occurred in the past with 
`EIP 1884 <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1884.md>`_.

Remediation
-----------

Avoid the use of transfer() and send() and do not otherwise specify
a fixed amount of gas when performing calls. Use .call{value: ...}("")
instead. Use the checks-effects-interactions pattern and/or reentrancy
locks to prevent reentrancy attacks.

Examples
--------

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 23,27,31,35,50,55
   
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

Contract Interfaces
-------------------



.. autosolcontract:: CallableContract
   :members:
   :undoc-members:

.. autosolcontract:: HardcodedGasLimits
   :members:
   :undoc-members:

.. autosolcontract:: HardcodedGasLimitsFixed
   :members:
   :undoc-members:



Tests
-----

None
