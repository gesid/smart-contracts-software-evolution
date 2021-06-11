pragma solidity ^0.4.10;


contract erc20tokeninterface {
    
    function name() public constant returns (string name) {}
    function symbol() public constant returns (string symbol) {}
    function decimals() public constant returns (uint8 decimals) {}
    function totalsupply() public constant returns (uint256 totalsupply) {}
    function balanceof(address _owner) public constant returns (uint256 balance) {}
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {}

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferfrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}
