// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 1. 创建一个收款函数
// 2. 记录投资人并且查看
// 3. 锁定期内，达到目标值，生产商可以提款。
// 4. 锁定期内，没有达到目标值，投资人可以退款。
// 凭借凭据 拿到商品

contract FundMe {
    mapping(address => uint256) public funderToAmount;

    AggregatorV3Interface internal dataFeed;

    uint256 constant TARGET = 1000 * 10**18;

    address public owner;

    uint256 deploymentTimestamp;
    uint256 lockTime;

    constructor(uint256 _lockTime) {
        // testnet
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        owner = msg.sender;
        deploymentTimestamp = block.timestamp; // 区块
        lockTime = _lockTime;
    }

    uint256 MINIMUM_VALUE = 100 * 10**18; // USD

    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "Send more ETH");
        require(
            block.timestamp < deploymentTimestamp + lockTime,
            "window is closed"
        );
        funderToAmount[msg.sender] = msg.value;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount * (ethPrice / 10**8);
    }

    function transfreOwnership(address newOwner) public onlyOwer {
        owner = newOwner;
    }

    function getFund() external windowClosed onlyOwer {
        require(
            convertEthToUsd(address(this).balance) >= TARGET,
            "Target is not reached"
        );

        // transfer ETH and revert if tx failed
        // payabled(msg.sender).transfer(value)
        // send   if tx failed return bool
        // call transfer ETH with data retuen value of function and bool
        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );

        require(success, "tranxfer tx failed");
    }

    function refund() external windowClosed {
        require(
            convertEthToUsd(address(this).balance) < TARGET,
            "Target is reached"
        );
        require(funderToAmount[msg.sender] != 0, "there is no fund for you");

        bool success;
        (success, ) = payable(msg.sender).call{
            value: funderToAmount[msg.sender]
        }("");

        require(success, "tranxfer tx failed");
        funderToAmount[msg.sender] = 0;
    }

    // modifier
    modifier windowClosed() {
        require(
            block.timestamp >= deploymentTimestamp + lockTime,
            "window is not closed"
        );
        _;
    }

    modifier onlyOwer() {
        require(
            msg.sender == owner,
            "this function can only be called by owner"
        );

        _;
    }
}
