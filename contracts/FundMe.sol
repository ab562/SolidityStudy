// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**

0xf09b5FdDb91F83692565F024f12D5E42aA3F0b8e
 * @title Storage
 * @dev Store & retrieve value in a variable 1
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract FundMe {
    mapping(address=>uint) public fundersToAmount;
    uint256 min_value=1*10**18;
    uint256 constant TARGET =10*10**18;
    AggregatorV3Interface internal dataFeed;
    uint256 deploymentTimestamp;
    // 锁定时长
    uint256 lockTime;
    address public owner;
    
    constructor(uint256  _lockTime) {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        owner=msg.sender;
        deploymentTimestamp=block.timestamp;
        lockTime=_lockTime;
    }

    //external 外部调用
    // payable 收款 eth
    function fund() external payable {
        // 如果条件不满足则回退交易
        require(coverEthToUsd(msg.value) >=min_value,"send more eth");
         require(block.timestamp < deploymentTimestamp+lockTime,"window is closed");
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
    function transferOwnership(address newOwner) public onluOwner {
    
        owner=newOwner;
    }

    function getFund() external windowClose onluOwner {
       
        // 当前合约地址
       require( coverEthToUsd(address(this).balance) >=TARGET,"Target is not reached");
      
       payable(msg.sender).transfer(address(this).balance);
    }

    function refund() external windowClose {
        require( coverEthToUsd(address(this).balance) < TARGET,"Target is  reached");
        uint256 amount= fundersToAmount[msg.sender];
        require( amount==0,"There is no fund for you");
        payable(msg.sender).transfer(amount);
        fundersToAmount[msg.sender]=0;
    }
    modifier windowClose (){
         require(block.timestamp >deploymentTimestamp+lockTime,"window is no closed");
         _;
    }

       modifier onluOwner (){
         require(msg.sender==owner,"this function con only be called by owner");
         _;
    }
}