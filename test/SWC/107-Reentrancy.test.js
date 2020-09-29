const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { expectRevert, ether, BN } = require('@openzeppelin/test-helpers');

const { expect } = require('chai');

const EtherStore = contract.fromArtifact('EtherStore');
const EtherStoreAttacker = contract.fromArtifact('EtherStoreAttacker');

const EtherStoreFixed = contract.fromArtifact('EtherStoreFixed');
const EtherStoreFixedAttacker = contract.fromArtifact('EtherStoreFixedAttacker');

async function getBal(account) {
  return new BN(await web3.eth.getBalance(account));
}

describe("107-Reentrancy", function(){
   const [ funder, attacker, user1, user2 ] = accounts;
   let gasPrice;
   
   describe("EtherStore", function(){
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
   });
   
   describe("EtherStoreFixed", function(){
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
   });
   
});
