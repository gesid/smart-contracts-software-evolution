pragma solidity ^0.4.8;


import ;


contract standard223tokenreceivermock is standard223receiver {
    address public tokensender;
    uint public sentvalue;
    bytes public tokendata;
    bool public calledfallback = false;

    function tokenfallback(address _sender, uint _value, bytes _data)
    public returns (bool success) {
      calledfallback = true;

      tokensender = _sender;
      sentvalue = _value;
      tokendata = _data;
      return true;
    }

}
