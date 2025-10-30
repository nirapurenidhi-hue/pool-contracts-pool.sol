// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Group Investment Smart Pools
 * @dev This contract allows multiple investors to pool funds together for a shared investment.
 *      Each investor can deposit, view pool balance, and withdraw proportionally.
 */
contract Project {
    address public manager;
    uint256 public totalPoolBalance;

    struct Investor {
        uint256 amountInvested;
        bool exists;
    }

    mapping(address => Investor) public investors;
    address[] public investorList;

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this");
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    /**
     * @dev Allows an investor to contribute ETH to the pool.
     */
    function invest() external payable {
        require(msg.value > 0, "Investment must be greater than 0");

        if (!investors[msg.sender].exists) {
            investors[msg.sender] = Investor(msg.value, true);
            investorList.push(msg.sender);
        } else {
            investors[msg.sender].amountInvested += msg.value;
        }

        totalPoolBalance += msg.value;
    }

    /**
     * @dev Returns the total pool balance.
     */
    function getPoolBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Allows the manager to distribute funds back to investors proportionally.
     */
    function distributeFunds() external onlyManager {
        require(address(this).balance > 0, "No funds to distribute");

        for (uint i = 0; i < investorList.length; i++) {
            address investorAddr = investorList[i];
            uint256 share = (investors[investorAddr].amountInvested * address(this).balance) / totalPoolBalance;
            payable(investorAddr).transfer(share);
            investors[investorAddr].amountInvested = 0;
        }

        totalPoolBalance = 0;
        delete investorList;
    }
}

