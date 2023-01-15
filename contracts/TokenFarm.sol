// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./JamToken.sol";
import "./StellartToken.sol";

contract TokenFarm {

    // Initial statements
    string public name = "Stellart Token Farm";
    address public owner;
    JamToken public jamToken;
    StellartToken public stellartToken;

    // Data structures
    address [] public stakers;
    mapping(address => uint) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    // Constructor
    constructor(StellartToken _stellartToken, JamToken _jamToken) {
        stellartToken = _stellartToken;
        jamToken = _jamToken;
        owner = msg.sender;
    }

    // Token staking
    function stakeTokens(uint _amount) public {
        // A quantity greater than 0 is required
        require(_amount > 0, "The amount cannot be less than 0");
        // Transfer Jam tokens to main smart contract
        jamToken.transferFrom(msg.sender, address(this), _amount);
        // Update staking balance
        stakingBalance[msg.sender] += _amount;
        // Save the user
        if(!hasStaked[msg.sender]){
            stakers.push(msg.sender);
        }
        // Update staking status
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    // Token unstaking
    function unstakeTokens(uint _amount) public {
        // User staking balance
        uint balance = stakingBalance[msg.sender];
        // A quantity greater than 0 is required
        require(balance >= _amount, "The amount to withdraw is less than the amount staked");
        // Transfer of tokens to the user
        jamToken.transfer(msg.sender, _amount);
        // Update staking status
        stakingBalance[msg.sender] -= _amount;
        if(stakingBalance[msg.sender] == 0){
            isStaking[msg.sender] = false;
        }
    }

    // Withdraw all staked tokens
    function withdrawAll() public {
        // User staking balance
        uint balance = stakingBalance[msg.sender];
        // A quantity greater than 0 is required
        require(balance > 0, "Staking balance is 0");
        // Transfer of tokens to the user
        jamToken.transfer(msg.sender, balance);
        // Update staking status
        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;
    }

    // Issuance of Reward Tokens
    function issueTokens() public {
        // Only executable by the owner
        require(msg.sender == owner, "You are not the owner");
        // Issue tokens to all current stakers
        for (uint i=0; i < stakers.length; i++){
            address recipient = stakers[i];
            uint balance = stakingBalance[recipient];
            if(balance > 0){
                stellartToken.transfer(recipient, balance);
            }
        }
    }
}