// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract FundMe {
    mapping(address=>uint) public fundersToAmount;
    uint256 min_value=1*10**18;
    AggregatorV3Interface internal dataFeed;
    
    constructor() {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    //external 外部调用
    // payable 收款 eth
    function fund() external payable {
        // 如果条件不满足则回退交易
        require(coverEthToUsd(msg.value) >=min_value,"send more eth");
        fundersToAmount[msg.sender]=msg.value;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
    function coverEthToUsd(uint256 ethAmount ) internal view returns (uint256){
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethPrice * ethAmount/(10**8);
    }
}