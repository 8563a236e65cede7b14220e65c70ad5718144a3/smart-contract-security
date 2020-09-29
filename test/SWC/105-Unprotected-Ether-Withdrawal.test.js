const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { expectRevert, ether, BN } = require('@openzeppelin/test-helpers');

const { expect } = require('chai');

const SimpleEtherDrain = contract.fromArtifact('SimpleEtherDrain');
const SimpleEtherDrainFixed = contract.fromArtifact('SimpleEtherDrainFixed');

const WalletWrongConstructor = contract.fromArtifact('WalletWrongConstructor');
const WalletWrongConstructorFixed = contract.fromArtifact('WalletWrongConstructorFixed');

async function getBal(account) {
  return new BN(await web3.eth.getBalance(account));
}

describe("105-Unprotected-Ether-Withdrawal", function(){
   const [ funder, attacker ] = accounts;
   let gasPrice;
   
   describe("Simple Ether Drain", function(){
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
            
            let finalContractBalance = await getBal(simpleEtherDrain.address);
            let finalAttackerBalance = await getBal(attacker);
            
            expect(finalAttackerBalance).to.be.bignumber.equal(expectedAttackerBalance);
            expect(finalContractBalance).to.be.bignumber.equal(new BN("0"));
            
         }
      );
      
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
      );
   });
   
   describe("WalletWrongConstructor", function(){
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
      
      
   });

});
