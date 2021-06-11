

pragma solidity 0.4.21;


import ;
import ;
import ;


contract ethernomin is externstateproxyfeetoken {

    

    
    address public oracle;

    
    court public court;

    
    address public beneficiary;

    
    uint public nominpool;

    
    uint public poolfeerate = unit / 200;

    
    uint constant minimum_purchase = unit / 100;

    
    uint constant minimum_issuance_ratio =  2 * unit;

    
    uint constant auto_liquidation_ratio = unit;

    
    uint constant default_liquidation_period = 14 days;
    uint constant max_liquidation_period = 180 days;
    uint public liquidationperiod = default_liquidation_period;

    
    uint public liquidationtimestamp = ~uint(0);

    
    uint public etherprice;

    
    uint public lastpriceupdatetime;

    
    uint public staleperiod = 60 minutes;

    
    mapping(address => bool) public frozen;


    

    
    function ethernomin(address _havven, address _oracle,
                        address _beneficiary,
                        uint _initialetherprice,
                        address _owner, tokenstate _initialstate)
        externstateproxyfeetoken(, ,
                                 15 * unit / 10000, 
                                 _havven, 
                                 _initialstate,
                                 _owner)
        public
    {
        oracle = _oracle;
        beneficiary = _beneficiary;

        etherprice = _initialetherprice;
        lastpriceupdatetime = now;
        emit priceupdated(_initialetherprice);

        
        frozen[this] = true;
    }


    

    
    function() public payable {}


    

    function setoracle(address _oracle)
        external
        optionalproxy_onlyowner
    {
        oracle = _oracle;
        emit oracleupdated(_oracle);
    }

    function setcourt(court _court)
        external
        optionalproxy_onlyowner
    {
        court = _court;
        emit courtupdated(_court);
    }

    function setbeneficiary(address _beneficiary)
        external
        optionalproxy_onlyowner
    {
        beneficiary = _beneficiary;
        emit beneficiaryupdated(_beneficiary);
    }

    function setpoolfeerate(uint _poolfeerate)
        external
        optionalproxy_onlyowner
    {
        require(_poolfeerate <= unit);
        poolfeerate = _poolfeerate;
        emit poolfeerateupdated(_poolfeerate);
    }

    function setstaleperiod(uint _staleperiod)
        external
        optionalproxy_onlyowner
    {
        staleperiod = _staleperiod;
        emit staleperiodupdated(_staleperiod);
    }
 

     

    
    function fiatvalue(uint etherwei)
        public
        view
        pricenotstale
        returns (uint)
    {
        return safemul_dec(etherwei, etherprice);
    }

    
    function fiatbalance()
        public
        view
        returns (uint)
    {
        
        return fiatvalue(address(this).balance);
    }

    
    function ethervalue(uint fiat)
        public
        view
        pricenotstale
        returns (uint)
    {
        return safediv_dec(fiat, etherprice);
    }

    
    function ethervalueallowstale(uint fiat) 
        internal
        view
        returns (uint)
    {
        return safediv_dec(fiat, etherprice);
    }

    
    function collateralisationratio()
        public
        view
        returns (uint)
    {
        return safediv_dec(fiatbalance(), _nomincap());
    }

    
    function _nomincap()
        internal
        view
        returns (uint)
    {
        return safeadd(nominpool, totalsupply);
    }

    
    function poolfeeincurred(uint n)
        public
        view
        returns (uint)
    {
        return safemul_dec(n, poolfeerate);
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
        return safeadd(lastpriceupdatetime, staleperiod) < now;
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
            
            bool alltokensreturned = (liquidationtimestamp + 1 weeks < now) && (totalsupply == 0);
            return totalperiodelapsed || alltokensreturned;
        }
        return false;
    }


    

    
    function transfer(address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transfer_byproxy(messagesender, to, value);
    }

    
    function transferfrom(address from, address to, uint value)
        public
        optionalproxy
        returns (bool)
    {
        require(!frozen[to]);
        return _transferfrom_byproxy(messagesender, from, to, value);
    }

    
    function updateprice(uint price, uint timesent)
        external
        postcheckautoliquidate
    {
        
        require(msg.sender == oracle);
        
        require(lastpriceupdatetime < timesent && timesent < now + 10 minutes);

        etherprice = price;
        lastpriceupdatetime = timesent;
        emit priceupdated(price);
    }

    
    function replenishpool(uint n)
        external
        payable
        notliquidating
        optionalproxy_onlyowner
    {
        
        require(fiatbalance() >= safemul_dec(safeadd(_nomincap(), n), minimum_issuance_ratio));
        nominpool = safeadd(nominpool, n);
        emit poolreplenished(n, msg.value);
    }

    
    function diminishpool(uint n)
        external
        optionalproxy_onlyowner
    {
        
        require(nominpool >= n);
        nominpool = safesub(nominpool, n);
        emit pooldiminished(n);
    }

    
    function buy(uint n)
        external
        payable
        notliquidating
        optionalproxy
    {
        
        require(n >= minimum_purchase &&
                msg.value == purchasecostether(n));
        address sender = messagesender;
        
        nominpool = safesub(nominpool, n);
        state.setbalanceof(sender, safeadd(state.balanceof(sender), n));
        emit purchased(sender, sender, n, msg.value);
        emit transfer(0, sender, n);
        totalsupply = safeadd(totalsupply, n);
    }

    
    function sell(uint n)
        external
        optionalproxy
    {

        
        
        
        uint proceeds;
        if (isliquidating()) {
            proceeds = saleproceedsetherallowstale(n);
        } else {
            proceeds = saleproceedsether(n);
        }

        require(address(this).balance >= proceeds);

        address sender = messagesender;
        
        state.setbalanceof(sender, safesub(state.balanceof(sender), n));
        nominpool = safeadd(nominpool, n);
        emit sold(sender, sender, n, proceeds);
        emit transfer(sender, 0, n);
        totalsupply = safesub(totalsupply, n);
        sender.transfer(proceeds);
    }

    
    function forceliquidation()
        external
        notliquidating
        optionalproxy_onlyowner
    {
        beginliquidation();
    }

    function beginliquidation()
        internal
    {
        liquidationtimestamp = now;
        emit liquidationbegun(liquidationperiod);
    }

    
    function extendliquidationperiod(uint extension)
        external
        optionalproxy_onlyowner
    {
        require(isliquidating());
        uint sum = safeadd(liquidationperiod, extension);
        require(sum <= max_liquidation_period);
        liquidationperiod = sum;
        emit liquidationextended(extension);
    }

    
    function terminateliquidation()
        external
        payable
        pricenotstale
        optionalproxy_onlyowner
    {
        require(isliquidating());
        require(_nomincap() == 0 || collateralisationratio() >= auto_liquidation_ratio);
        liquidationtimestamp = ~uint(0);
        liquidationperiod = default_liquidation_period;
        emit liquidationterminated();
    }

    
    function selfdestruct()
        external
        optionalproxy_onlyowner
    {
        require(canselfdestruct());
        emit selfdestructed(beneficiary);
        selfdestruct(beneficiary);
    }

    
    function confiscatebalance(address target)
        external
    {
        
        require(court(msg.sender) == court);
        
        
        uint motionid = court.targetmotionid(target);
        require(motionid != 0);

        
        
        
        require(court.motionconfirming(motionid));
        require(court.motionpasses(motionid));
        require(!frozen[target]);

        
        uint balance = state.balanceof(target);
        state.setbalanceof(address(this), safeadd(state.balanceof(address(this)), balance));
        state.setbalanceof(target, 0);
        frozen[target] = true;
        emit accountfrozen(target, target, balance);
        emit transfer(target, address(this), balance);
    }

    
    function unfreezeaccount(address target)
        external
        optionalproxy_onlyowner
    {
        if (frozen[target] && ethernomin(target) != this) {
            frozen[target] = false;
            emit accountunfrozen(target, target);
        }
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

    
    modifier postcheckautoliquidate
    {
        _;
        if (!isliquidating() && _nomincap() != 0 && collateralisationratio() < auto_liquidation_ratio) {
            beginliquidation();
        }
    }


    

    event poolreplenished(uint nominscreated, uint collateraldeposited);

    event pooldiminished(uint nominsdestroyed);

    event purchased(address buyer, address indexed buyerindex, uint nomins, uint etherwei);

    event sold(address seller, address indexed sellerindex, uint nomins, uint etherwei);

    event priceupdated(uint newprice);

    event staleperiodupdated(uint newperiod);

    event oracleupdated(address neworacle);

    event courtupdated(address newcourt);

    event beneficiaryupdated(address newbeneficiary);

    event liquidationbegun(uint duration);

    event liquidationterminated();

    event liquidationextended(uint extension);

    event poolfeerateupdated(uint newfeerate);

    event selfdestructed(address beneficiary);

    event accountfrozen(address target, address indexed targetindex, uint balance);

    event accountunfrozen(address target, address indexed targetindex);
}
