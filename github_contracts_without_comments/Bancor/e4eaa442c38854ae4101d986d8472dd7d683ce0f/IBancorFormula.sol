pragma solidity ^0.4.11;


contract ibancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _connectorbalance, uint32 _connectorweight, uint256 _depositamount) public constant returns (uint256);
    function calculatesalereturn(uint256 _supply, uint256 _connectorbalance, uint32 _connectorweight, uint256 _sellamount) public constant returns (uint256);
}
