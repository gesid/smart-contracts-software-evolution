pragma solidity ^0.4.11;
import ;
import ;
import ;


contract bancorpricefloor is tokenholder, safemath {
    uint256 public constant token_price_n = 1;      
    uint256 public constant token_price_d = 100;    

    string public version = ;
    ismarttoken public token; 

    
    function bancorpricefloor(ismarttoken _token)
        validaddress(_token)
    {
        token = _token;
    }

    
    function sell() public returns (uint256 amount) {
        uint256 allowance = token.allowance(msg.sender, this); 
        assert(token.transferfrom(msg.sender, this, allowance)); 
        uint256 ethervalue = safemul(allowance, token_price_n) / token_price_d; 
        assert(msg.sender.send(ethervalue)); 
        return ethervalue;
    }

    
    function withdraw(uint256 _amount) public owneronly {
        assert(msg.sender.send(_amount)); 
    }

    
    function() public payable {
    }
}
