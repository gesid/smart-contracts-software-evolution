pragma solidity 0.4.26;
import ;
import ;
import ;
import ;
import ;


contract ethertoken is iethertoken, owned, erc20token, tokenholder {
    using safemath for uint256;

    
    event issuance(uint256 _amount);

    
    event destruction(uint256 _amount);

    
    constructor()
        public
        erc20token(, , 18) {
    }

    
    function deposit() public payable {
        balanceof[msg.sender] = balanceof[msg.sender].add(msg.value); 
        totalsupply = totalsupply.add(msg.value); 

        emit issuance(msg.value);
        emit transfer(this, msg.sender, msg.value);
    }

    
    function withdraw(uint256 _amount) public {
        withdrawto(msg.sender, _amount);
    }

    
    function withdrawto(address _to, uint256 _amount)
        public
        notthis(_to)
    {
        balanceof[msg.sender] = balanceof[msg.sender].sub(_amount); 
        totalsupply = totalsupply.sub(_amount); 
        _to.transfer(_amount); 

        emit transfer(msg.sender, this, _amount);
        emit destruction(_amount);
    }

    

    
    function transfer(address _to, uint256 _value)
        public
        notthis(_to)
        returns (bool success)
    {
        assert(super.transfer(_to, _value));
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value)
        public
        notthis(_to)
        returns (bool success)
    {
        assert(super.transferfrom(_from, _to, _value));
        return true;
    }

    
    function() public payable {
        deposit();
    }
}
