pragma solidity ^0.4.10;
import ;


contract ethertoken is standardtoken {
    function ethertoken()
        standardtoken(, ) {
    }

    
    function deposit() public payable returns (bool success) {
        assert(balanceof[msg.sender] + msg.value >= balanceof[msg.sender]); 
        balanceof[msg.sender] += msg.value; 
        totalsupply += msg.value; 
        return true;
    }

    
    function withdraw(uint256 _amount) public returns (bool success) {
        require(_amount <= balanceof[msg.sender]); 
        balanceof[msg.sender] = _amount; 
        totalsupply = _amount; 
        assert(msg.sender.send(_amount)); 
        return true;
    }

    
    function() public payable {
        assert(balanceof[msg.sender] + msg.value >= balanceof[msg.sender]); 
        balanceof[msg.sender] += msg.value; 
        totalsupply += msg.value; 
    }
}
