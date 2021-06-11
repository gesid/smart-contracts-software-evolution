pragma solidity ^0.5.16;

import ;
import ;




contract mocksynth is externstatetoken {
    isystemstatus private systemstatus;
    bytes32 public currencykey;

    constructor(
        address payable _proxy,
        tokenstate _tokenstate,
        string memory _name,
        string memory _symbol,
        uint _totalsupply,
        address _owner,
        bytes32 _currencykey
    ) public externstatetoken(_proxy, _tokenstate, _name, _symbol, _totalsupply, 18, _owner) {
        currencykey = _currencykey;
    }

    
    function setsystemstatus(isystemstatus _status) external {
        systemstatus = _status;
    }

    
    function settotalsupply(uint256 _totalsupply) external {
        totalsupply = _totalsupply;
    }

    function transfer(address to, uint value) external optionalproxy returns (bool) {
        systemstatus.requiresynthactive(currencykey);

        return _transferbyproxy(messagesender, to, value);
    }

    function transferfrom(
        address from,
        address to,
        uint value
    ) external optionalproxy returns (bool) {
        systemstatus.requiresynthactive(currencykey);

        return _transferfrombyproxy(messagesender, from, to, value);
    }

    event issued(address indexed account, uint value);

    event burned(address indexed account, uint value);

    
    function issue(address account, uint amount) external {
        tokenstate.setbalanceof(account, tokenstate.balanceof(account).add(amount));
        totalsupply = totalsupply.add(amount);
        emit issued(account, amount);
    }

    function burn(address account, uint amount) external {
        tokenstate.setbalanceof(account, tokenstate.balanceof(account).sub(amount));
        totalsupply = totalsupply.sub(amount);
        emit burned(account, amount);
    }
}
