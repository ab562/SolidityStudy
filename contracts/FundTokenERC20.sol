// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";


contract FundTokenERC20 is ERC20 {
    FundMe fundMe;
    constructor (address fundMeAddr) ERC20("FundTokenERC20","TTL"){
        fundMe = FundMe(fundMeAddr);
    }

    function mint (uint256 amountToMint) public {
        uint256 a=fundMe.fundersToAmount(msg.sender);
        require(a>=amountToMint,"Yout cannot mint this many tokens");
        require(fundMe.getFundSuccess(),"This fundme is not completed yet");
        _mint(msg.sender,amountToMint);
        fundMe.setFuncerToAmount(msg.sender, a-amountToMint);
    }

    function claim (uint256 amountToClaim) public {
        require(balanceOf(msg.sender)>=amountToClaim,"Yout dont have enough ERC20 tokens");
        _burn(msg.sender, amountToClaim);
    }

}

