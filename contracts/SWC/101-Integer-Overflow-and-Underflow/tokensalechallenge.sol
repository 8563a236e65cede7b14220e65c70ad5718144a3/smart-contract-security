// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

import "../../math/SafeMath.sol";

/**
 * @notice https://capturetheether.com/challenges/math/token-sale/
 * @author Steve Marx
 * @dev Contract that has integer overflow resulting from addition
 * and multiplication.
 *
 * Modified to make showing overflow less expensive in test environment
 */
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
    
    /// @dev The require statement in this function can overflow
    /// due to multiplication and incrementing the sender's balance
    /// can overflow due to addition
    function buy(uint8 numTokens) public payable {
        require(
            msg.value == 
            numTokens * PRICE_PER_TOKEN, 
                "buy: Require Statement"
        );

        balanceOf[msg.sender] += numTokens;
    }

    /// @dev The transfer of tokens can overflow due to 
    /// multiplication
    function sell(uint8 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] -= numTokens;
        msg.sender.transfer(numTokens * PRICE_PER_TOKEN);
    }
    
    /// @dev Receive function to perform funding for tests
    receive() external payable {
        
    }
}

/// @dev The fixed version of the TokenSaleChallenge contract.
/// Uses the SafeMath library for all uint8 operations
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
    
    /// @dev The require statement will now revert on overflow as
    /// will incrementing the sender's balance
    function buy(uint8 numTokens) public payable {
        require(msg.value == numTokens.mul(PRICE_PER_TOKEN));
        require(
            msg.value == 
            numTokens.mul(PRICE_PER_TOKEN), 
                "buy: Require Statement"
        );
        balanceOf[msg.sender] = balanceOf[msg.sender].add(numTokens);
    }

    /// @dev The transfer of tokens will now revert on overflow
    function sell(uint8 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(numTokens);
        msg.sender.transfer(numTokens.mul(PRICE_PER_TOKEN));
    }
    
    /// @dev Receive function to perform funding for tests
    receive() external payable {
        
    }
}