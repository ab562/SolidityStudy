// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract FundMe {
    mapping(address=>uint) public fundersToAmount;
    uint256 min_value=1*10**18;
    //external 外部调用
    // payable 收款 eth
    function fund() external payable {
        // 如果条件不满足则回退交易
        require(msg.value>=min_value,"send more eth");
        fundersToAmount[msg.sender]=msg.value;
    }
     
}