

pragma solidity ^0.4.4;

contract owned {
    
    modifier onlyowner { if (msg.sender != owner) throw; _; }

    address public owner;

    
    function owned() { owner = msg.sender;}

    
    
    function changeowner(address _newowner) onlyowner {
        owner = _newowner;
    }
}

contract tokencreation {
    function proxypayment(address _owner) payable returns(bool);
}

contract minimetoken is owned {

    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = ;       

    struct  checkpoint {
        
        uint fromblock;
        
        uint value;
    }

    minimetoken public parenttoken;
    uint public parentsnapshotblock;
    uint public creationblock;
    mapping (address => checkpoint[]) balances;
    mapping (address => mapping (address => uint256)) allowed;
    checkpoint[] totalsupplyhistory;
    bool public isconstant;

    minimetokenfactory public tokenfactory;





    
    
    
    
    
    
    
    
    
    
    
    function minimetoken(
        address _tokenfactory,
        address _parenttoken,
        uint _parentsnapshotblock,
        string _tokenname,
        uint8 _decimalunits,
        string _tokensymbol,
        bool _isconstant
        ) {
        tokenfactory = minimetokenfactory(_tokenfactory);
        name = _tokenname;                                   
        decimals = _decimalunits;                            
        symbol = _tokensymbol;                              
        parenttoken = minimetoken(_parenttoken);
        parentsnapshotblock = _parentsnapshotblock;
        isconstant = _isconstant;
        creationblock = block.number;
    }






    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        return dotransfer(msg.sender, _to, _value);
    }

    
    
    
    
    
    
    function transferfrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (isconstant) throw;
        if (msg.sender != owner) {
            if (allowed[_from][msg.sender] < _value) return false;
            allowed[_from][msg.sender] = _value;
        }
        return dotransfer(_from, _to, _value);
    }

    function dotransfer(address _from, address _to, uint _value) internal returns(bool) {

           if (_value == 0) {
               return true;
           }

           
           if ((_to == 0) || (_to == address(this))) throw;

           
           var previousbalancefrom = balanceofat(_from, block.number);
           if (previousbalancefrom < _value) {
               return false;
           }

           updatevalueatnow(balances[_from], previousbalancefrom  _value);

           var previousbalanceto = balanceofat(_to, block.number);
           updatevalueatnow(balances[_to], previousbalanceto + _value);

           transfer(_from, _to, _value);

           return true;
    }

    
    
    function balanceof(address _owner) constant returns (uint256 balance) {
        return balanceofat(_owner, block.number);
    }

    
    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        if (isconstant) throw;
        allowed[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }

    
    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    
    function approveandcall(address _spender, uint256 _value, bytes _extradata) returns (bool success) {
        if (isconstant) throw;
        allowed[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3())), msg.sender, _value, this, _extradata)) { throw; }
        return true;
    }

    
    function totalsupply() constant returns (uint) {
        return totalsupplyat(block.number);
    }






    
    
    
    
    function balanceofat(address _owner, uint _blocknumber) constant returns (uint) {

        if (_blocknumber < creationblock) {
            return 0;
        } else if ((balances[_owner].length == 0) || (balances[_owner][0].fromblock > _blocknumber)) {
            if (address(parenttoken) != 0) {
                return parenttoken.balanceofat(_owner, parentsnapshotblock);
            } else {
                return 0;
            }
        } else {
            return getvalueat( balances[_owner], _blocknumber);
        }

    }

    
    
    
    function totalsupplyat(uint _blocknumber) constant returns(uint) {
        if (_blocknumber < creationblock) {
            return 0;
        } else if ((totalsupplyhistory.length == 0) || (totalsupplyhistory[0].fromblock > _blocknumber)) {
            if (address(parenttoken) != 0) {
                return parenttoken.totalsupplyat(parentsnapshotblock);
            } else {
                return 0;
            }
        } else {
            return getvalueat( totalsupplyhistory, _blocknumber);
        }
    }





    
    
    
    
    
    
    
    
    
    
    
    function createchildtoken(string _childtokenname, uint8 _childdecimalunits, string _childtokensymbol, uint _snapshotblock, bool _isconstant) returns(address) {
        if (_snapshotblock > block.number) _snapshotblock = block.number;
        minimetoken childtoken = tokenfactory.createchildtoken(this, _snapshotblock, _childtokenname, _childdecimalunits, _childtokensymbol, _isconstant);
        newchildtoken(address(childtoken), _snapshotblock);
        return address(childtoken);
    }





    
    
    
    
    function generatetokens(address _owner, uint _value) onlyowner returns (bool) {
        if (isconstant) throw;
        uint curtotalsupply = getvalueat(totalsupplyhistory, block.number);
        updatevalueatnow(totalsupplyhistory, curtotalsupply + _value);
        var previousbalanceto = balanceof(_owner);
        updatevalueatnow(balances[_owner], previousbalanceto + _value);
        transfer(0, _owner, _value);
        return true;
    }


    
    
    
    
    function destroytokens(address _owner, uint _value) onlyowner returns (bool) {
        if (isconstant) throw;
        uint curtotalsupply = getvalueat(totalsupplyhistory, block.number);
        if (curtotalsupply < _value) throw;
        updatevalueatnow(totalsupplyhistory, curtotalsupply  _value);
        var previousbalancefrom = balanceof(_owner);
        if (previousbalancefrom < _value) throw;
        updatevalueatnow(balances[_owner], previousbalancefrom  _value);
        transfer(_owner, 0, _value);
        return true;
    }






    
    
    function setconstant(bool _isconstant) onlyowner {
        isconstant = _isconstant;
    }





    function getvalueat(checkpoint[] storage checkpoints, uint _block) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;
        
        if (_block >= checkpoints[checkpoints.length1].fromblock) return checkpoints[checkpoints.length1].value;
        if (_block < checkpoints[0].fromblock) return 0;
        uint min = 0;
        uint max = checkpoints.length1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromblock<=_block) {
                min = mid;
            } else {
                max = mid1;
            }
        }
        return checkpoints[min].value;
    }

    function updatevalueatnow(checkpoint[] storage checkpoints, uint _value) internal  {
           if ((checkpoints.length == 0) || (checkpoints[checkpoints.length 1].fromblock < block.number)) {
               checkpoint newcheckpoint = checkpoints[ checkpoints.length++ ];
               newcheckpoint.fromblock =  block.number;
               newcheckpoint.value = _value;
           } else {
               checkpoint oldcheckpoint = checkpoints[checkpoints.length1];
               oldcheckpoint.value = _value;
           }
    }

    
    
    
    function ()  payable {
        if (owner == 0) throw;
        if (! tokencreation(owner).proxypayment.value(msg.value)(msg.sender)) {
            throw;
        }
    }





    event transfer(address indexed _from, address indexed _to, uint256 _value);
    event approval(address indexed _owner, address indexed _spender, uint256 _value);
    event newchildtoken(address indexed _childtoken, uint _snapshotblock);

}

contract minimetokenfactory {
    function createchildtoken(
        address _parenttoken,
        uint _snapshotblock,
        string _tokenname,
        uint8 _decimalunits,
        string _tokensymbol,
        bool _isconstant
    ) returns (minimetoken) {
        minimetoken newtoken = new minimetoken(this, _parenttoken, _snapshotblock, _tokenname, _decimalunits, _tokensymbol, _isconstant);
        return newtoken;
    }
}
