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






contract seeletoken is pausabletoken {
    using safemath for uint;

    
    string public constant name = ;
    string public constant symbol = ;
    uint public constant decimals = 18;

    
    uint public currentsupply;

    
    
    address public minter; 

    
    mapping (address => uint) public lockedbalances;

    
    bool public claimedflag;  

    
    modifier onlyminter {
        require(msg.sender == minter);
        _;
    }

    modifier canclaimed {
        require(claimedflag == true);
        _;
    }

    modifier maxtokenamountnotreached (uint amount){
        require(currentsupply.add(amount) <= totalsupply);
        _;
    }

    modifier validaddress( address addr ) {
        require(addr != address(0x0));
        require(addr != address(this));
        _;
    }

    
    function seeletoken(address _minter, address _admin, uint _maxtotalsupply) 
        public 
        validaddress(_admin)
        validaddress(_minter)
        {
        minter = _minter;
        totalsupply = _maxtotalsupply;
        claimedflag = false;
        transferownership(_admin);
    }

    

    function mint(address receipent, uint amount, bool islock)
        external
        onlyminter
        maxtokenamountnotreached(amount)
        returns (bool)
    {
        if (islock ) {
            lockedbalances[receipent] = lockedbalances[receipent].add(amount);
        } else {
            balances[receipent] = balances[receipent].add(amount);
        }
        currentsupply = currentsupply.add(amount);
        return true;
    }


    function setclaimedflag(bool flag) 
        public
        onlyowner 
    {
        claimedflag = flag;
    }

     

    
    function claimtokens(address[] receipents)
        public
        canclaimed
    {        
        for (uint i = 0; i < receipents.length; i++) {
            address receipent = receipents[i];
            balances[receipent] = balances[receipent].add(lockedbalances[receipent]);
            lockedbalances[receipent] = 0;
        }
    }
}






contract seelecrowdsale is pausable {
    using safemath for uint;

    
    
    uint public constant seele_total_supply = 1000000000 ether;
    uint public constant max_sale_duration = 4 days;
    uint public constant stage_1_time =  6 hours;
    uint public constant stage_2_time = 12 hours;
    uint public constant min_limit = 0.1 ether;
    uint public constant max_stage_1_limit = 1 ether;
    uint public constant max_stage_2_limit = 2 ether;

    uint public constant stage_1 = 1;
    uint public constant stage_2 = 2;
    uint public constant stage_3 = 3;


    
    uint public  exchangerate = 12500;


    uint public constant miner_stake = 3000;    
    uint public constant open_sale_stake = 625; 
    uint public constant other_stake = 6375;    

    
    uint public constant divisor_stake = 10000;

    
    uint public constant max_open_sold = seele_total_supply * open_sale_stake / divisor_stake;
    uint public constant stake_multiplier = seele_total_supply / divisor_stake;

    
    address public wallet;
    address public mineraddress;
    address public otheraddress;

    
    uint public starttime;
    
    uint public endtime;

    
    
    uint public opensoldtokens;
    
    seeletoken public seeletoken; 

    
    mapping (address => bool) public fullwhitelist;

    mapping (address => uint) public firststagefund;
    mapping (address => uint) public secondstagefund;

    
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

    function seelecrowdsale (
        address _wallet, 
        address _mineraddress,
        address _otheraddress
        ) public 
        validaddress(_wallet) 
        validaddress(_mineraddress) 
        validaddress(_otheraddress) 
        {
        paused = true;  
        wallet = _wallet;
        mineraddress = _mineraddress;
        otheraddress = _otheraddress;     

        opensoldtokens = 0;
        
        seeletoken = new seeletoken(this, msg.sender, seele_total_supply);

        seeletoken.mint(mineraddress, miner_stake * stake_multiplier, false);
        seeletoken.mint(otheraddress, other_stake * stake_multiplier, false);
    }

    function setexchangerate(uint256 rate)
        public
        onlyowner
        earlierthan(endtime)
    {
        exchangerate = rate;
    }

    function setstarttime(uint _starttime )
        public
        onlyowner
    {
        starttime = _starttime;
        endtime = starttime + max_sale_duration;
    }

    
    
    function setwhitelist(address[] users, bool opentag)
        external
        onlyowner
        earlierthan(endtime)
    {
        require(salenotend());
        for (uint i = 0; i < users.length; i++) {
            fullwhitelist[users[i]] = opentag;
        }
    }


    
    
    function addwhitelist(address user, bool opentag)
        external
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
        buyseele(msg.sender);
    }

    
    
    
    function buyseele(address receipient) 
        internal 
        whennotpaused  
        ceilingnotreached 
        notearlierthan(starttime)
        earlierthan(endtime)
        validaddress(receipient)
        returns (bool) 
    {
        
        require(!iscontract(msg.sender));    
        require(tx.gasprice <= 100000000000 wei);
        require(msg.value >= min_limit);

        bool inwhitelisttag = fullwhitelist[receipient];       
        require(inwhitelisttag == true);

        uint stage = stage_3;
        if ( starttime <= now && now < starttime + stage_1_time ) {
            stage = stage_1;
            require(msg.value <= max_stage_1_limit);
        }else if ( starttime + stage_1_time <= now && now < starttime + stage_2_time ) {
            stage = stage_2;
            require(msg.value <= max_stage_2_limit);
        }

        dobuy(receipient, stage);

        return true;
    }


    
    function dobuy(address receipient, uint stage) internal {
        
        uint value = msg.value;

        if ( stage == stage_1 ) {
            uint fund1 = firststagefund[receipient];
            fund1 = fund1.add(value);
            if (fund1 > max_stage_1_limit ) {
                uint refund1 = fund1.sub(max_stage_1_limit);
                value = value.sub(refund1);
                msg.sender.transfer(refund1);
            }
        }else if ( stage == stage_2 ) {
            uint fund2 = secondstagefund[receipient];
            fund2 = fund2.add(value);
            if (fund2 > max_stage_2_limit) {
                uint refund2 = fund2.sub(max_stage_2_limit);
                value = value.sub(refund2);
                msg.sender.transfer(refund2);
            }            
        }

        uint tokenavailable = max_open_sold.sub(opensoldtokens);
        require(tokenavailable > 0);
        uint tofund;
        uint tocollect;
        (tofund, tocollect) = costandbuytokens(tokenavailable, value);
        if (tofund > 0) {
            require(seeletoken.mint(receipient, tocollect,true));         
            wallet.transfer(tofund);
            opensoldtokens = opensoldtokens.add(tocollect);
            newsale(receipient, tofund, tocollect);             
        }

        
        uint toreturn = value.sub(tofund);
        if (toreturn > 0) {
            msg.sender.transfer(toreturn);
        }

        if ( stage == stage_1 ) {
            firststagefund[receipient] = firststagefund[receipient].add(tofund);
        }else if ( stage == stage_2 ) {
            secondstagefund[receipient] = secondstagefund[receipient].add(tofund);          
        }
    }

    
    function costandbuytokens(uint availabletoken, uint value) constant internal returns (uint costvalue, uint gettokens) {
        
        gettokens = exchangerate * value;

        if (availabletoken >= gettokens) {
            costvalue = value;
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
}
