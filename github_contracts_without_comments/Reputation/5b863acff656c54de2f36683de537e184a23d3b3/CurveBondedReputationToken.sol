pragma solidity ^0.4.24;

import ;
import ;
import ;
import ;


contract curvebondedreputationtoken is reputationtoken, standardtoken {
  using safemath for uint256;

  erc20basic public backingtoken;
  
  function getreputation() public returns (uint256) {
    return totalsupply_;
  }

  function buy(uint256 _amount) public returns (bool);

  function sell(uint256 _amount) public returns (bool);

}
