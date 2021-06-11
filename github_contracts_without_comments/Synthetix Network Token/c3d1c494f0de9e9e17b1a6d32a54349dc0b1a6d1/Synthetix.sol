pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;



contract synthetix is externstatetoken {
    

    
    synth[] public availablesynths;
    mapping(bytes32 => synth) public synths;
    mapping(address => bytes32) public synthsbyaddress;

    ifeepool public feepool;
    isynthetixescrow public escrow;
    isynthetixescrow public rewardescrow;
    exchangerates public exchangerates;
    synthetixstate public synthetixstate;
    supplyschedule public supplyschedule;
    irewardsdistribution public rewardsdistribution;

    bool private protectioncircuit = false;

    string constant token_name = ;
    string constant token_symbol = ;
    uint8 constant decimals = 18;
    bytes32 constant susd = ;

    bool public exchangeenabled = true;
    uint public gaspricelimit;

    address public gaslimitoracle;

    

    
    constructor(
        address _proxy,
        tokenstate _tokenstate,
        synthetixstate _synthetixstate,
        address _owner,
        exchangerates _exchangerates,
        ifeepool _feepool,
        supplyschedule _supplyschedule,
        isynthetixescrow _rewardescrow,
        isynthetixescrow _escrow,
        irewardsdistribution _rewardsdistribution,
        uint _totalsupply
    ) public externstatetoken(_proxy, _tokenstate, token_name, token_symbol, _totalsupply, decimals, _owner) {
        synthetixstate = _synthetixstate;
        exchangerates = _exchangerates;
        feepool = _feepool;
        supplyschedule = _supplyschedule;
        rewardescrow = _rewardescrow;
        escrow = _escrow;
        rewardsdistribution = _rewardsdistribution;
    }

    

    function setfeepool(ifeepool _feepool) external optionalproxy_onlyowner {
        feepool = _feepool;
    }

    function setexchangerates(exchangerates _exchangerates) external optionalproxy_onlyowner {
        exchangerates = _exchangerates;
    }

    function setprotectioncircuit(bool _protectioncircuitisactivated) external onlyoracle {
        protectioncircuit = _protectioncircuitisactivated;
    }

    function setexchangeenabled(bool _exchangeenabled) external optionalproxy_onlyowner {
        exchangeenabled = _exchangeenabled;
    }

    function setgaslimitoracle(address _gaslimitoracle) external optionalproxy_onlyowner {
        gaslimitoracle = _gaslimitoracle;
    }

    function setgaspricelimit(uint _gaspricelimit) external {
        require(msg.sender == gaslimitoracle, );
        require(_gaspricelimit > 0, );
        gaspricelimit = _gaspricelimit;
    }

    
    function addsynth(synth synth) external optionalproxy_onlyowner {
        bytes32 currencykey = synth.currencykey();

        require(synths[currencykey] == synth(0), );
        require(synthsbyaddress[synth] == bytes32(0), );

        availablesynths.push(synth);
        synths[currencykey] = synth;
        synthsbyaddress[synth] = currencykey;
    }

    
    function removesynth(bytes32 currencykey) external optionalproxy_onlyowner {
        require(synths[currencykey] != address(0), );
        require(synths[currencykey].totalsupply() == 0, );
        require(currencykey != susd, );

        
        address synthtoremove = synths[currencykey];

        
        for (uint i = 0; i < availablesynths.length; i++) {
            if (availablesynths[i] == synthtoremove) {
                delete availablesynths[i];

                
                
                
                availablesynths[i] = availablesynths[availablesynths.length  1];

                
                availablesynths.length;

                break;
            }
        }

        
        delete synthsbyaddress[synths[currencykey]];
        delete synths[currencykey];

        
        
        
    }

    

    
    function effectivevalue(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
        public
        view
        returns (uint)
    {
        return exchangerates.effectivevalue(sourcecurrencykey, sourceamount, destinationcurrencykey);
    }

    
    function totalissuedsynths(bytes32 currencykey) public view returns (uint) {
        uint total = 0;
        uint currencyrate = exchangerates.rateforcurrency(currencykey);

        (uint[] memory rates, bool anyratestale) = exchangerates.ratesandstaleforcurrencies(availablecurrencykeys());
        require(!anyratestale, );

        for (uint i = 0; i < availablesynths.length; i++) {
            
            
            
            
            uint synthvalue = availablesynths[i].totalsupply().multiplydecimalround(rates[i]);
            total = total.add(synthvalue);
        }

        return total.dividedecimalround(currencyrate);
    }

    
    function availablecurrencykeys() public view returns (bytes32[]) {
        bytes32[] memory currencykeys = new bytes32[](availablesynths.length);

        for (uint i = 0; i < availablesynths.length; i++) {
            currencykeys[i] = synthsbyaddress[availablesynths[i]];
        }

        return currencykeys;
    }

    
    function availablesynthcount() public view returns (uint) {
        return availablesynths.length;
    }

    
    function feerateforexchange(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey) public view returns (uint) {
        
        uint exchangefeerate = feepool.exchangefeerate();

        uint multiplier = 1;

        
        
        if (
            (sourcecurrencykey[0] == 0x73 && sourcecurrencykey != susd && destinationcurrencykey[0] == 0x69) ||
            (sourcecurrencykey[0] == 0x69 && destinationcurrencykey != susd && destinationcurrencykey[0] == 0x73)
        ) {
            
            multiplier = 2;
        }

        return exchangefeerate.mul(multiplier);
    }

    

    
    function transfer(address to, uint value) public optionalproxy returns (bool) {
        
        require(value <= transferablesynthetix(messagesender), );

        
        _transfer_byproxy(messagesender, to, value);

        return true;
    }

    
    function transferfrom(address from, address to, uint value) public optionalproxy returns (bool) {
        
        require(value <= transferablesynthetix(from), );

        
        
        return _transferfrom_byproxy(messagesender, from, to, value);
    }

    
    function exchange(bytes32 sourcecurrencykey, uint sourceamount, bytes32 destinationcurrencykey)
        external
        optionalproxy
        returns (
            
            bool
        )
    {
        require(sourcecurrencykey != destinationcurrencykey, );
        require(sourceamount > 0, );

        
        validategasprice(tx.gasprice);

        
        if (protectioncircuit) {
            synths[sourcecurrencykey].burn(messagesender, sourceamount);
            return true;
        } else {
            
            return
                _internalexchange(
                    messagesender,
                    sourcecurrencykey,
                    sourceamount,
                    destinationcurrencykey,
                    messagesender,
                    true 
                );
        }
    }

    
    function validategasprice(uint _givengasprice) public view {
        require(_givengasprice <= gaspricelimit, );
    }

    
    function synthinitiatedexchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress
    ) external optionalproxy returns (bool) {
        require(synthsbyaddress[messagesender] != bytes32(0), );
        require(sourcecurrencykey != destinationcurrencykey, );
        require(sourceamount > 0, );

        
        return
            _internalexchange(from, sourcecurrencykey, sourceamount, destinationcurrencykey, destinationaddress, false);
    }

    
    function _internalexchange(
        address from,
        bytes32 sourcecurrencykey,
        uint sourceamount,
        bytes32 destinationcurrencykey,
        address destinationaddress,
        bool chargefee
    ) internal returns (bool) {
        require(exchangeenabled, );

        
        

        
        synths[sourcecurrencykey].burn(from, sourceamount);

        
        uint destinationamount = effectivevalue(sourcecurrencykey, sourceamount, destinationcurrencykey);

        
        uint amountreceived = destinationamount;
        uint fee = 0;

        if (chargefee) {
            
            uint exchangefeerate = feerateforexchange(sourcecurrencykey, destinationcurrencykey);

            amountreceived = destinationamount.multiplydecimal(safedecimalmath.unit().sub(exchangefeerate));

            fee = destinationamount.sub(amountreceived);
        }

        
        synths[destinationcurrencykey].issue(destinationaddress, amountreceived);

        
        if (fee > 0) {
            uint usdfeeamount = effectivevalue(destinationcurrencykey, fee, susd);
            synths[susd].issue(feepool.fee_address(), usdfeeamount);
            
            feepool.recordfeepaid(usdfeeamount);
        }

        

        
        emitsynthexchange(
            from,
            sourcecurrencykey,
            sourceamount,
            destinationcurrencykey,
            amountreceived,
            destinationaddress
        );

        return true;
    }

    
    function _addtodebtregister(uint amount, uint existingdebt) internal {
        
        uint totaldebtissued = totalissuedsynths(susd);

        
        uint newtotaldebtissued = amount.add(totaldebtissued);

        
        uint debtpercentage = amount.dividedecimalroundprecise(newtotaldebtissued);

        
        
        
        
        uint delta = safedecimalmath.preciseunit().sub(debtpercentage);

        
        if (existingdebt > 0) {
            debtpercentage = amount.add(existingdebt).dividedecimalroundprecise(newtotaldebtissued);
        }

        
        if (existingdebt == 0) {
            synthetixstate.incrementtotalissuercount();
        }

        
        synthetixstate.setcurrentissuancedata(messagesender, debtpercentage);

        
        
        if (synthetixstate.debtledgerlength() > 0) {
            synthetixstate.appenddebtledgervalue(
                synthetixstate.lastdebtledgerentry().multiplydecimalroundprecise(delta)
            );
        } else {
            synthetixstate.appenddebtledgervalue(safedecimalmath.preciseunit());
        }
    }

    
    function issuesynths(uint amount)
        public
        optionalproxy
    
    {
        
        (uint maxissuable, uint existingdebt) = remainingissuablesynths(messagesender);
        require(amount <= maxissuable, );

        
        _addtodebtregister(amount, existingdebt);

        
        synths[susd].issue(messagesender, amount);

        
        _appendaccountissuancerecord();
    }

    
    function issuemaxsynths() external optionalproxy {
        
        (uint maxissuable, uint existingdebt) = remainingissuablesynths(messagesender);

        
        _addtodebtregister(maxissuable, existingdebt);

        
        synths[susd].issue(messagesender, maxissuable);

        
        _appendaccountissuancerecord();
    }

    
    function burnsynths(uint amount)
        external
        optionalproxy
    
    {
        
        uint debttoremove = amount;
        uint existingdebt = debtbalanceof(messagesender, susd);

        require(existingdebt > 0, );

        
        
        uint amounttoremove = existingdebt < debttoremove ? existingdebt : debttoremove;

        
        _removefromdebtregister(amounttoremove, existingdebt);

        uint amounttoburn = amounttoremove;

        
        synths[susd].burn(messagesender, amounttoburn);

        
        _appendaccountissuancerecord();
    }

    
    function _appendaccountissuancerecord() internal {
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = synthetixstate.issuancedata(messagesender);

        feepool.appendaccountissuancerecord(messagesender, initialdebtownership, debtentryindex);
    }

    
    function _removefromdebtregister(uint amount, uint existingdebt) internal {
        uint debttoremove = amount;

        
        uint totaldebtissued = totalissuedsynths(susd);

        
        uint newtotaldebtissued = totaldebtissued.sub(debttoremove);

        uint delta = 0;

        
        
        if (newtotaldebtissued > 0) {
            
            uint debtpercentage = debttoremove.dividedecimalroundprecise(newtotaldebtissued);

            
            
            
            delta = safedecimalmath.preciseunit().add(debtpercentage);
        }

        
        if (debttoremove == existingdebt) {
            synthetixstate.setcurrentissuancedata(messagesender, 0);
            synthetixstate.decrementtotalissuercount();
        } else {
            
            uint newdebt = existingdebt.sub(debttoremove);
            uint newdebtpercentage = newdebt.dividedecimalroundprecise(newtotaldebtissued);

            
            synthetixstate.setcurrentissuancedata(messagesender, newdebtpercentage);
        }

        
        synthetixstate.appenddebtledgervalue(synthetixstate.lastdebtledgerentry().multiplydecimalroundprecise(delta));
    }

    

    
    function maxissuablesynths(address issuer)
        public
        view
        returns (
            
            uint
        )
    {
        
        uint destinationvalue = effectivevalue(, collateral(issuer), susd);

        
        return destinationvalue.multiplydecimal(synthetixstate.issuanceratio());
    }

    
    function collateralisationratio(address issuer) public view returns (uint) {
        uint totalownedsynthetix = collateral(issuer);
        if (totalownedsynthetix == 0) return 0;

        uint debtbalance = debtbalanceof(issuer, );
        return debtbalance.dividedecimalround(totalownedsynthetix);
    }

    
    function debtbalanceof(address issuer, bytes32 currencykey)
        public
        view
        returns (
            
            uint
        )
    {
        
        uint initialdebtownership;
        uint debtentryindex;
        (initialdebtownership, debtentryindex) = synthetixstate.issuancedata(issuer);

        
        if (initialdebtownership == 0) return 0;

        
        
        uint currentdebtownership = synthetixstate
            .lastdebtledgerentry()
            .dividedecimalroundprecise(synthetixstate.debtledger(debtentryindex))
            .multiplydecimalroundprecise(initialdebtownership);

        
        uint totalsystemvalue = totalissuedsynths(currencykey);

        
        uint highprecisionbalance = totalsystemvalue.decimaltoprecisedecimal().multiplydecimalroundprecise(
            currentdebtownership
        );

        
        return highprecisionbalance.precisedecimaltodecimal();
    }

    
    function remainingissuablesynths(address issuer)
        public
        view
        returns (
            
            uint,
            uint
        )
    {
        uint alreadyissued = debtbalanceof(issuer, susd);
        uint maxissuable = maxissuablesynths(issuer);

        if (alreadyissued >= maxissuable) {
            maxissuable = 0;
        } else {
            maxissuable = maxissuable.sub(alreadyissued);
        }
        return (maxissuable, alreadyissued);
    }

    
    function collateral(address account) public view returns (uint) {
        uint balance = tokenstate.balanceof(account);

        if (escrow != address(0)) {
            balance = balance.add(escrow.balanceof(account));
        }

        if (rewardescrow != address(0)) {
            balance = balance.add(rewardescrow.balanceof(account));
        }

        return balance;
    }

    
    function transferablesynthetix(address account)
        public
        view
        ratenotstale() 
        returns (uint)
    {
        
        
        
        uint balance = tokenstate.balanceof(account);

        
        
        
        
        uint lockedsynthetixvalue = debtbalanceof(account, ).dividedecimalround(synthetixstate.issuanceratio());

        
        if (lockedsynthetixvalue >= balance) {
            return 0;
        } else {
            return balance.sub(lockedsynthetixvalue);
        }
    }

    
    function mint() external returns (bool) {
        require(rewardsdistribution != address(0), );

        uint supplytomint = supplyschedule.mintablesupply();
        require(supplytomint > 0, );

        
        supplyschedule.recordmintevent(supplytomint);

        
        
        uint minterreward = supplyschedule.minterreward();
        
        uint amounttodistribute = supplytomint.sub(minterreward);

        
        tokenstate.setbalanceof(rewardsdistribution, tokenstate.balanceof(rewardsdistribution).add(amounttodistribute));
        emittransfer(this, rewardsdistribution, amounttodistribute);

        
        rewardsdistribution.distributerewards(amounttodistribute);

        
        tokenstate.setbalanceof(msg.sender, tokenstate.balanceof(msg.sender).add(minterreward));
        emittransfer(this, msg.sender, minterreward);

        totalsupply = totalsupply.add(supplytomint);

        return true;
    }

    

    modifier ratenotstale(bytes32 currencykey) {
        require(!exchangerates.rateisstale(currencykey), );
        _;
    }

    modifier onlyoracle {
        require(msg.sender == exchangerates.oracle(), );
        _;
    }

    
    
    event synthexchange(
        address indexed account,
        bytes32 fromcurrencykey,
        uint256 fromamount,
        bytes32 tocurrencykey,
        uint256 toamount,
        address toaddress
    );
    bytes32 constant synthexchange_sig = keccak256();

    function emitsynthexchange(
        address account,
        bytes32 fromcurrencykey,
        uint256 fromamount,
        bytes32 tocurrencykey,
        uint256 toamount,
        address toaddress
    ) internal {
        proxy._emit(
            abi.encode(fromcurrencykey, fromamount, tocurrencykey, toamount, toaddress),
            2,
            synthexchange_sig,
            bytes32(account),
            0,
            0
        );
    }
    
}
