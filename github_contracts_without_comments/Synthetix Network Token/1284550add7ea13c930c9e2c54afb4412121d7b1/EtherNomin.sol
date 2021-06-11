

pragma solidity ^0.4.19;


import ;
import ;
import ;


contract ethernomin is erc20feetoken {

    

    
    
    address public oracle;

    
    court public court;

    
    address public beneficiary;

    
    uint public nominpool = 0;

    
    uint public poolfeerate = unit / 200;

    
    uint constant purchasemininum = unit / 100;

    
    uint constant collatratiominimum =  2 * unit;

    
    
    uint constant autoliquidationratio = unit;

    
    
    uint constant defaultliquidationperiod = 90 days;
    uint constant maxliquidationperiod = 180 days;
    uint public liquidationperiod = defaultliquidationperiod;

    
    
    
    uint public liquidationtimestamp = ~uint(0);

    
    uint public etherprice;

    
    uint public lastpriceupdate;

    
    
    uint public staleperiod = 2 days;

    
    mapping(address => bool) public isfrozen;


    

    function ethernomin(havven _havven, address _oracle,
                        address _beneficiary,
                        uint initialetherprice,
                        address _owner)
        erc20feetoken(, ,
                      0, _owner,
                      unit / 500, 
                      address(_havven), 
                      _owner)
        public
    {
        oracle = _oracle;
        beneficiary = _beneficiary;

        etherprice = initialetherprice;
        lastpriceupdate = now;
        priceupdated(etherprice);

        isfrozen[this] = true;
    }


    

    function setoracle(address neworacle)
        public
        onlyowner
    {
        oracle = neworacle;
        oracleupdated(neworacle);
    }

    function setcourt(address newcourt)
        public
        onlyowner
    {
        court = court(newcourt);
        courtupdated(newcourt);
    }

    function setbeneficiary(address newbeneficiary)
        public
        onlyowner
    {
        beneficiary = newbeneficiary;
        beneficiaryupdated(newbeneficiary);
    }

    function setpoolfeerate(uint newfeerate)
        public
        onlyowner
    {
        require(newfeerate <= unit);
        poolfeerate = newfeerate;
        poolfeerateupdated(newfeerate);
    }

    function setstaleperiod(uint period)
        public
        onlyowner
    {
        staleperiod = period;
        staleperiodupdated(period);
    }

    

    
    function fiatvalue(uint eth)
        public
        view
        pricenotstale
        returns (uint)
    {
        return safedecmul(eth, etherprice);
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
        return safedecdiv(fiat, etherprice);
    }

    
    function ethervalueallowstale(uint fiat) 
        internal
        view
        returns (uint)
    {
        return safedecdiv(fiat, etherprice);
    }

    
    function collateralisationratio()
        public
        view
        returns (uint)
    {
        return safedecdiv(fiatbalance(), totalsupply);
    }

    
    function poolfeeincurred(uint n)
        public
        view
        returns (uint)
    {
        return safedecmul(n, poolfeerate);
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

    
    function saleproceedsetherallowstale(uint n)
        internal
        view
        returns (uint)
    {
        return ethervalueallowstale(saleproceedsfiat(n));
    }

    
    function priceisstale()
        public
        view
        returns (bool)
    {
        return lastpriceupdate + staleperiod < now;
    }

    function isliquidating()
        public
        view
        returns (bool)
    {
        return liquidationtimestamp <= now;
    }

    
    function canselfdestruct()
        public
        view
        returns (bool)
    {
        
        
        if (isliquidating()) {
            bool totalperiodelapsed = liquidationtimestamp + liquidationperiod < now;
            bool alltokensreturned = (liquidationtimestamp + 1 weeks < now) && (nominpool == totalsupply);
            return totalperiodelapsed || alltokensreturned;
        }
        return false;
    }


    

    
    function transfer(address _to, uint _value)
        public
        returns (bool)
    {
        require(!(isfrozen[msg.sender] || isfrozen[_to]));
        return super.transfer(_to, _value);
    }

    
    function transferfrom(address _from, address _to, uint _value)
        public
        returns (bool)
    {
        require(!(isfrozen[_from] || isfrozen[_to]));
        return super.transferfrom(_from, _to, _value);
    }

    
    function updateprice(uint price)
        public
        postcheckautoliquidate
    {
        
        require(msg.sender == oracle);

        etherprice = price;
        lastpriceupdate = now;
        priceupdated(price);
    }

    
    function issue(uint n)
        public
        onlyowner
        payable
        notliquidating
    {
        
        
        
        require(fiatbalance() >= safedecmul(totalsupply + n, collatratiominimum));
        totalsupply = safeadd(totalsupply, n);
        nominpool = safeadd(nominpool, n);
        issuance(n, msg.value);
    }

    
    function burn(uint n)
        public
        onlyowner
    {
        
        require(nominpool >= n);
        nominpool = safesub(nominpool, n);
        totalsupply = safesub(totalsupply, n);
        burning(n);
    }

    
    function buy(uint n)
        public
        notliquidating
        payable
    {
        
        require(n >= purchasemininum &&
                msg.value == purchasecostether(n));
        
        nominpool = safesub(nominpool, n);
        balanceof[msg.sender] = safeadd(balanceof[msg.sender], n);
        purchase(msg.sender, msg.sender, n, msg.value);
    }

    
    function sell(uint n)
        public
    {

        
        
        
        uint proceeds;
        if (isliquidating()) {
            proceeds = saleproceedsetherallowstale(n);
        } else {
            proceeds = saleproceedsether(n);
        }

        require(this.balance >= proceeds);

        
        balanceof[msg.sender] = safesub(balanceof[msg.sender], n);
        nominpool = safeadd(nominpool, n);
        sale(msg.sender, msg.sender, n, proceeds);
        msg.sender.transfer(proceeds);
    }

    
    function forceliquidation()
        public
        onlyowner
        notliquidating
    {
        beginliquidation();
    }

    function beginliquidation()
        internal
    {
        liquidationtimestamp = now;
        liquidation(liquidationperiod);
    }

    
    function extendliquidationperiod(uint extension)
        public
        onlyowner
    {
        require(isliquidating());
        require(liquidationperiod + extension <= maxliquidationperiod);
        liquidationperiod += extension;
        liquidationextended(extension);
    }

    
    function terminateliquidation()
        public
        onlyowner
        pricenotstale
        payable
    {
        require(isliquidating());
        require(totalsupply == 0 || collateralisationratio() >= autoliquidationratio);
        liquidationtimestamp = ~uint(0);
        liquidationperiod = defaultliquidationperiod;
        liquidationterminated();
    }

    
    function selfdestruct()
        public
        onlyowner
    {
        require(canselfdestruct());
        selfdestructed();
        selfdestruct(beneficiary);
    }

    
    function confiscatebalance(address target)
        public
    {
        
        require(court(msg.sender) == court);

        
        
        
        require(court.confirming(target));
        require(court.votepasses(target));

        
        uint balance = balanceof[target];
        feepool = safeadd(feepool, balance);
        balanceof[target] = 0;
        isfrozen[target] = true;
        confiscation(target, target, balance);
    }

    
    function unfreezeaccount(address target)
        public
        onlyowner
    {
        if (isfrozen[target] && ethernomin(target) != this) {
            isfrozen[target] = false;
            accountunfrozen(target, target);
        }
    }

    
    function() public payable {}


    

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

    
    modifier postcheckautoliquidate
    {
        _;
        if (!isliquidating() && totalsupply != 0 && collateralisationratio() < autoliquidationratio) {
            beginliquidation();
        }
    }


    

    event issuance(uint nominsissued, uint collateraldeposited);

    event burning(uint nominsburned);

    event purchase(address buyer, address indexed buyerindex, uint nomins, uint eth);

    event sale(address seller, address indexed sellerindex, uint nomins, uint eth);

    event priceupdated(uint newprice);

    event staleperiodupdated(uint newperiod);

    event oracleupdated(address neworacle);

    event courtupdated(address newcourt);

    event beneficiaryupdated(address newbeneficiary);

    event liquidation(uint duration);

    event liquidationterminated();

    event liquidationextended(uint extension);

    event poolfeerateupdated(uint newfeerate);

    event selfdestructed();

    event confiscation(address target, address indexed targetindex, uint balance);

    event accountunfrozen(address target, address indexed targetindex);
}
