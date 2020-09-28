105-Unprotected-Ether-Withdrawal
================================

Adapted From
`SWC 105 <https://swcregistry.io/docs/SWC-105>`_.

Description
-----------

If you do not implement adequate access controls, an attacker can
withdraw some or all Ether from the contract account.

You can sometimes trigger this bug by unintentionally exposing
initialization functions. By wrongly naming a function intended to be
a constructor (or not guarding an initializer function), the constructor
code ends up in the runtime byte code and can be called by anyone to
re-initialize the contract.

Remediation
-----------

Implement controls so withdrawals can only be triggered by authorized 
parties or according to the specs of the smart contract system.

Examples
--------

SimpleEtherDrain
^^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 3,20
   
   contract SimpleEtherDrain {
       function withdrawAllAnyone() {
           msg.sender.transfer(address(this).balance);
       }
       
       receive() external payable {
           
       }
   }
   
   contract SimpleEtherDrainFixed {
       
       address private _owner;

       constructor() {
           _owner = msg.sender;
       }

       function withdrawAllAnyone() {
           require(msg.sender == _owner);
           msg.sender.transfer(address(this).balance);
       }
       
       receive() external payable {
           
       }    
   }

WalletWrongConstructor
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 7,35
 
   contract WalletWrongConstructor {
       address creator;
       
       mapping(address => uint256) balances;
   
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
   
       function migrateTo(address to) public {
           require(creator == msg.sender);
           payable(to).transfer(address(this).balance);
       }
       
       receive() external payable {
           
       }
   
   }
   
   contract WalletWrongConstructorFixed {
       address creator;
       
       mapping(address => uint256) balances;
   
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
   
       function migrateTo(address to) public {
           require(creator == msg.sender);
           payable(to).transfer(address(this).balance);
       }
   
       receive() external payable {
           
       }
       
   }


Contract Interfaces
-------------------

SimpleEtherDrain
^^^^^^^^^^^^^^^^

.. autosolcontract:: SimpleEtherDrain
   :members:
   :undoc-members:

.. autosolcontract:: SimpleEtherDrainFixed
   :members:
   :undoc-members:

WalletWrongConstructor
^^^^^^^^^^^^^^^^^^^^^^

.. autosolcontract:: WalletWrongConstructor
   :members:
   :undoc-members:

.. autosolcontract:: WalletWrongConstructorFixed
   :members:
   :undoc-members:

Tests
-----

SimpleEtherDrain
^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

   it(
      "allows anyone to withdraw from the contract",
      async function(){
         gasPrice = new BN(await web3.eth.getGasPrice());
         
         let simpleEtherDrain = await SimpleEtherDrain.new({ from: funder });
         await simpleEtherDrain.send(ether("1"), {from: funder});
         let initContractBalance = await getBal(simpleEtherDrain.address);
         let initAttackerBalance = await getBal(attacker);
         
         let txReceipt = await simpleEtherDrain.withdrawAllAnyone({ from: attacker });
         
         let gasUsed = gasPrice.mul(new BN(txReceipt.receipt.gasUsed));
         
         let expectedAttackerBalance = initAttackerBalance
                                       .sub(gasUsed)
                                       .add(ether("1"));
         
         let finalAttackerBalance = await getBal(attacker);
         
         expect(finalAttackerBalance).to.be.bignumber.equal(expectedAttackerBalance);
         
      }
   )

SimpleEtherDrainFixed
^^^^^^^^^^^^^^^^^^^^^
   
.. code-block:: javascript
   :linenos:

   it(
      "does not allow anyone but owner to withdraw",
      async function(){
         gasPrice = new BN(await web3.eth.getGasPrice());
         
         let simpleEtherDrainFixed = await SimpleEtherDrainFixed.new({ from: funder });
         await simpleEtherDrainFixed.send(ether("1"), {from: funder});
         
         await expectRevert(
            simpleEtherDrainFixed.withdrawAllAnyone({ from: attacker }),
            "Only the owner can make withdrawals"
         );
         
         let initFunderBalance = await getBal(funder);
         
         let txReceipt = await simpleEtherDrainFixed.withdrawAllAnyone({ from: funder });
         
         let gasUsed = gasPrice.mul(new BN(txReceipt.receipt.gasUsed));
         
         let expectedFunderBalance = initFunderBalance
                                       .sub(gasUsed)
                                       .add(ether("1"));
         
         let finalFunderBalance = await getBal(funder);
         
         expect(finalFunderBalance).to.be.bignumber.equal(expectedFunderBalance);

      }
   )

WalletWrongConstructor
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:
   
   it(
      "allows reinitialization to reset owner and thus steal funds",
      async function(){
         let walletWrongConstructor = await WalletWrongConstructor.new({ from: funder });
         await walletWrongConstructor.send(ether("1"), { from: funder });
            
         let initContractBalance = await getBal(walletWrongConstructor.address);
         await walletWrongConstructor.initWallet({ from: attacker });
         let initAttackerBalance = await getBal(attacker);
         let txReceipt = await walletWrongConstructor.migrateTo(attacker, { from: attacker });
         let gasUsed = gasPrice.mul(new BN(txReceipt.receipt.gasUsed));
            
         let expectedAttackerBalance = initAttackerBalance
                                       .sub(gasUsed)
                                       .add(ether("1"));
            
         let finalContractBalance = await getBal(walletWrongConstructor.address);
         let finalAttackerBalance = await getBal(attacker);
            
         expect(finalAttackerBalance).to.be.bignumber.equal(expectedAttackerBalance);
         expect(finalContractBalance).to.be.bignumber.equal(new BN("0"));

      }
   );
      
WalletWrongConstructorFixed
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

   it(
      "cannot reinitialize contract",
      async function(){
         let errorReturn = null;
         let walletWrongConstructorFixed = await WalletWrongConstructorFixed.new({ from: funder });
         await walletWrongConstructorFixed.send(ether("1"), { from: funder });
            
         try {
            await walletWrongConstructorFixed.constructor({from: attacker})
         } catch(err) {
            errorReturn = err;
         }
   
         expect(errorReturn.message).to.equal("Cannot read property 'address' of undefined")
      }
   );
