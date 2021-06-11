pragma solidity ^0.4.1;




contract erc20tokeninterface {
    
    function totalsupply() constant returns (uint256 supply);

    
    
    function balanceof(address _owner) constant returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success);

    
    
    
    
    
    function transferfrom(address _from, address _to, uint256 _value) returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract standardtoken is erc20tokeninterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    function transfer(address _to, uint256 _value) returns (bool success) {
        

        
        
        
        
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = _value;
            balances[_to] += _value;
            transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferfrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] = _value;
            allowed[_from][msg.sender] = _value;
            transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceof(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}

contract golemnetworktoken is standardtoken {

    

    

    string public standard = ;

    uint256 supply = 0;
    string public constant name = ;
    uint8 public constant decimals = 1;
    string public constant symbol = ;

    uint256 constant fundingmax = 847457627118644067796611;
    uint256 constant fundingmin = 84745762711864406779661;
    uint256 fundingstart;
    uint256 fundingend;
    address founder;

    function golemnetworktoken(address _founder, uint256 _fundingstart,
                               uint256 _fundingend) {
        founder = _founder;
        fundingstart = _fundingstart;
        fundingend = _fundingend;
    }

    function changefounder(address _newfounder) external {
        
        if (msg.sender == founder)
            founder = _newfounder;
    }

    function totalsupply() constant returns (uint256 supply) {
        return supply;
    }

    function generatetokens() external {
        

        
        if (block.number < fundingstart) throw;
        if (block.number > fundingend) throw;

        var numtokens = msg.value;
        if (numtokens == 0) throw;

        
        
        
        
        
        uint256 tokensleft = fundingmax  supply;
        if (numtokens > tokensleft) throw;

        
        balances[msg.sender] += numtokens;
        supply += numtokens;
    }

    
    function finalizefunding() external {
        
        
        if (founder == 0) throw;
        if (msg.sender != founder) throw;
        if (block.number <= fundingend) throw;

        
        
        if (supply < fundingmin) throw;

        
        if (!founder.send(msg.value)) throw;

        
        
        var additionaltokens = supply * 118 / 100;
        balances[founder] += additionaltokens;
        supply += additionaltokens;

        
        
        
        delete founder;
        delete fundingstart;
        delete fundingend;
    }

    
    
    
    function sendfundsback() external {
        
        
        

        
        if (block.number <= fundingend) throw;

        
        if (supply >= fundingmin) throw;

        uint256 value = balances[msg.sender];
        balances[msg.sender] = 0;
        if (!msg.sender.send(value)) throw;
    }

    
    function approveandcall(address _spender, uint256 _value, bytes _extradata) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3())), msg.sender, _value, this, _extradata)) { throw; }
        return true;
    }
}
