pragma solidity ^0.4.11;



contract erc20basic {
  uint256 public totalsupply;
  function balanceof(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity ^0.4.11;


import ;



contract pausable is ownable {
  event pause();
  event unpause();

  bool public paused = false;


  
  modifier whennotpaused() {
    require(!paused);
    _;
  }

  
  modifier whenpaused() {
    require(paused);
    _;
  }

  
  function pause() onlyowner whennotpaused public {
    paused = true;
    pause();
  }

  
  function unpause() onlyowner whenpaused public {
    paused = false;
    unpause();
  }
}
pragma solidity ^0.4.11;


import ;
import ;



contract standardtoken is erc20, basictoken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
  function transferfrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_to != contractaddress);
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  
  function increaseapproval (address _spender, uint _addedvalue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedvalue);
    approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseapproval (address _spender, uint _subtractedvalue) public returns (bool success) {
    uint oldvalue = allowed[msg.sender][_spender];
    if (_subtractedvalue > oldvalue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldvalue.sub(_subtractedvalue);
    }
    approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
pragma solidity ^0.4.11;



library safemath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a  b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
pragma solidity ^0.4.11;



contract ownable {
  address public owner;

  event ownershiptransferred(address indexed previousowner, address indexed newowner);


  
  function ownable() {
    owner = msg.sender;
  }


  
  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferownership(address newowner) onlyowner public {
    require(newowner != address(0));
    ownershiptransferred(owner, newowner);
    owner = newowner;
  }

}
pragma solidity ^0.4.11;


import ;



contract erc20 is erc20basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferfrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.4.13;


import ;
import ;



contract waxtoken is standardtoken, pausable {

  string public constant name = ;                          
  string public constant symbol = ;                                 
  uint8 public constant decimals = 8;                                  
  uint256 public constant initial_supply = 1000000000 * 10**uint256(decimals);    

  
  function waxtoken() {
    totalsupply = initial_supply;                               
    balances[msg.sender] = initial_supply;                      
    contractaddress = this;
    transfer(0x0, msg.sender, initial_supply);
  }

  
  function transfer(address _to, uint256 _value) whennotpaused returns (bool) {
    require(_to != address(0));
    require(_to != contractaddress);
    return super.transfer(_to, _value);
  }

  
  function transferfrom(address _from, address _to, uint256 _value) whennotpaused returns (bool) {
    require(_to != address(0));
    require(_to != contractaddress);
    return super.transferfrom(_from, _to, _value);
  }

  
  function approve(address _spender, uint256 _value) whennotpaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function() payable {
      revert();
  }

}
pragma solidity ^0.4.11;


import ;
import ;



contract basictoken is erc20basic {
  using safemath for uint256;
  address public contractaddress;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_to != contractaddress);
    require(_value <= balances[msg.sender]);

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceof(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

