101-Integer-Overflow-and-Underflow
==================================

Adapted From
`SWC 101 <https://swcregistry.io/docs/SWC-101>`_.


Description
-----------

An overflow/underflow happens when an arithmetic operation reaches the
maximum or minimum size of a type. Be aware that *uint* in Solidity is
an alias for *uint256*, a 256 bit unsigned integer type. Solidity
also has a variety of uints: *uint8*, *uint16*, ...

A number stored in a uint8 represents an 8 bit unsigned integer with
range 0 to 2\ :sup:`8`\ - 1. Integer overflow occurs when an arithmetic
operation attempts to create a numeric value that is outside of the
range that can be represented with a given number of bits, either higher
than the maximum representable integer or lower than the minimum representable
integer.

Remediation
-----------

You should use the SafeMath library for all instances of arithmetic 
operations within your contract. This entails placing *using SafeMath 
for uint256;* at the top of your contract and making the 
following replacements.

+-------------------------+
| Operation | Replacement |
+===========+=============+
|   x + y   |   x.add(y)  |
+-----------+-------------+
|   x - y   |   x.sub(y)  |
+-----------+-------------+
|   x * y   |   x.mul(y)  |
+-----------+-------------+
|   x / y   |   x.div(y)  |
+-----------+-------------+
|   x % y   |   x.mod(y)  |
+-----------+-------------+

Examples
--------

TokenSaleChallenge
^^^^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 20,24,31,60,63,70

    contract TokenSaleChallenge {
        mapping(address => uint8) public balanceOf;
        uint8 PRICE_PER_TOKEN = 1;
    
        function TokenSaleChallengeDeposit() public payable {
            require(msg.value == 1);
        }
        
        function changePrice(uint8 price) public {
            PRICE_PER_TOKEN = price;
        }
    
        function isComplete() public view returns (bool) {
            return address(this).balance < 1;
        }
        
        function buy(uint8 numTokens) public payable {
            require(
                msg.value == 
                numTokens * PRICE_PER_TOKEN, 
                    "buy: Require Statement"
            );
    
            balanceOf[msg.sender] += numTokens;
        }
        
        function sell(uint8 numTokens) public {
            require(balanceOf[msg.sender] >= numTokens);
    
            balanceOf[msg.sender] -= numTokens;
            msg.sender.transfer(numTokens * PRICE_PER_TOKEN);
        }
        
        receive() external payable {
            
        }
    }
    
    contract TokenSaleChallengeFixed {
        using SafeMath8 for uint8;
        mapping(address => uint8) public balanceOf;
        uint8 PRICE_PER_TOKEN = 1;
    
        function TokenSaleChallengeDeposit() public payable {
            require(msg.value == 1);
        }
        
        function changePrice(uint8 price) public {
            PRICE_PER_TOKEN = price;
        }    
    
        function isComplete() public view returns (bool) {
            return address(this).balance < 1;
        }
        
        function buy(uint8 numTokens) public payable {
            require(msg.value == numTokens.mul(PRICE_PER_TOKEN));
            require(
                msg.value == 
                numTokens.mul(PRICE_PER_TOKEN), 
                    "buy: Require Statement"
            );
            balanceOf[msg.sender] = balanceOf[msg.sender].add(numTokens);
        }
    
        function sell(uint8 numTokens) public {
            require(balanceOf[msg.sender] >= numTokens);
    
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(numTokens);
            msg.sender.transfer(numTokens.mul(PRICE_PER_TOKEN));
        }
        
        receive() external payable {
            
        }
    }


IntegerOverflowMappingSym1
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 5,15

   contract IntegerOverflowMappingSym1 {
       mapping(uint256 => uint256) public map;
       
       function init(uint256 k, uint256 v) public {
           map[k] -= v;
       }
   }
   
   contract IntegerOverflowMappingSym1Fixed {
       using SafeMath for uint256;
       
       mapping(uint256 => uint256) public map;
       
       function init(uint256 k, uint256 v) public {
           map[k] = map[k].sub(v);
       }
   }

IntegerOverflowMinimal
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 6,16

   contract IntegerOverflowMinimal {
       
       uint256 public count = 1;
       
       function run(uint256 input) public {
           count -= input;
       }
   }
   
   contract IntegerOverflowMinimalFixed {
       using SafeMath for uint256;
       
       uint256 public count = 1;
       
       function run(uint256 input) public {
           count = count.sub(input);
       }
   }


IntegerOverflowMul
^^^^^^^^^^^^^^^^^^

.. code-block:: solidity
   :linenos:
   :emphasize-lines: 6,16

   contract IntegerOverflowMul {
   
       uint256 public count = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
       
       function run(uint256 input) public {
           count *= input;
       }
   }
   
   contract IntegerOverflowMulFixed {
       using SafeMath for uint256;
       
       uint256 public count = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
       
       function run(uint256 input) public {
           count = count.mul(input);
       }
   }

Contract Interfaces
-------------------

TokenSaleChallenge
^^^^^^^^^^^^^^^^^^

.. autosolcontract:: TokenSaleChallenge
   :members:
   :undoc-members:

.. autosolcontract:: TokenSaleChallengeFixed
   :members:
   :undoc-members:

IntegerOverflowMappingSym1
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. autosolcontract:: IntegerOverflowMappingSym1
   :members:
   :undoc-members:

.. autosolcontract:: IntegerOverflowMappingSym1Fixed
   :members:
   :undoc-members:

IntegerOverflowMinimal
^^^^^^^^^^^^^^^^^^^^^^

.. autosolcontract:: IntegerOverflowMinimal
   :members:
   :undoc-members:

.. autosolcontract:: IntegerOverflowMinimalFixed
   :members:
   :undoc-members:

IntegerOverflowMul
^^^^^^^^^^^^^^^^^^

.. autosolcontract:: IntegerOverflowMul
   :members:
   :undoc-members:

.. autosolcontract:: IntegerOverflowMulFixed
   :members:
   :undoc-members:

Tests
-----

TokenSaleChallenge
^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

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

TokenSaleChallengeFixed
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

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

IntegerOverflowMappingSym1
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

   it(
      "overflows on subtraction",
      async function(){
         let integerOverflowMappingSym1 = await IntegerOverflowMappingSym1.new();
         await integerOverflowMappingSym1.init(0, 1, {from: funder});
         let mappedValue = await integerOverflowMappingSym1.map(0);
         expect(mappedValue).to.be.bignumber.equal(MAX_UINT256)
      }
   );

IntegerOverflowMappingSym1Fixed
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

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

IntegerOverflowMinimal
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

   it(
      "overflows on subtraction",
      async function(){
         let integerOverflowMinimal = await IntegerOverflowMinimal.new();
         await integerOverflowMinimal.run(2, {from: funder});
         let count = await integerOverflowMinimal.count.call();
         expect(count).to.be.bignumber.equal(MAX_UINT256);
      }
    );

IntegerOverflowMinimalFixed
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

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

IntegerOverflowMul
^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

   it(
      "overflows on multiplication",
      async function(){
         let integerOverflowMul = await IntegerOverflowMul.new();
         await integerOverflowMul.run(2, {from: funder});
         let count = await integerOverflowMul.count.call();
         expect(count).to.be.bignumber.equal(new BN("0"));
      }
   );

IntegerOverflowMulFixed
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: javascript
   :linenos:

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
