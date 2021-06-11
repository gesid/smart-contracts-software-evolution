pragma solidity ^0.4.11;


import ;
import ;



contract basictoken is erc20basic {
  using safemath for uint256;
  address public contractaddress;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_to != contractaddress);
    require(_value <= balances[msg.sender]);

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceof(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}