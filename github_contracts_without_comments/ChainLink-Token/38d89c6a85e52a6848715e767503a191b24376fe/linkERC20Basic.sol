pragma solidity ^0.4.11;



contract linkerc20basic {
  uint256 public totalsupply;
  function balanceof(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event transfer(address indexed from, address indexed to, uint256 value);
}
