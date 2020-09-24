const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { expectRevert, ether, BN, send } = require('@openzeppelin/test-helpers');

const { expect } = require('chai');

const HashForEtherVisibilityNotSet = 
  contract.fromArtifact('HashForEtherVisibilityNotSet');
const HashForEtherVisibilityNotSetFixed = 
  contract.fromArtifact('HashForEtherVisibilityNotSetFixed');

/**
 * Return the balance of given account
 *
 * @param {string} The address of the account to query
 * @returns {BN} The balance as a BN object
 */
async function getBal(account) {
  return new BN(await web3.eth.getBalance(account));
}

describe("100-Function-Default-Visibility", function(){
  describe("HashForEtherVisibilityNotSet", function(){
    let notFixed;
    let gasPrice;
    const [ funder, attacker ] = accounts ;
    before(async function(){
      notFixed = await HashForEtherVisibilityNotSet.new();
      await notFixed.send(ether("1"), {from: funder});
      gasPrice = new BN(await web3.eth.getGasPrice());
    });
    
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
  });
  
  describe("HashForEtherVisibilityNotSetFixed", function(){
    let fixed;
    let gasPrice;
    const [ funder, attacker ] = accounts ;
    before(async function(){
      fixed = await HashForEtherVisibilityNotSetFixed.new();
      await fixed.send(ether("1"), {from: funder});
      gasPrice = new BN(await web3.eth.getGasPrice());
    });
    
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
  });
});
