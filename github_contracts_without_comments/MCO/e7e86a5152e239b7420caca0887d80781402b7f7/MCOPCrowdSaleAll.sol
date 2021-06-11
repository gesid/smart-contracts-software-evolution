pragma solidity ^0.4.18;




contract ownable {
  address public owner;


  event ownershiptransferred(address indexed previousowner, address indexed newowner);


  
  function ownable() public {
    owner = msg.sender;
  }


  
  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferownership(address newowner) public onlyowner {
    require(newowner != address(0));
    ownershiptransferred(owner, newowner);
    owner = newowner;
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




library safemath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a  b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}




contract erc20basic {
  uint256 public totalsupply;
  function balanceof(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event transfer(address indexed from, address indexed to, uint256 value);
}




contract basictoken is erc20basic {
  using safemath for uint256;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceof(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}




contract erc20 is erc20basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferfrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event approval(address indexed owner, address indexed spender, uint256 value);
}




contract standardtoken is erc20, basictoken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
  function transferfrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
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

  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  
  function increaseapproval(address _spender, uint _addedvalue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedvalue);
    approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseapproval(address _spender, uint _subtractedvalue) public returns (bool) {
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





contract pausabletoken is standardtoken, pausable {

  function transfer(address _to, uint256 _value) public whennotpaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferfrom(address _from, address _to, uint256 _value) public whennotpaused returns (bool) {
    return super.transferfrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whennotpaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseapproval(address _spender, uint _addedvalue) public whennotpaused returns (bool success) {
    return super.increaseapproval(_spender, _addedvalue);
  }

  function decreaseapproval(address _spender, uint _subtractedvalue) public whennotpaused returns (bool success) {
    return super.decreaseapproval(_spender, _subtractedvalue);
  }
}






contract mcoptoken is pausabletoken {
    using safemath for uint;

    
    string public constant name = ;
    string public constant symbol = ;
    uint public constant decimals = 18;

    
    uint public maxtotalsupply;

    
    
    address public minter; 

    
    uint public starttime;
    
    uint public endtime;

    
    modifier onlyminter {
        assert(msg.sender == minter);
        _;
    }

    modifier islaterthan (uint x){
        assert(now > x);
        _;
    }

    modifier maxtokenamountnotreached (uint amount){
        assert(totalsupply.add(amount) <= maxtotalsupply);
        _;
    }

    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    
    function mcoptoken(address _minter, address _admin, uint _maxtotalsupply, uint _starttime, uint _endtime) 
        public 
        validaddress(_admin)
        validaddress(_minter)
        {
        minter = _minter;
        starttime = _starttime;
        endtime = _endtime;
        maxtotalsupply = _maxtotalsupply;
        transferownership(_admin);
    }

    

    function mint(address receipent, uint amount)
        external
        onlyminter
        maxtokenamountnotreached(amount)
        returns (bool)
    {
        require(now <= endtime);
        balances[receipent] = balances[receipent].add(amount);
        totalsupply = totalsupply.add(amount);
        return true;
    }
}




library safeerc20 {
  function safetransfer(erc20basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safetransferfrom(erc20 token, address from, address to, uint256 value) internal {
    assert(token.transferfrom(from, to, value));
  }

  function safeapprove(erc20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}




contract tokentimelock {
  using safeerc20 for erc20basic;

  
  erc20basic public token;

  
  address public beneficiary;

  
  uint public releasetime;

  function tokentimelock(erc20basic _token, address _beneficiary, uint _releasetime) public {
    require(_releasetime > now);
    token = _token;
    beneficiary = _beneficiary;
    releasetime = _releasetime;
  }

  
  function release() public {
    require(now >= releasetime);

    uint256 amount = token.balanceof(this);
    require(amount > 0);

    token.safetransfer(beneficiary, amount);
  }
}







contract mcopcrowdsale is pausable {
    using safemath for uint;

    
    
    uint public constant mcop_total_supply = 10000000000 ether;
    uint public constant max_sale_duration = 3 weeks;

    
    uint public constant lock_time =  5 years;

    
    uint public constant price_rate_first = 20833;
    
    uint public constant price_rate_second = 18518;
    
    uint public constant price_rate_last = 16667;


    uint256 public minbuylimit = 0.1 ether;
    uint256 public maxbuylimit = 100 ether;

    uint public constant lock_stake = 800;  
    uint public constant dev_team_stake = 98;     
    uint public constant community_stake = 2;     
    uint public constant pre_sale_stake = 60;      
    uint public constant open_sale_stake = 40;

    
    uint public constant divisor_stake = 1000;

    
    uint public constant max_open_sold = mcop_total_supply * open_sale_stake / divisor_stake;
    uint public constant stake_multiplier = mcop_total_supply / divisor_stake;

    
    address public wallet;
    address public presaleaddress;
    address public lockaddress;
    address public teamaddress;
    address public communityaddress;
    
    uint public starttime;
    
    uint public endtime;

    
    
    uint public opensoldtokens;
    
    mcoptoken public mcoptoken; 

    
    tokentimelock public tokentimelock; 

    
    mapping (address => uint) public fullwhitelist;

    
    event newsale(address indexed destaddress, uint ethcost, uint gottokens);
    event newwallet(address onwer, address oldwallet, address newwallet);
    
    

    modifier notearlierthan(uint x) {
        require(now >= x);
        _;
    }

    modifier earlierthan(uint x) {
        require(now < x);
        _;
    }

    modifier ceilingnotreached() {
        require(opensoldtokens < max_open_sold);
        _;
    }  

    modifier issaleended() {
        require(now > endtime || opensoldtokens >= max_open_sold);
        _;
    }

    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    function mcopcrowdsale (address _admin, 
        address _wallet, 
        address _presaleaddress,
        address _lockaddress,
        address _teamaddress,
        address _communityaddress,
        uint _starttime 
        ) public 
        validaddress(_admin) 
        validaddress(_wallet) 
        validaddress(_presaleaddress) 
        validaddress(_lockaddress) 
        validaddress(_teamaddress) 
        validaddress(_communityaddress) 
        {

        wallet = _wallet;
        presaleaddress = _presaleaddress;
        lockaddress = _lockaddress;
        teamaddress = _teamaddress;
        communityaddress = _communityaddress;        
        starttime = _starttime;
        endtime = starttime + max_sale_duration;

        opensoldtokens = 0;
        
        mcoptoken = new mcoptoken(this, _admin, mcop_total_supply, starttime, endtime);

        tokentimelock = new tokentimelock(mcoptoken, lockaddress, now + lock_time);

        
        mcoptoken.mint(presaleaddress, pre_sale_stake * stake_multiplier);
        mcoptoken.mint(tokentimelock, lock_stake * stake_multiplier);
        mcoptoken.mint(teamaddress, dev_team_stake * stake_multiplier);
        mcoptoken.mint(communityaddress, community_stake * stake_multiplier);  

        transferownership(_admin);
    }

    function setmaxbuylimit(uint256 limit)
        public
        onlyowner
        earlierthan(endtime)
    {
        maxbuylimit = limit;
    }

    function setminbuylimit(uint256 limit)
        public
        onlyowner
        earlierthan(endtime)
    {
        minbuylimit = limit;
    }

    
    
    function setwhitelist(address[] users, uint opentag)
        public
        onlyowner
        earlierthan(endtime)
    {
        require(salenotend());
        
        for (uint i = 0; i < users.length; i++) {
            
            fullwhitelist[users[i]] = opentag;
        }
    }


    
    
    function addwhitelist(address user, uint opentag)
        public
        onlyowner
        earlierthan(endtime)
    {
        require(salenotend());
        
        fullwhitelist[user] = opentag;

    }

    
    function setwallet(address newaddress)  external onlyowner { 
        newwallet(owner, wallet, newaddress);
        wallet = newaddress; 
    }

    
    function salenotend() constant internal returns (bool) {
        return now < endtime && opensoldtokens < max_open_sold;
    }

    
    function () public payable {
      buympc(msg.sender);
    }

    
    
    
    function buympc(address receipient) 
        public 
        payable 
        whennotpaused  
        ceilingnotreached 
        earlierthan(endtime)
        validaddress(receipient)
        returns (bool) 
    {
        require(msg.value >= minbuylimit);
        require(msg.value <= maxbuylimit);
        
        require(!iscontract(msg.sender));        

        require(tx.gasprice <= 50000000000 wei);

        uint inwhitelisttag = fullwhitelist[receipient];
        
        require(inwhitelisttag>0);
        
        dobuy(receipient);

        return true;
    }


    
    function dobuy(address receipient) internal {
        
        uint tokenavailable = max_open_sold.sub(opensoldtokens);
        require(tokenavailable > 0);
        uint tofund;
        uint tocollect;
        (tofund, tocollect) = costandbuytokens(tokenavailable);
        if (tofund > 0) {
            require(mcoptoken.mint(receipient, tocollect));         
            wallet.transfer(tofund);
            opensoldtokens = opensoldtokens.add(tocollect);
            newsale(receipient, tofund, tocollect);             
        }

        
        uint toreturn = msg.value.sub(tofund);
        if (toreturn > 0) {
            msg.sender.transfer(toreturn);
        }
    }

    
    
    function pricerate() public view returns (uint) {
        if (starttime <= now && now < starttime + 1 weeks ) {
            return  price_rate_first;
        }else if (starttime + 1 weeks <= now && now < starttime + 2 weeks ) {
            return price_rate_second;
        }else if (starttime + 2 weeks <= now && now < endtime) {
            return price_rate_last;
        }else {
            assert(false);
        }
        return now;
    }

    
    function costandbuytokens(uint availabletoken) constant internal returns (uint costvalue, uint gettokens) {
        
        uint exchangerate = pricerate();
        gettokens = exchangerate * msg.value;

        if (availabletoken >= gettokens) {
            costvalue = msg.value;
        } else {
            costvalue = availabletoken / exchangerate;
            gettokens = availabletoken;
        }
    }

    
    
    
    function iscontract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) {
            return false;
        }

        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    
    function releaselocktoken()  external onlyowner {
        tokentimelock.release();
    }
}
