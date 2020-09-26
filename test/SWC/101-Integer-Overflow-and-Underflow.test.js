const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { expectRevert, ether, BN, send, constants } = require('@openzeppelin/test-helpers');

const { expect } = require('chai');

const { MAX_UINT256 } = constants;

const TokenSaleChallenge = contract.fromArtifact('TokenSaleChallenge');
const TokenSaleChallengeFixed = contract.fromArtifact('TokenSaleChallengeFixed');

const IntegerOverflowMappingSym1 = contract.fromArtifact('IntegerOverflowMappingSym1');
const IntegerOverflowMappingSym1Fixed = contract.fromArtifact('IntegerOverflowMappingSym1Fixed');

const IntegerOverflowMinimal = contract.fromArtifact('IntegerOverflowMinimal');
const IntegerOverflowMinimalFixed = contract.fromArtifact('IntegerOverflowMinimalFixed');

const IntegerOverflowMul = contract.fromArtifact('IntegerOverflowMul');
const IntegerOverflowMulFixed = contract.fromArtifact('IntegerOverflowMulFixed');

const MAX_UINT8 = 255;

async function getBal(account) {
  return new BN(await web3.eth.getBalance(account));
}

const [ funder ] = accounts ;

describe("101-Integer-Overflow-and-Underflow", function(){
  let gasPrice;
  
  before(async function(){
    gasPrice = new BN(await web3.eth.getGasPrice());
  })
  
  describe("TokenSaleChallenge", function(){
    it(
      "overflows buy() require statement",
      async function(){
        let tokenSaleChallenge = await TokenSaleChallenge.new();
        await expectRevert(
          tokenSaleChallenge.buy(256, {from: funder, value: 256}),
          "buy: Require Statement"
        );
      }
    );
    
    it(
      "overflows sell() transfer statement",
      async function(){
        let tokenSaleChallenge = await TokenSaleChallenge.new();
        await tokenSaleChallenge.send(new BN("128"), {from: funder});
        
        await tokenSaleChallenge.buy(128, {from: funder, value: 128});
        let initialSenderBalance = await getBal(funder);
        let initialContractBalance = await getBal(tokenSaleChallenge.address);
        await tokenSaleChallenge.changePrice(2);
        
        let receipt = await tokenSaleChallenge.sell(128, {from: funder});
        
        let finalSenderBalance = await getBal(funder);
        let finalContractBalance = await getBal(tokenSaleChallenge.address);
        
        let gasUsed = gasPrice.mul(new BN(receipt.receipt.gasUsed));

        expect(finalSenderBalance).to.be.eql(initialSenderBalance.sub(gasUsed));
        expect(finalContractBalance).to.be.eql(initialContractBalance);
      }
    );
  });

  describe("TokenSaleChallengeFixed", function(){
    it(
      "reverts on overflow buy() require statement",
      async function(){
        let tokenSaleChallenge = await TokenSaleChallengeFixed.new();
        await expectRevert.unspecified(
          tokenSaleChallenge.buy(256, {from: funder, value: 256}),
        );
      }
    );
    
    it(
      "reverts on overflow sell() transfer statement",
      async function(){
        let tokenSaleChallenge = await TokenSaleChallengeFixed.new();
        await tokenSaleChallenge.send(new BN("128"), {from: funder});
        
        await tokenSaleChallenge.buy(128, {from: funder, value: 128});
        await tokenSaleChallenge.changePrice(2);
        
        await expectRevert(
          tokenSaleChallenge.sell(128, {from: funder}),
          "SafeMath: multiplication overflow"
        );
      }
    );

  });
  
  describe("IntegerOverflowMappingSym1", function(){
    it(
      "overflows on subtraction",
      async function(){
        let integerOverflowMappingSym1 = await IntegerOverflowMappingSym1.new();
        await integerOverflowMappingSym1.init(0, 1, {from: funder});
        let mappedValue = await integerOverflowMappingSym1.map(0);
        expect(mappedValue).to.be.bignumber.equal(MAX_UINT256);
      }
    );
  });
  
  describe("IntegerOverflowMappingSym1Fixed", function(){
    it(
      "reverts on subtraction",
      async function(){
        let integerOverflowMappingSym1 = await IntegerOverflowMappingSym1Fixed.new();
        await expectRevert(
          integerOverflowMappingSym1.init(0, 1, {from: funder}),
          "SafeMath: subtraction overflow"
        );
      }
    );
  });
  
  describe("IntegerOverflowMinimal", function(){
    it(
      "overflows on subtraction",
      async function(){
        let integerOverflowMinimal = await IntegerOverflowMinimal.new();
        await integerOverflowMinimal.run(2, {from: funder});
        let count = await integerOverflowMinimal.count.call();
        expect(count).to.be.bignumber.equal(MAX_UINT256);
      }
    );
  });
  
  describe("IntegerOverflowMinimalFixed", function(){
    it(
      "reverts on subtraction",
      async function(){
        let integerOverflowMinimalFixed = await IntegerOverflowMinimalFixed.new();
        await expectRevert(
          integerOverflowMinimalFixed.run(2, {from: funder}),
          "SafeMath: subtraction overflow"
        );
      }
    );
  });
  
  describe("IntegerOverflowMul", function(){
    it(
      "overflows on multiplication",
      async function(){
        let integerOverflowMul = await IntegerOverflowMul.new();
        await integerOverflowMul.run(2, {from: funder});
        let count = await integerOverflowMul.count.call();
        expect(count).to.be.bignumber.equal(new BN("0"));
      }
    );
  });
  
  describe("IntegerOverflowMulFixed", function(){
    it(
      "reverts on multiplication",
      async function(){
        let integerOverflowMulFixed = await IntegerOverflowMulFixed.new();
        await expectRevert(
          integerOverflowMulFixed.run(2, {from: funder}),
          "SafeMath: multiplication overflow"
        );
      }
    );
  });
  
});
