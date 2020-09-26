100-Function-Default-Visibility
===============================

Adapted From
`SWC 100 <https://swcregistry.io/docs/SWC-100>`_.

Description
-----------

The default visibility of functions is set to public. This means that
if you have a function that you intend to be internal or private, a
malicious user could call that function externally and make unauthorized
or unintended state changes.

Remediation
-----------

Functions can be specified as external, public, internal or private. 
You should ensure that all your functions have the correct visibility
declared and perhaps even explicitly declare public visibility to be
consistent. 

Example
-------

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 3,8,15,20

    contract HashForEtherVisibilityNotSet {
    
        function withdrawWinnings() {
            require(uint32(msg.sender) == 0);
            _sendWinnings();
        }
        
        function _sendWinnings() {
            msg.sender.transfer(address(this).balance);
        }
    }
    
    contract HashForEtherVisibilityNotSetFixed {
        
        function withdrawWinnings() external {
            require(uint32(msg.sender) == 0);
            _sendWinnings();
        }
        
        function _sendWinnings() internal {
            msg.sender.transfer(address(this).balance);
        }
    }

Contract Interfaces
-------------------

.. autosolcontract:: HashForEtherVisibilityNotSet
   :members:
   :undoc-members:

.. autosolcontract:: HashForEtherVisibilityNotSetFixed
   :members:
   :undoc-members:

Tests
-----

HashForEtherVisibilityNotSet
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

   it(
      "allows withdrawal from critical function by attacker",
      async function(){
      let initContractBalance = await getBal(notFixed.address);
      let initAttackerBalance = await getBal(attacker);
      
      let txReceipt = await notFixed._sendWinnings({from: attacker});
      let gasUsed = (new BN(txReceipt.receipt.gasUsed)).mul(gasPrice);
        
      let expectedAttackerBalance = initAttackerBalance
                                    .sub(gasUsed)
                                    .add(initContractBalance);
                                        
      let finalContractBalance = await getBal(notFixed.address);
      let finalAttackerBalance = await getBal(attacker);
        
      expect(finalContractBalance).to.be.eql(new BN("0"));
      expect(finalAttackerBalance).to.be.eql(expectedAttackerBalance);
      }
   );


HashForEtherVisibilityNotSetFixed
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

   it(
      "does not allow withdrawal from critical function by attacker",
      async function(){
         let errorReturn = null;
         try {
            await fixed._sendWinnings({from: attacker})
         } catch(err) {
            errorReturn = err;
         }
        
         expect(errorReturn.message).to.equal("fixed._sendWinnings is not a function")
      }
   );
