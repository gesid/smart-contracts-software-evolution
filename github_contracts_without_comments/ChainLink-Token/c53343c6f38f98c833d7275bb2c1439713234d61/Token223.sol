pragma solidity ^0.4.11;


import ;
import ;


contract token223 is standardtoken, erc223basictoken {
    string public constant name = ;
    string public constant symbol = ;
    uint8 public constant decimals = 18;
    uint256 public totalsupply;

    function token223(uint _initialbalance)
    {
        balances[msg.sender] = _initialbalance;
        totalsupply = _initialbalance;
    }
}
