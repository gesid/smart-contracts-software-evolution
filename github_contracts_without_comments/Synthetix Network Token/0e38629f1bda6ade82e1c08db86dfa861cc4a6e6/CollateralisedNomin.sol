


pragma solidity ^0.4.19;



contract safefixedmath {
    
    
    uint public constant decimals = 18;

    
    uint public constant unit = 10 ** decimals;
    
    
    function addissafe(uint x, uint y) 
        pure
        internal
        returns (bool)
    {
        return x + y >= y;
    }

    
    function safeadd(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        assert(addissafe(x, y));
        return x + y;
    }
    
    
    function subissafe(uint x, uint y)
        pure
        internal
        returns (bool)
    {
        return y <= x;
    }

    
    function safesub(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        assert(subissafe(x, y));
        return x  y;
    }
    
    
    function mulissafe(uint x, uint y)
        pure
        internal
        returns (bool) 
    {
        if (x == 0) {
            return true;
        }
        uint r = x * y;
        return r / x == y;
    }

    
    function safemul(uint x, uint y)
        pure 
        internal 
        returns (uint)
    {
        assert(mulissafe(x, y));
        
        return (x * y) / unit;
    }
    
    
    function divissafe(uint x, uint y)
        pure 
        internal
        returns (bool)
    {
        return y != 0;
    }

    
    function safediv(uint x, uint y)
        pure
        internal
        returns (uint)
    {
        assert(mulissafe(x, unit)); 
        
        return (x * unit) / y;
    }
}


contract erc20feetoken is safefixedmath {
    
    
    uint supply = 0;
 
    
    mapping(address => uint) balances;

    
    mapping(address => mapping (address => uint256)) allowances;

    
    
    uint public transferfee = 0;
   
    
    function totalsupply()
        public
        view
        returns (uint)
    {
        return supply;
    }
 
    
    function balanceof(address _account)
        public
        view
        returns (uint)
    {
        return balances[_account];
    }

    
    function feecharged(uint _value) 
        public
        view
        returns (uint)
    {
        return safemul(_value, transferfee);
    }

    function settransferfee(uint newfee)
        public
        onlyowner
    {
        require(newfee <= unit);
        transferfee = newfee;
        transferfeeupdated(newfee);
    }
 
    
    function transfer(address _to, uint _value)
        public
        returns (bool)
    {
        
        uint totalcharge = safeadd(_value, feecharged(_value));
        if (subissafe(balances[msg.sender], totalcharge) &&
            addissafe(balances[_to], _value)) {
            transfer(msg.sender, _to, _value);
            
            
            if (_value == 0) {
                return true;
            }
            balances[msg.sender] = safesub(balances[msg.sender], totalcharge);
            balances[_to] = safeadd(balances[_to], _value);
            return true;
        }
        return false;
    }
 
    
    function transferfrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        
        uint totalcharge = safeadd(_value, feecharged(_value));
        if (subissafe(balances[_from], totalcharge) &&
            subissafe(allowances[_from][msg.sender], totalcharge) &&
            addissafe(balances[_to], _value)) {
                transfer(_from, _to, _value);
                
                
                if (_value == 0) {
                    return true;
                }
                balances[_from] = safesub(balances[_from], totalcharge);
                allowances[_from][msg.sender] = safesub(allowances[_from][msg.sender], totalcharge);
                balances[_to] = safeadd(balances[_to], _value);
                return true;
        }
        return false;
    }
  
    
    
    
    function approve(address _spender, uint _value)
        public
        returns (bool)
    {
        allowances[msg.sender][_spender] = _value;
        approval(msg.sender, _spender, _value);
        return true;
    }
 
    
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint)
    {
        return allowances[_owner][_spender];
    }
 
    
    event transfer(address indexed _from, address indexed _to, uint _value);
 
    
    event approval(address indexed _owner, address indexed _spender, uint _value);

    
    event transferfeeupdated(uint newfee);
}


contract havven is erc20feetoken {}



contract collateralisednomin is erc20feetoken {

    
    address owner;

    
    
    address oracle;

    
    address beneficiary;
    
    
    string public constant name = ;
    string public constant symbol = ;

    
    uint public pool = 0;
    
    
    uint public poolfee = unit / 200;
    
    
    uint public purchasemininum = unit / 100;

    
    uint public collatratiominimum =  2 * unit;

    
    uint public liquidationperiod = 90 days;
    
    
    uint public maxliquidationperiod = 180 days;

    
    
    
    uint public liquidationtimestamp = ~uint(0);
    
    
    uint public etherprice;
    
    
    uint public lastpriceupdate;

    
    
    uint public staleperiod = 3 days;

    
    function collateralisednomin(address _owner, address _oracle,
                                 address _beneficiary, uint initialetherprice) public
    {
        owner = _owner;
        oracle = _oracle;
        beneficiary = _beneficiary;
        etherprice = initialetherprice;
        lastpriceupdate = now;

        
        transferfee = unit / 1000; 
    }

    
    modifier onlyowner
    {
        require(msg.sender == owner);
        _;
    }

    
    modifier onlyoracle
    {
        require(msg.sender == oracle);
        _;
    }

    
    modifier notliquidating
    {
        require(!isliquidating());
        _;
    }

    modifier pricenotstale
    {
        require(!priceisstale());
        _;
    }
    
    
    function setowner(address newowner)
        public
        onlyowner
    {
        owner = newowner;
    }   
    
    
    function setoracle(address neworacle)
        public
        onlyowner
    {
        oracle = neworacle;
    }
    
    
    function setbeneficiary(address newbeneficiary)
        public
        onlyowner
    {
        beneficiary = newbeneficiary;
    }
    
    
    function fiatvalue(uint eth)
        public
        view
        pricenotstale
        returns (uint)
    {
        return safemul(eth, etherprice);
    }
    
    
    function fiatbalance()
        public
        view
        returns (uint)
    {
        
        return fiatvalue(this.balance);
    }
    
    
    function ethervalue(uint fiat)
        public
        view
        pricenotstale
        returns (uint)
    {
        return safediv(fiat, etherprice);
    }

    
    function transferfeeincurred(uint n)
        public
        view
        returns (uint)
    {
        return safemul(n, transferfee);
    }

    
    function issue(uint n)
        public
        onlyowner
        payable
    {
        
        
        
        require(fiatvalue(msg.value) + fiatbalance() >= safemul(this.supply + n, collatratiominimum));
        supply = safeadd(supply, n);
        pool = safeadd(pool, n);
        issuance(n, msg.value);
    }

    
    function burn(uint n)
        public
        onlyowner
    {
        
        require(pool >= n);
        pool = safesub(pool, n);
        supply = safesub(supply, n);
        burning(n);
    }
    */

    
    function poolfeeincurred(uint n)
        public
        view
        returns (uint)
    {
        return safemul(n, poolfee);
    }

    
    function purchasecostfiat(uint n)
        public
        view
        returns (uint)
    {
        return safeadd(n, poolfeeincurred(n));
    }

    
    function purchasecostether(uint n)
        public
        view
        returns (uint)
    {
        
        return ethervalue(purchasecostfiat(n));
    }

    
    function buy(uint n)
        public
        notliquidating
        payable
    {
        
        require(n >= purchasemininum &&
                msg.value == purchasecostether(n));
        
        pool = safesub(pool, n);
        balances[msg.sender] = safeadd(balances[msg.sender], n);
        purchase(msg.sender, n, msg.value);
    }
    
    
    function saleproceedsfiat(uint n)
        public
        view
        returns (uint)
    {
        return safesub(n, poolfeeincurred(n));
    }

    
    function saleproceedsether(uint n)
        public
        view
        returns (uint)
    {
        
        return ethervalue(saleproceedsfiat(n));
    }

    
    function sell(uint n)
        public
    {
        uint proceeds = saleproceedsfiat(n);
        
        require(fiatbalance() >= proceeds);
        
        balances[msg.sender] = safesub(balances[msg.sender], n);
        pool = safeadd(pool, n);
        msg.sender.transfer(proceeds);
        sale(msg.sender, n, proceeds);
    }

    
    function setprice(uint price)
        public
        onlyoracle
    {
        etherprice = price;
        lastpriceupdate = now;
        priceupdate(price);
    }

    
    function setstaleperiod(uint period)
        public
        onlyowner
    {
        staleperiod = period;
        staleperiodupdate(period);
    }

    
    function priceisstale()
        public
        view
        returns (bool)
    {
        return lastpriceupdate + staleperiod < now;
    }

    
    function liquidate()
        public
        onlyowner
        notliquidating
    {
        liquidationtimestamp = now;
        liquidation();
    }

    
    function extendliquidationperiod(uint extension)
        public
        onlyowner
    {
        require(liquidationperiod + extension <= maxliquidationperiod);
        liquidationperiod += extension;
        liquidationextended(extension);
    }
    
    
    function isliquidating()
        public
        view
        returns (bool)
    {
        return liquidationtimestamp <= now;
    }
    
    
    function selfdestruct()
        public
        onlyowner
    {
        require(isliquidating() &&
                liquidationtimestamp + liquidationperiod < now);
        selfdestructed();
        selfdestruct(beneficiary);
    }

    
    event issuance(uint nominsissued, uint collateraldeposited);

    
    event burning(uint nominsburned);

    
    event purchase(address buyer, uint nomins, uint eth);

    
    event sale(address seller, uint nomins, uint eth);

    
    event priceupdate(uint newprice);

    
    event staleperiodupdate(uint newperiod);

    
    event liquidation();

    
    event liquidationextended(uint extension);

    
    event selfdestructed();
}
