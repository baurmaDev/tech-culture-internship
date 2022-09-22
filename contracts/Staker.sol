// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract Staker {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public depositTimestamps;
    mapping(address => bool) public userStaked;
    mapping(address => bool) public completed;

    uint256 public constant rewardRatePerSecond = 0.00001667 ether;
    uint256 public currentBlock = 0;

    event Withdraw(address indexed sender, uint256 amount);
    event Stake(address indexed sender, uint256 amount);
    event Received(address, uint256);
    event UnStake(address indexed sender, uint256 amount);

    // (msg.value * reward) + balance
    modifier withdrawAvailable() {
        require(
            block.timestamp - depositTimestamps[msg.sender] >= 60,
            "Withdraw is not available yet"
        );
        _;
    }

    modifier notStaked() {
        require(
            userStaked[msg.sender] == false,
            "The user has been already staked"
        );
        _;
    }
    modifier staked() {
        require(userStaked[msg.sender] == true, "The user has not staked yet");
        _;
    }

    function stake() public payable notStaked {
        balances[msg.sender] = balances[msg.sender] + msg.value;
        depositTimestamps[msg.sender] = block.timestamp;
        userStaked[msg.sender] = true;
        emit Stake(msg.sender, msg.value);
        console.log("Staked", balances[msg.sender]);
    }

    function unStake() public staked {
        require(balances[msg.sender] > 0, "You have no balance to unstake!");
        uint256 individualBalance = balances[msg.sender];
        balances[msg.sender] = 0;
        userStaked[msg.sender] = false;
        payable(msg.sender).transfer(individualBalance);
        console.log("Unstaked", balances[msg.sender]);
        emit UnStake(msg.sender, individualBalance);
    }

    function withdraw() public payable staked withdrawAvailable {
        require(balances[msg.sender] > 0, "You have no balance to withdraw!");
        uint256 individualBalance = balances[msg.sender];
        uint256 indBalanceRewards = individualBalance +
            ((block.timestamp - depositTimestamps[msg.sender]) *
                rewardRatePerSecond);
        payable(msg.sender).transfer(indBalanceRewards - individualBalance);
        emit Withdraw(msg.sender, indBalanceRewards - individualBalance);
    }

    function balance() public view returns (uint256) {
        require(balances[msg.sender] > 0, "You have no balance");
        uint256 indBalanceRewards = balances[msg.sender] +
            ((block.timestamp - depositTimestamps[msg.sender]) *
                rewardRatePerSecond);
        return indBalanceRewards;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
