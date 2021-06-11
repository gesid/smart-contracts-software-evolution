

pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;
import ;
import ;
import ;

contract feepool is proxyable, selfdestructible, limitedsetup {

    using safemath for uint;
    using safedecimalmath for uint;

    synthetix public synthetix;
    isynthetixstate public synthetixstate;
    isynthetixescrow public rewardescrow;

    
    uint public transferfeerate;

    
    uint constant public max_transfer_fee_rate = safedecimalmath.unit() / 10;

    
    uint public exchangefeerate;

    
    uint constant public max_exchange_fee_rate = safedecimalmath.unit() / 10;

    
    address public feeauthority;

    
    feepoolstate public feepoolstate;

    
    address public constant fee_address = 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef;

    
    struct feeperiod {
        uint feeperiodid;
        uint startingdebtindex;
        uint starttime;
        uint feestodistribute;
        uint feesclaimed;
        uint rewardstodistribute;
        uint rewardsclaimed;
    }

    
    
    
    
    uint8 constant public fee_period_length = 6;

    feeperiod[fee_period_length] public recentfeeperiods;

    
    uint public nextfeeperiodid;

    
    
    
    
    
    uint public feeperiodduration = 1 weeks; 

    
    uint public constant min_fee_period_duration = 60 seconds;  
    
    uint public constant max_fee_period_duration = 60 days;

    
    mapping(address => uint) public lastfeewithdrawal;

    
    
    uint constant twenty_percent = (20 * safedecimalmath.unit()) / 100;
    uint constant twenty_two_percent = (22 * safedecimalmath.unit()) / 100;
    uint constant twenty_five_percent = (25 * safedecimalmath.unit()) / 100;
    uint constant thirty_percent = (30 * safedecimalmath.unit()) / 100;
    uint constant fourty_percent = (40 * safedecimalmath.unit()) / 100;
    uint constant fifty_percent = (50 * safedecimalmath.unit()) / 100;
    uint constant seventy_five_percent = (75 * safedecimalmath.unit()) / 100;
    uint constant ninety_percent = (90 * safedecimalmath.unit()) / 100;
    uint constant one_hundred_percent = (100 * safedecimalmath.unit()) / 100;

    constructor(
        address _proxy,
        address _owner,
        synthetix _synthetix,
        feepoolstate _feepoolstate,
        isynthetixstate _synthetixstate,
        isynthetixescrow _rewardescrow,
        address _feeauthority,
        uint _transferfeerate,
        uint _exchangefeerate)
        selfdestructible(_owner)
        proxyable(_proxy, _owner)
        limitedsetup(3 weeks)
        public
    {
        
        require(_transferfeerate <= max_transfer_fee_rate, );
        require(_exchangefeerate <= max_exchange_fee_rate, );

        synthetix = _synthetix;
        feepoolstate = _feepoolstate;
        rewardescrow = _rewardescrow;
        synthetixstate = _synthetixstate;
        feeauthority = _feeauthority;
        transferfeerate = _transferfeerate;
        exchangefeerate = _exchangefeerate;

        
        recentfeeperiods[0].feeperiodid = 1;
        recentfeeperiods[0].starttime = now;

        
        nextfeeperiodid = 2;
    }

    
    function appendaccountissuancerecord(address account, uint debtratio, uint debtentryindex)
        external
        onlysynthetix
    {
        feepoolstate.appendaccountissuancerecord(account, debtratio, debtentryindex, recentfeeperiods[0].startingdebtindex);

        emitissuancedebtratioentry(account, debtratio, debtentryindex, recentfeeperiods[0].startingdebtindex);
    }

    
    function setexchangefeerate(uint _exchangefeerate)
        external
        optionalproxy_onlyowner
    {
        require(_exchangefeerate <= max_exchange_fee_rate, );

        exchangefeerate = _exchangefeerate;

        emitexchangefeeupdated(_exchangefeerate);
    }

    
    function settransferfeerate(uint _transferfeerate)
        external
        optionalproxy_onlyowner
    {
        require(_transferfeerate <= max_transfer_fee_rate, );

        transferfeerate = _transferfeerate;

        emittransferfeeupdated(_transferfeerate);
    }

    
    function setfeeauthority(address _feeauthority)
        external
        optionalproxy_onlyowner
    {
        feeauthority = _feeauthority;

        emitfeeauthorityupdated(_feeauthority);
    }

    
    function setfeepoolstate(feepoolstate _feepoolstate)
        external
        optionalproxy_onlyowner
    {
        feepoolstate = _feepoolstate;

        emitfeepoolstateupdated(_feepoolstate);
    }

    
    function setfeeperiodduration(uint _feeperiodduration)
        external
        optionalproxy_onlyowner
    {
        require(_feeperiodduration >= min_fee_period_duration, );
        require(_feeperiodduration <= max_fee_period_duration, );

        feeperiodduration = _feeperiodduration;

        emitfeeperioddurationupdated(_feeperiodduration);
    }

    
    function setsynthetix(synthetix _synthetix)
        external
        optionalproxy_onlyowner
    {
        require(address(_synthetix) != address(0), );

        synthetix = _synthetix;

        emitsynthetixupdated(_synthetix);
    }

    
    function feepaid(bytes4 currencykey, uint amount)
        external
        onlysynthetix
    {
        uint xdramount;

        if (currencykey != ) {
            xdramount = synthetix.effectivevalue(currencykey, amount, );
        } else {
            xdramount = amount;
        }

        
        recentfeeperiods[0].feestodistribute = recentfeeperiods[0].feestodistribute.add(xdramount);
    }

    
    function rewardsminted(uint amount)
        external
        onlysynthetix
    {
        
        recentfeeperiods[0].rewardstodistribute = recentfeeperiods[0].rewardstodistribute.add(amount);
    }

    
    function closecurrentfeeperiod()
        external
        onlyfeeauthority
    {
        require(recentfeeperiods[0].starttime <= (now  feeperiodduration), );

        feeperiod memory secondlastfeeperiod = recentfeeperiods[fee_period_length  2];
        feeperiod memory lastfeeperiod = recentfeeperiods[fee_period_length  1];

        
        
        
        
        
        recentfeeperiods[fee_period_length  2].feestodistribute = lastfeeperiod.feestodistribute
            .sub(lastfeeperiod.feesclaimed)
            .add(secondlastfeeperiod.feestodistribute);

        
        
        
        
        
        for (uint i = fee_period_length  2; i < fee_period_length; i) {
            uint next = i + 1;
            recentfeeperiods[next].feeperiodid = recentfeeperiods[i].feeperiodid;
            recentfeeperiods[next].startingdebtindex = recentfeeperiods[i].startingdebtindex;
            recentfeeperiods[next].starttime = recentfeeperiods[i].starttime;
            recentfeeperiods[next].feestodistribute = recentfeeperiods[i].feestodistribute;
            recentfeeperiods[next].feesclaimed = recentfeeperiods[i].feesclaimed;
            recentfeeperiods[next].rewardstodistribute = recentfeeperiods[i].rewardstodistribute;
            recentfeeperiods[next].rewardsclaimed = recentfeeperiods[i].rewardsclaimed;
        }

        
        delete recentfeeperiods[0];

        
        recentfeeperiods[0].feeperiodid = nextfeeperiodid;
        recentfeeperiods[0].startingdebtindex = synthetixstate.debtledgerlength();
        recentfeeperiods[0].starttime = now;

        nextfeeperiodid = nextfeeperiodid.add(1);

        emitfeeperiodclosed(recentfeeperiods[1].feeperiodid);
    }

    
    function claimfees(bytes4 currencykey)
        external
        optionalproxy
        returns (bool)
    {
        uint availablefees;
        uint availablerewards;
        (availablefees, availablerewards) = feesavailable(messagesender, );

        require(availablefees > 0 || availablerewards > 0, );

        lastfeewithdrawal[messagesender] = recentfeeperiods[1].feeperiodid;

        if (availablefees > 0) {
            
            uint feespaid = _recordfeepayment(availablefees);

            
            _payfees(messagesender, feespaid, currencykey);

            emitfeesclaimed(messagesender, feespaid);
        }

        if (availablerewards > 0) {
            
            uint rewardpaid = _recordrewardpayment(availablerewards);

            
            _payrewards(messagesender, rewardpaid);

            emitrewardsclaimed(messagesender, rewardpaid);
        }

        return true;
    }

    function importfeeperiod(
        uint feeperiodindex, uint feeperiodid, uint startingdebtindex, uint starttime,
        uint feestodistribute, uint feesclaimed, uint rewardstodistribute, uint rewardsclaimed)
        public
        optionalproxy_onlyowner
        onlyduringsetup
    {
        recentfeeperiods[feeperiodindex].feeperiodid = feeperiodid;
        recentfeeperiods[feeperiodindex].startingdebtindex = startingdebtindex;
        recentfeeperiods[feeperiodindex].starttime = starttime;
        recentfeeperiods[feeperiodindex].feestodistribute = feestodistribute;
        recentfeeperiods[feeperiodindex].feesclaimed = feesclaimed;
        recentfeeperiods[feeperiodindex].rewardstodistribute = rewardstodistribute;
        recentfeeperiods[feeperiodindex].rewardsclaimed = rewardsclaimed;
    }


    
    function _recordfeepayment(uint xdramount)
        internal
        returns (uint)
    {
        
        uint remainingtoallocate = xdramount;

        uint feespaid;
        
        
        
        for (uint i = fee_period_length  1; i < fee_period_length; i) {
            uint delta = recentfeeperiods[i].feestodistribute.sub(recentfeeperiods[i].feesclaimed);

            if (delta > 0) {
                
                uint amountinperiod = delta < remainingtoallocate ? delta : remainingtoallocate;

                recentfeeperiods[i].feesclaimed = recentfeeperiods[i].feesclaimed.add(amountinperiod);
                remainingtoallocate = remainingtoallocate.sub(amountinperiod);
                feespaid = feespaid.add(amountinperiod);

                
                if (remainingtoallocate == 0) return feespaid;

                
                
                if (i == 0 && remainingtoallocate > 0) {
                    remainingtoallocate = 0;
                }
            }
        }

        return feespaid;
    }

    
    function _recordrewardpayment(uint snxamount)
        internal
        returns (uint)
    {
        
        uint remainingtoallocate = snxamount;
        
        uint rewardpaid;

        
        
        
        for (uint i = fee_period_length  1; i < fee_period_length; i) {
            uint todistribute = recentfeeperiods[i].rewardstodistribute.sub(recentfeeperiods[i].rewardsclaimed);

            if (todistribute > 0) {
                
                uint amountinperiod = todistribute < remainingtoallocate ? todistribute : remainingtoallocate;

                recentfeeperiods[i].rewardsclaimed = recentfeeperiods[i].rewardsclaimed.add(amountinperiod);
                remainingtoallocate = remainingtoallocate.sub(amountinperiod);
                rewardpaid = rewardpaid.add(amountinperiod);

                
                if (remainingtoallocate == 0) return rewardpaid;

                
                
                
                if (i == 0 && remainingtoallocate > 0) {
                    remainingtoallocate = 0;
                }
            }
        }
        return rewardpaid;
    }

    
    function _payfees(address account, uint xdramount, bytes4 destinationcurrencykey)
        internal
        notfeeaddress(account)
    {
        require(account != address(0), );
        require(account != address(this), );
        require(account != address(proxy), );
        require(account != address(synthetix), );

        synth xdrsynth = synthetix.synths();
        synth destinationsynth = synthetix.synths(destinationcurrencykey);

        
        

        
        xdrsynth.burn(fee_address, xdramount);

        
        uint destinationamount = synthetix.effectivevalue(, xdramount, destinationcurrencykey);

        

        
        destinationsynth.issue(account, destinationamount);

        

        
        destinationsynth.triggertokenfallbackifneeded(fee_address, account, destinationamount);
    }

    
    function _payrewards(address account, uint snxamount)
        internal
        notfeeaddress(account)
    {
        require(account != address(0), );
        require(account != address(this), );
        require(account != address(proxy), );
        require(account != address(synthetix), );

        
        
        rewardescrow.appendvestingentry(account, snxamount);
    }

    
    function transferfeeincurred(uint value)
        public
        view
        returns (uint)
    {
        return value.multiplydecimal(transferfeerate);

        
        
        
        
        
        
        
    }

    
    function transferredamounttoreceive(uint value)
        external
        view
        returns (uint)
    {
        return value.add(transferfeeincurred(value));
    }

    
    function amountreceivedfromtransfer(uint value)
        external
        view
        returns (uint)
    {
        return value.dividedecimal(transferfeerate.add(safedecimalmath.unit()));
    }

    
    function exchangefeeincurred(uint value)
        public
        view
        returns (uint)
    {
        return value.multiplydecimal(exchangefeerate);

        
        
        
        
        
        
        
    }

    
    function exchangedamounttoreceive(uint value)
        external
        view
        returns (uint)
    {
        return value.add(exchangefeeincurred(value));
    }

    
    function amountreceivedfromexchange(uint value)
        external
        view
        returns (uint)
    {
        return value.multiplydecimal(safedecimalmath.unit().sub(exchangefeerate));
    }

    
    function totalfeesavailable(bytes4 currencykey)
        external
        view
        returns (uint)
    {
        uint totalfees = 0;

        
        for (uint i = 1; i < fee_period_length; i++) {
            totalfees = totalfees.add(recentfeeperiods[i].feestodistribute);
            totalfees = totalfees.sub(recentfeeperiods[i].feesclaimed);
        }

        return synthetix.effectivevalue(, totalfees, currencykey);
    }

    
    function totalrewardsavailable()
        external
        view
        returns (uint)
    {
        uint totalrewards = 0;

        
        for (uint i = 1; i < fee_period_length; i++) {
            totalrewards = totalrewards.add(recentfeeperiods[i].rewardstodistribute);
            totalrewards = totalrewards.sub(recentfeeperiods[i].rewardsclaimed);
        }

        return totalrewards;
    }

    
    function feesavailable(address account, bytes4 currencykey)
        public
        view
        returns (uint, uint)
    {
        
        uint[2][fee_period_length] memory userfees = feesbyperiod(account);

        uint totalfees = 0;
        uint totalrewards = 0;

        
        for (uint i = 1; i < fee_period_length; i++) {
            totalfees = totalfees.add(userfees[i][0]);
            totalrewards = totalrewards.add(userfees[i][1]);
        }

        
        
        return (
            synthetix.effectivevalue(, totalfees, currencykey),
            totalrewards
        );
    }

    
    function currentpenalty(address account)
        public
        view
        returns (uint)
    {
        uint ratio = synthetix.collateralisationratio(account);

        
        
        
        
        
        
        
        
        if (ratio <= twenty_percent) {
            return 0;
        } else if (ratio > twenty_percent && ratio <= twenty_two_percent) {
            return 0;
        } else if (ratio > twenty_two_percent && ratio <= thirty_percent) {
            return twenty_five_percent;
        } else if (ratio > thirty_percent && ratio <= fourty_percent) {
            return fifty_percent;
        } else if (ratio > fourty_percent && ratio <= fifty_percent) {
            return seventy_five_percent;
        } else if (ratio > fifty_percent && ratio <= one_hundred_percent) {
            return ninety_percent;
        }
        return one_hundred_percent;
    }

    
    function feesbyperiod(address account)
        public
        view
        returns (uint[2][fee_period_length] memory results)
    {
        
        uint userownershippercentage;
        uint debtentryindex;
        (userownershippercentage, debtentryindex) = feepoolstate.getaccountsdebtentry(account, 0);

        
        if (debtentryindex == 0 && userownershippercentage == 0) return;

        
        if (synthetix.totalissuedsynths() == 0) return;

        uint penalty = currentpenalty(account);

        
        
        uint feesfromperiod;
        uint rewardsfromperiod;
        (feesfromperiod, rewardsfromperiod) = _feesandrewardsfromperiod(0, userownershippercentage, debtentryindex, penalty);

        results[0][0] = feesfromperiod;
        results[0][1] = rewardsfromperiod;

        
        
        for (uint i = fee_period_length  1; i > 0; i) {
            uint next = i  1;
            feeperiod memory nextperiod = recentfeeperiods[next];

            
            if (nextperiod.startingdebtindex > 0 &&
            lastfeewithdrawal[account] < recentfeeperiods[i].feeperiodid) {

                
                
                
                uint closingdebtindex = nextperiod.startingdebtindex.sub(1);

                
                
                
                (userownershippercentage, debtentryindex) = feepoolstate.applicableissuancedata(account, closingdebtindex);

                (feesfromperiod, rewardsfromperiod) = _feesandrewardsfromperiod(i, userownershippercentage, debtentryindex, penalty);

                results[i][0] = feesfromperiod;
                results[i][1] = rewardsfromperiod;
            }
        }
    }

    
    function _feesandrewardsfromperiod(uint period, uint ownershippercentage, uint debtentryindex, uint penalty)
        internal
        returns (uint, uint)
    {
        
        if (ownershippercentage == 0) return (0, 0);

        uint debtownershipforperiod = ownershippercentage;

        
        if (period > 0) {
            uint closingdebtindex = recentfeeperiods[period  1].startingdebtindex.sub(1);
            debtownershipforperiod = _effectivedebtratioforperiod(closingdebtindex, ownershippercentage, debtentryindex);
        }

        
        
        uint feesfromperiodwithoutpenalty = recentfeeperiods[period].feestodistribute
            .multiplydecimal(debtownershipforperiod);

        uint rewardsfromperiodwithoutpenalty = recentfeeperiods[period].rewardstodistribute
            .multiplydecimal(debtownershipforperiod);

        
        uint feesfromperiod = feesfromperiodwithoutpenalty.sub(feesfromperiodwithoutpenalty.multiplydecimal(penalty));

        uint rewardsfromperiod = rewardsfromperiodwithoutpenalty.sub(rewardsfromperiodwithoutpenalty.multiplydecimal(penalty));

        return (
            feesfromperiod.precisedecimaltodecimal(),
            rewardsfromperiod.precisedecimaltodecimal()
        );
    }

    function _effectivedebtratioforperiod(uint closingdebtindex, uint ownershippercentage, uint debtentryindex)
        internal
        view
        returns (uint)
    {
        
        if (closingdebtindex > synthetixstate.debtledgerlength()) return 0;

        
        
        uint feeperioddebtownership = synthetixstate.getdebtledgerat(closingdebtindex)
            .dividedecimalroundprecise(synthetixstate.getdebtledgerat(debtentryindex))
            .multiplydecimalroundprecise(ownershippercentage);

        return feeperioddebtownership;
    }

    function effectivedebtratioforperiod(address account, uint period)
        external
        view
        returns (uint)
    {
        require(period != 0, );
        require(period < fee_period_length, );

        
        if (recentfeeperiods[period  1].startingdebtindex == 0) return;

        uint closingdebtindex = recentfeeperiods[period  1].startingdebtindex.sub(1);

        uint ownershippercentage;
        uint debtentryindex;
        (ownershippercentage, debtentryindex) = feepoolstate.applicableissuancedata(account, closingdebtindex);

        
        return _effectivedebtratioforperiod(closingdebtindex, ownershippercentage, debtentryindex);
    }

    modifier onlyfeeauthority
    {
        require(msg.sender == feeauthority, );
        _;
    }

    modifier onlysynthetix
    {
        require(msg.sender == address(synthetix), );
        _;
    }

    modifier notfeeaddress(address account) {
        require(account != fee_address, );
        _;
    }

    

    event issuancedebtratioentry(address indexed account, uint debtratio, uint debtentryindex, uint feeperiodstartingdebtindex);
    bytes32 constant issuancedebtratioentry_sig = keccak256();
    function emitissuancedebtratioentry(address account, uint debtratio, uint debtentryindex, uint feeperiodstartingdebtindex) internal {
        proxy._emit(abi.encode(debtratio, debtentryindex, feeperiodstartingdebtindex), 2, issuancedebtratioentry_sig, bytes32(account), 0, 0);
    }

    event transferfeeupdated(uint newfeerate);
    bytes32 constant transferfeeupdated_sig = keccak256();
    function emittransferfeeupdated(uint newfeerate) internal {
        proxy._emit(abi.encode(newfeerate), 1, transferfeeupdated_sig, 0, 0, 0);
    }

    event exchangefeeupdated(uint newfeerate);
    bytes32 constant exchangefeeupdated_sig = keccak256();
    function emitexchangefeeupdated(uint newfeerate) internal {
        proxy._emit(abi.encode(newfeerate), 1, exchangefeeupdated_sig, 0, 0, 0);
    }

    event feeperioddurationupdated(uint newfeeperiodduration);
    bytes32 constant feeperioddurationupdated_sig = keccak256();
    function emitfeeperioddurationupdated(uint newfeeperiodduration) internal {
        proxy._emit(abi.encode(newfeeperiodduration), 1, feeperioddurationupdated_sig, 0, 0, 0);
    }

    event feeauthorityupdated(address newfeeauthority);
    bytes32 constant feeauthorityupdated_sig = keccak256();
    function emitfeeauthorityupdated(address newfeeauthority) internal {
        proxy._emit(abi.encode(newfeeauthority), 1, feeauthorityupdated_sig, 0, 0, 0);
    }

    event feepoolstateupdated(address newfeepoolstate);
    bytes32 constant feepoolstateupdated_sig = keccak256();
    function emitfeepoolstateupdated(address newfeepoolstate) internal {
        proxy._emit(abi.encode(newfeepoolstate), 1, feepoolstateupdated_sig, 0, 0, 0);
    }

    event feeperiodclosed(uint feeperiodid);
    bytes32 constant feeperiodclosed_sig = keccak256();
    function emitfeeperiodclosed(uint feeperiodid) internal {
        proxy._emit(abi.encode(feeperiodid), 1, feeperiodclosed_sig, 0, 0, 0);
    }

    event feesclaimed(address account, uint xdramount);
    bytes32 constant feesclaimed_sig = keccak256();
    function emitfeesclaimed(address account, uint xdramount) internal {
        proxy._emit(abi.encode(account, xdramount), 1, feesclaimed_sig, 0, 0, 0);
    }

    event rewardsclaimed(address account, uint snxamount);
    bytes32 constant rewardsclaimed_sig = keccak256();
    function emitrewardsclaimed(address account, uint snxamount) internal {
        proxy._emit(abi.encode(account, snxamount), 1, rewardsclaimed_sig, 0, 0, 0);
    }

    event synthetixupdated(address newsynthetix);
    bytes32 constant synthetixupdated_sig = keccak256();
    function emitsynthetixupdated(address newsynthetix) internal {
        proxy._emit(abi.encode(newsynthetix), 1, synthetixupdated_sig, 0, 0, 0);
    }
}
