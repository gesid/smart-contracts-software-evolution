pragma solidity ^0.4.1;

contract migrationagent {
    function migratefrom(address _from, uint256 _value);
}

contract golemnetworktoken {
    string public constant name = ;
    string public constant symbol = ;
    uint8 public constant decimals = 18;  

    
    uint256 constant percenttokensforcrowdfundingagent = 12;
    uint256 constant percenttokensfordevelopers = 6;
    uint256 public constant tokencreationrate = 1000;

    
    uint256 constant tokencreationcap = 847457627118644067796611 * tokencreationrate;

    uint256 fundingstartblock;
    uint256 fundingendblock;

    address public golemfactory;

    
    
    
    
    
    address public constant dev0 = 0xde00;
    uint256 public constant dev0percent = 10;

    address public constant dev1 = 0xde01;
    uint256 public constant dev1percent = 10;

    address public constant dev2 = 0xde02;
    uint256 public constant dev2percent = 15;

    address public constant dev3 = 0xde03;
    uint256 public constant dev3percent = 20;

    address public constant dev4 = 0xde04;
    uint256 public constant dev4percent = 20;

    address public constant dev5 = 0xde05;
    

    uint256 totaltokens;
    mapping (address => uint256) balances;

    address public migrationagent;
    uint256 public totalmigrated;

    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event migrate(address indexed _from, address indexed _to, uint256 _value);

    function golemnetworktoken(address _golemfactory, uint256 _fundingstartblock,
                               uint256 _fundingendblock) {
        golemfactory = _golemfactory;
        fundingstartblock = _fundingstartblock;
        fundingendblock = _fundingendblock;
    }

    

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (transferenabled() && balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = _value;
            balances[_to] += _value;
            transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function totalsupply() constant returns (uint256) {
        return totaltokens;
    }

    function balanceof(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    

    function migrationenabled() constant returns (bool) {
        return migrationagent != 0;
    }

    function migrate(uint256 _value) {
        if (!migrationenabled()) throw;
        if (!transferenabled()) throw;
        if (balances[msg.sender] < _value) throw;
        if (_value == 0) throw;

        balances[msg.sender] = _value;
        totaltokens = _value;
        totalmigrated += _value;
        migrationagent(migrationagent).migratefrom(msg.sender, _value);
        migrate(msg.sender, migrationagent, _value);
    }

    function setmigrationagent(address _agent) external {
        if (msg.sender != golemfactory) throw;
        if (!fundingfinalized()) throw; 
        if (migrationenabled()) throw;  

        migrationagent = _agent;
    }

    

    
    
    function fundinghasended() constant returns (bool) {
        if (block.number > fundingendblock)
            return true;

        
        
        return totaltokens >= tokencreationcap;
    }

    function fundingfinalized() constant returns (bool) {
        return fundingendblock == 0;
    }

    
    function fundingongoing() constant returns (bool) {
        if (fundinghasended())
            return false;
        return block.number >= fundingstartblock;
    }

    function transferenabled() constant returns (bool) {
        return fundinghasended();
    }

    
    
    function numberoftokensleft() constant returns (uint256) {
        if (fundinghasended())
            return 0;
        return tokencreationcap  totaltokens;
    }

    function changegolemfactory(address _golemfactory) external {
        if (!fundingfinalized()) throw; 

        
        if (msg.sender == golemfactory)
            golemfactory = _golemfactory;
    }

    
    function() payable external {
        
        if (!fundingongoing()) throw;

        var numtokens = msg.value * tokencreationrate;
        if (numtokens == 0) throw;

        
        
        
        
        
        if (numtokens > numberoftokensleft()) throw;

        
        balances[msg.sender] += numtokens;
        totaltokens += numtokens;
        
        transfer(0, msg.sender, numtokens);
    }

    
    
    
    
    
    
    
    function finalizefunding() external {
        if (fundingfinalized()) throw;
        if (!fundinghasended()) throw;

        
        if (!golemfactory.send(this.balance)) throw;

        
        var numadditionaltokens = totaltokens * (percenttokensforcrowdfundingagent + percenttokensfordevelopers) / (100  percenttokensforcrowdfundingagent  percenttokensfordevelopers);
        var numtokensforgolemagent = numadditionaltokens * percenttokensforcrowdfundingagent / (percenttokensforcrowdfundingagent + percenttokensfordevelopers);

        balances[golemfactory] += numtokensforgolemagent;

        
        var numtokensfordevelpers  = numadditionaltokens  numtokensforgolemagent;

        var dev0tokens = dev0percent * numtokensfordevelpers / 100;
        var dev1tokens = dev1percent * numtokensfordevelpers / 100;
        var dev2tokens = dev2percent * numtokensfordevelpers / 100;
        var dev3tokens = dev3percent * numtokensfordevelpers / 100;
        var dev4tokens = dev4percent * numtokensfordevelpers / 100;
        var dev5tokens = numtokensfordevelpers  dev0tokens  dev1tokens  dev2tokens  dev3tokens  dev4tokens;

        balances[dev0] += dev0tokens;
        balances[dev1] += dev1tokens;
        balances[dev2] += dev2tokens;
        balances[dev3] += dev3tokens;
        balances[dev4] += dev4tokens;
        balances[dev5] += dev5tokens;

        
        totaltokens += numadditionaltokens;

        
        
        
        
        fundingstartblock = 0;
        fundingendblock = 0;
    }
}
