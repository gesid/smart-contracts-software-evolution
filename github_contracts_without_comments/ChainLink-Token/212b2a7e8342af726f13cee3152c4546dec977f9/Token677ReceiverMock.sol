pragma solidity ^0.6.0;

contract token677receivermock {
  address public tokensender;
  uint public sentvalue;
  bytes public tokendata;
  bool public calledfallback = false;

  function ontokentransfer(address _sender, uint _value, bytes memory _data) public {
    calledfallback = true;

    tokensender = _sender;
    sentvalue = _value;
    tokendata = _data;
  }
}
