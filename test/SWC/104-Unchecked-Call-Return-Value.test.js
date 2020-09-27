const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { expectRevert } = require('@openzeppelin/test-helpers');

const { expect } = require('chai');

const ReturnValue = contract.fromArtifact('ReturnValue');
const ReturnValueAttacker = contract.fromArtifact('ReturnValueAttacker');

describe("104-Unchecked-Call-Return-Value", function(){
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
});
