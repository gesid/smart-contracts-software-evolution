pragma solidity ^0.4.11;
import ;
import ;
import ;
import ;


contract ethertoken is iethertoken, owned, erc20token, tokenholder {
    
    event issuance(uint256 _amount);
    
    event destruction(uint256 _amount);

    
    function ethertoken()
        erc20token(, , 18) {
    }

    
    function deposit()
        public
        payable
    {
        balanceof[msg.sender] = safeadd(balanceof[msg.sender], msg.value); 
        totalsupply = safeadd(totalsupply, msg.value); 

        issuance(msg.value);
        transfer(this, msg.sender, msg.value);
    }

    
    function withdraw(uint256 _amount) public {
        balanceof[msg.sender] = safesub(balanceof[msg.sender], _amount); 
        totalsupply = safesub(totalsupply, _amount); 
        assert(msg.sender.send(_amount)); 

        transfer(msg.sender, this, _amount);
        destruction(_amount);
    }

    

    
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(_to != address(this));
        assert(super.transfer(_to, _value));
        return true;
    }

    
    function transferfrom(address _from, address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(_to != address(this));
        assert(super.transferfrom(_from, _to, _value));
        return true;
    }

    
    function() public payable {
        deposit();
    }
}
