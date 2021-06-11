pragma solidity 0.4.26;
import ;
import ;
import ;
import ;


contract smarttoken is ismarttoken, owned, erc20token, tokenholder {
    using safemath for uint256;


    string public version = ;

    bool public transfersenabled = true;    

    
    event newsmarttoken(address _token);

    
    event issuance(uint256 _amount);

    
    event destruction(uint256 _amount);

    
    constructor(string _name, string _symbol, uint8 _decimals)
        public
        erc20token(_name, _symbol, _decimals)
    {
        emit newsmarttoken(address(this));
    }

    
    modifier transfersallowed {
        assert(transfersenabled);
        _;
    }

    
    function disabletransfers(bool _disable) public owneronly {
        transfersenabled = !_disable;
    }

    
    function issue(address _to, uint256 _amount)
        public
        owneronly
        validaddress(_to)
        notthis(_to)
    {
        totalsupply = totalsupply.add(_amount);
        balanceof[_to] = balanceof[_to].add(_amount);

        emit issuance(_amount);
        emit transfer(this, _to, _amount);
    }

    
    function destroy(address _from, uint256 _amount) public {
        require(msg.sender == _from || msg.sender == owner); 

        balanceof[_from] = balanceof[_from].sub(_amount);
        totalsupply = totalsupply.sub(_amount);

        emit transfer(_from, this, _amount);
        emit destruction(_amount);
    }

    

    
    function transfer(address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transfer(_to, _value));
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value) public transfersallowed returns (bool success) {
        assert(super.transferfrom(_from, _to, _value));
        return true;
    }
}
