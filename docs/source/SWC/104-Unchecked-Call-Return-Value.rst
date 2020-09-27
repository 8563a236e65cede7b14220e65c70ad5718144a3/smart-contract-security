104-Unchecked-Call-Return-Value
===============================

Adapted From
`SWC 104 <https://swcregistry.io/docs/SWC-104>`_.

Description
-----------

The return value of a message call is not checked when calling an
external contract. Execution will resume even if the called contract
throws an exception. If the call fails accidentally or an attacker
forces the call to fail, this may cause unexpected behaviour in the
subsequent program logic.

Remediation
-----------

Make sure to check the return values of all low-level call methods and
handle the possibility that the call may fail.

Examples
--------

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 11
   
   contract ReturnValue {
       
       function callChecked(address callee) public {
           bytes memory payload = abi.encodeWithSignature("myFunc()");
           (bool success, bytes memory returnData) = callee.call(payload);
           require(success, "Call Failed");
       }
       
       function callNotChecked(address callee) public {
           bytes memory payload = abi.encodeWithSignature("myFunc()");
           callee.call(payload);
       }
   
   }
   
   contract ReturnValueAttacker {
       
       function myFunc() external pure {
           revert("Will always revert");
       }
       
   }

Contract Interfaces
-------------------

.. autosolcontract:: ReturnValue
   :members:
   :undoc-members:

.. autosolcontract:: ReturnValueAttacker
   :members:
   :undoc-members:

Tests
-----

.. code-block:: javascript
   :linenos:
   
   it(
      "does not revert on call failure",
      async function(){
         returnValue = await ReturnValue.new()
         returnValueAttacker = await ReturnValueAttacker.new();
         
         await returnValue.callNotChecked(returnValueAttacker.address);
      }
   );
   
   it(
      "reverts on call failure",
      async function(){
         returnValue = await ReturnValue.new()
         returnValueAttacker = await ReturnValueAttacker.new();
         
         await expectRevert(
            returnValue.callChecked(returnValueAttacker.address),
            "Call Failed"
         );
      }
   );
