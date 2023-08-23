// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LockedFundsSavings {
    address public owner;
    uint256 public initialLockDays; //amount of days for initial lock
    uint256 public unlockInterval; //amount of days to unlock after initial lock date unlock
    uint256 public lastUnlockTimestamp; //keeps the timestampof the last unlock date
    uint256 public lockedAmount; //amount to get locked

    constructor(uint256 _initialLockDays, uint256 _unlockInterval) {
        owner = msg.sender;
        initialLockDays = _initialLockDays;
        unlockInterval = _unlockInterval;
        lastUnlockTimestamp = block.timestamp + _initialLockDays * 1 days; //the lastUnlockTimestamp here is determined by the initialLockDays
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function deposit() external payable {
        lockedAmount += msg.value;
    }

    function withdraw(uint256 _amount) external onlyOwner {
        require(block.timestamp >= lastUnlockTimestamp, "Funds can't be withdrawn yet"); //checks if the unlock date has reached

        uint256 elapsedDays = (block.timestamp - lastUnlockTimestamp) / 1 days; //to check how many days has passed since last unlock date
        uint256 unlockCount = elapsedDays / unlockInterval; //to check how many times unlock date has happened
        uint256 unlockAmount = (unlockCount + 1) * _amount; //amount to unlock based on given input

        require(unlockAmount <= lockedAmount, "Insufficient funds");
        
        lockedAmount -= unlockAmount;
        lastUnlockTimestamp = lastUnlockTimestamp + (unlockCount + 1) * unlockInterval * 1 days; //calculates new unlock time stamp
        payable(owner).transfer(unlockAmount); //sends the unlock amount to the owner
    }

    function getLockedAmount() external view returns (uint256) {
        return lockedAmount;
    }

    function getLastUnlockTimestamp() external view returns (uint256) {
        return lastUnlockTimestamp;
    }

    function getNextUnlockTimestamp() external view returns (uint256) {
        return lastUnlockTimestamp + unlockInterval * 1 days;
    }
}
