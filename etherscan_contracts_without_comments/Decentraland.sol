

pragma solidity ^0.4.11;

contract erc20basic {
  uint256 public totalsupply;
  function balanceof(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event transfer(address indexed from, address indexed to, uint256 value);
}

contract ownable {
  address public owner;


  
  function ownable() {
    owner = msg.sender;
  }


  
  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferownership(address newowner) onlyowner {
    if (newowner != address(0)) {
      owner = newowner;
    }
  }

}

contract pausable is ownable {
  event pause();
  event unpause();

  bool public paused = false;


  
  modifier whennotpaused() {
    require(!paused);
    _;
  }

  
  modifier whenpaused {
    require(paused);
    _;
  }

  
  function pause() onlyowner whennotpaused returns (bool) {
    paused = true;
    pause();
    return true;
  }

  
  function unpause() onlyowner whenpaused returns (bool) {
    paused = false;
    unpause();
    return true;
  }
}

contract erc20 is erc20basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferfrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract basictoken is erc20basic {
  using safemath for uint256;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceof(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract standardtoken is erc20, basictoken {

  mapping (address => mapping (address => uint256)) allowed;


  
  function transferfrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    
    

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) returns (bool) {

    
    
    
    
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract mintabletoken is standardtoken, ownable {
  event mint(address indexed to, uint256 amount);
  event mintfinished();

  bool public mintingfinished = false;


  modifier canmint() {
    require(!mintingfinished);
    _;
  }

  
  function mint(address _to, uint256 _amount) onlyowner canmint returns (bool) {
    totalsupply = totalsupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    mint(_to, _amount);
    return true;
  }

  
  function finishminting() onlyowner returns (bool) {
    mintingfinished = true;
    mintfinished();
    return true;
  }
}

contract pausabletoken is standardtoken, pausable {

  function transfer(address _to, uint _value) whennotpaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferfrom(address _from, address _to, uint _value) whennotpaused returns (bool) {
    return super.transferfrom(_from, _to, _value);
  }
}

contract burnabletoken is standardtoken {

    event burn(address indexed burner, uint256 value);

    
    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalsupply = totalsupply.sub(_value);
        burn(msg.sender, _value);
    }

}

contract manatoken is burnabletoken, pausabletoken, mintabletoken {

    string public constant symbol = ;

    string public constant name = ;

    uint8 public constant decimals = 18;

    function burn(uint256 _value) whennotpaused public {
        super.burn(_value);
    }
}