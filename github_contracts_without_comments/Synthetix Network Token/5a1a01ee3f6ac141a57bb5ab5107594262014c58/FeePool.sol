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
import ;
import ;
import ;
import ;
import ;
import ;



contract feepool is proxyable, selfdestructible, limitedsetup, mixinresolver {
    using safemath for uint;
    using safedecimalmath for uint;

    
    uint public exchangefeerate;

    
    uint public constant max_exchange_fee_rate = safedecimalmath.unit() / 10;

    
    address public constant fee_address = 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef;

    
    bytes32 private susd = ;

    
    struct feeperiod {
        uint64 feeperiodid;
        uint64 startingdebtindex;
        uint64 starttime;
        uint feestodistribute;
        uint feesclaimed;
        uint rewardstodistribute;
        uint rewardsclaimed;
    }

    
    
    
    
    
    
    uint8 public constant fee_period_length = 3;

    feeperiod[fee_period_length] private _recentfeeperiods;
    uint256 private _currentfeeperiod;

    
    
    
    
    uint public feeperiodduration = 1 weeks;
    
    uint public constant min_fee_period_duration = 1 days;
    uint public constant max_fee_period_duration = 60 days;

    
    uint public targetthreshold = (1 * safedecimalmath.unit()) / 100;

    

    bytes32 private constant contract_exrates = ;
    bytes32 private constant contract_synthetix = ;
    bytes32 private constant contract_feepoolstate = ;
    bytes32 private constant contract_feepooleternalstorage = ;
    bytes32 private constant contract_exchanger = ;
    bytes32 private constant contract_issuer = ;
    bytes32 private constant contract_synthetixstate = ;
    bytes32 private constant contract_rewardescrow = ;
    bytes32 private constant contract_delegateapprovals = ;

    bytes32[24] private addressestocache = [
        contract_exrates,
        contract_synthetix,
        contract_feepoolstate,
        contract_feepooleternalstorage,
        contract_exchanger,
        contract_issuer,
        contract_synthetixstate,
        contract_rewardescrow,
        contract_delegateapprovals
    ];

    

    bytes32 private constant last_fee_withdrawal = ;

    constructor(address _proxy, address _owner, uint _exchangefeerate, address _resolver)
        public
        selfdestructible(_owner)
        proxyable(_proxy, _owner)
        limitedsetup(3 weeks)
        mixinresolver(_owner, _resolver, addressestocache)
    {
        
        require(_exchangefeerate <= max_exchange_fee_rate, );

        exchangefeerate = _exchangefeerate;

        
        _recentfeeperiodsstorage(0).feeperiodid = 1;
        _recentfeeperiodsstorage(0).starttime = uint64(now);
    }

    

    function synthetix() internal view returns (isynthetix) {
        return isynthetix(requireandgetaddress(contract_synthetix, ));
    }

    function feepoolstate() internal view returns (feepoolstate) {
        return feepoolstate(requireandgetaddress(contract_feepoolstate, ));
    }

    function feepooleternalstorage() internal view returns (feepooleternalstorage) {
        return
            feepooleternalstorage(
                requireandgetaddress(contract_feepooleternalstorage, )
            );
    }

    function exchanger() internal view returns (iexchanger) {
        return iexchanger(requireandgetaddress(contract_exchanger, ));
    }

    function issuer() internal view returns (iissuer) {
        return iissuer(requireandgetaddress(contract_issuer, ));
    }

    function synthetixstate() internal view returns (isynthetixstate) {
        return isynthetixstate(requireandgetaddress(contract_synthetixstate, ));
    }

    function rewardescrow() internal view returns (isynthetixescrow) {
        return isynthetixescrow(requireandgetaddress(contract_rewardescrow, ));
    }

    function delegateapprovals() internal view returns (delegateapprovals) {
        return delegateapprovals(requireandgetaddress(contract_delegateapprovals, ));
    }

    function recentfeeperiods(uint index)
        external
        view
        returns (
            uint64 feeperiodid,
            uint64 startingdebtindex,
            uint64 starttime,
            uint feestodistribute,
            uint feesclaimed,
            uint rewardstodistribute,
            uint rewardsclaimed
        )
    {
        feeperiod memory feeperiod = _recentfeeperiodsstorage(index);
        return (
            feeperiod.feeperiodid,
            feeperiod.startingdebtindex,
            feeperiod.starttime,
            feeperiod.feestodistribute,
            feeperiod.feesclaimed,
            feeperiod.rewardstodistribute,
            feeperiod.rewardsclaimed
        );
    }

    function _recentfeeperiodsstorage(uint index) internal view returns (feeperiod storage) {
        return _recentfeeperiods[(_currentfeeperiod + index) % fee_period_length];
    }

    

    
    function appendaccountissuancerecord(address account, uint debtratio, uint debtentryindex) external onlyissuer {
        feepoolstate().appendaccountissuancerecord(
            account,
            debtratio,
            debtentryindex,
            _recentfeeperiodsstorage(0).startingdebtindex
        );

        emitissuancedebtratioentry(account, debtratio, debtentryindex, _recentfeeperiodsstorage(0).startingdebtindex);
    }

    
    function setexchangefeerate(uint _exchangefeerate) external optionalproxy_onlyowner {
        require(_exchangefeerate < max_exchange_fee_rate, );
        exchangefeerate = _exchangefeerate;
    }

    
    function setfeeperiodduration(uint _feeperiodduration) external optionalproxy_onlyowner {
        require(_feeperiodduration >= min_fee_period_duration, );
        require(_feeperiodduration <= max_fee_period_duration, );

        feeperiodduration = _feeperiodduration;

        emitfeeperioddurationupdated(_feeperiodduration);
    }

    function settargetthreshold(uint _percent) external optionalproxy_onlyowner {
        require(_percent >= 0, );
        require(_percent <= 50, );
        targetthreshold = _percent.mul(safedecimalmath.unit()).div(100);
    }

    
    function recordfeepaid(uint amount) external onlyexchangerorsynth {
        
        _recentfeeperiodsstorage(0).feestodistribute = _recentfeeperiodsstorage(0).feestodistribute.add(amount);
    }

    
    function setrewardstodistribute(uint amount) external {
        address rewardsauthority = resolver.getaddress();
        require(messagesender == rewardsauthority || msg.sender == rewardsauthority, );
        
        _recentfeeperiodsstorage(0).rewardstodistribute = _recentfeeperiodsstorage(0).rewardstodistribute.add(amount);
    }

    
    function closecurrentfeeperiod() external {
        require(_recentfeeperiodsstorage(0).starttime <= (now  feeperiodduration), );

        feeperiod storage secondlastfeeperiod = _recentfeeperiodsstorage(fee_period_length  2);
        feeperiod storage lastfeeperiod = _recentfeeperiodsstorage(fee_period_length  1);

        
        
        
        
        
        _recentfeeperiodsstorage(fee_period_length  2).feestodistribute = lastfeeperiod
            .feestodistribute
            .sub(lastfeeperiod.feesclaimed)
            .add(secondlastfeeperiod.feestodistribute);
        _recentfeeperiodsstorage(fee_period_length  2).rewardstodistribute = lastfeeperiod
            .rewardstodistribute
            .sub(lastfeeperiod.rewardsclaimed)
            .add(secondlastfeeperiod.rewardstodistribute);

        
        _currentfeeperiod = _currentfeeperiod.add(fee_period_length).sub(1).mod(fee_period_length);

        
        delete _recentfeeperiods[_currentfeeperiod];

        
        
        _recentfeeperiodsstorage(0).feeperiodid = uint64(uint256(_recentfeeperiodsstorage(1).feeperiodid).add(1));
        _recentfeeperiodsstorage(0).startingdebtindex = uint64(synthetixstate().debtledgerlength());
        _recentfeeperiodsstorage(0).starttime = uint64(now);

        emitfeeperiodclosed(_recentfeeperiodsstorage(1).feeperiodid);
    }

    
    function claimfees() external optionalproxy returns (bool) {
        return _claimfees(messagesender);
    }

    
    function claimonbehalf(address claimingforaddress) external optionalproxy returns (bool) {
        require(delegateapprovals().approval(claimingforaddress, messagesender), );

        return _claimfees(claimingforaddress);
    }

    function _claimfees(address claimingaddress) internal returns (bool) {
        uint rewardspaid = 0;
        uint feespaid = 0;
        uint availablefees;
        uint availablerewards;

        
        
        require(isfeesclaimable(claimingaddress), );

        
        (availablefees, availablerewards) = feesavailable(claimingaddress);

        require(
            availablefees > 0 || availablerewards > 0,
            
        );

        
        _setlastfeewithdrawal(claimingaddress, _recentfeeperiodsstorage(1).feeperiodid);

        if (availablefees > 0) {
            
            feespaid = _recordfeepayment(availablefees);

            
            _payfees(claimingaddress, feespaid);
        }

        if (availablerewards > 0) {
            
            rewardspaid = _recordrewardpayment(availablerewards);

            
            _payrewards(claimingaddress, rewardspaid);
        }

        emitfeesclaimed(claimingaddress, feespaid, rewardspaid);

        return true;
    }

    
    function importfeeperiod(
        uint feeperiodindex,
        uint feeperiodid,
        uint startingdebtindex,
        uint starttime,
        uint feestodistribute,
        uint feesclaimed,
        uint rewardstodistribute,
        uint rewardsclaimed
    ) public optionalproxy_onlyowner onlyduringsetup {
        require(startingdebtindex <= synthetixstate().debtledgerlength(), );

        _recentfeeperiods[_currentfeeperiod.add(feeperiodindex).mod(fee_period_length)] = feeperiod({
            feeperiodid: uint64(feeperiodid),
            startingdebtindex: uint64(startingdebtindex),
            starttime: uint64(starttime),
            feestodistribute: feestodistribute,
            feesclaimed: feesclaimed,
            rewardstodistribute: rewardstodistribute,
            rewardsclaimed: rewardsclaimed
        });
    }

    
    function appendvestingentry(address account, uint quantity) public optionalproxy_onlyowner {
        
        synthetix().transferfrom(messagesender, rewardescrow(), quantity);

        
        rewardescrow().appendvestingentry(account, quantity);
    }

    
    function approveclaimonbehalf(address account) public optionalproxy {
        require(account != address(0), );
        delegateapprovals().setapproval(messagesender, account);
    }

    
    function removeclaimonbehalf(address account) public optionalproxy {
        delegateapprovals().withdrawapproval(messagesender, account);
    }

    
    function _recordfeepayment(uint susdamount) internal returns (uint) {
        
        uint remainingtoallocate = susdamount;

        uint feespaid;
        
        
        
        for (uint i = fee_period_length  1; i < fee_period_length; i) {
            uint feesalreadyclaimed = _recentfeeperiodsstorage(i).feesclaimed;
            uint delta = _recentfeeperiodsstorage(i).feestodistribute.sub(feesalreadyclaimed);

            if (delta > 0) {
                
                uint amountinperiod = delta < remainingtoallocate ? delta : remainingtoallocate;

                _recentfeeperiodsstorage(i).feesclaimed = feesalreadyclaimed.add(amountinperiod);
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

    
    function _recordrewardpayment(uint snxamount) internal returns (uint) {
        
        uint remainingtoallocate = snxamount;

        uint rewardpaid;

        
        
        
        for (uint i = fee_period_length  1; i < fee_period_length; i) {
            uint todistribute = _recentfeeperiodsstorage(i).rewardstodistribute.sub(
                _recentfeeperiodsstorage(i).rewardsclaimed
            );

            if (todistribute > 0) {
                
                uint amountinperiod = todistribute < remainingtoallocate ? todistribute : remainingtoallocate;

                _recentfeeperiodsstorage(i).rewardsclaimed = _recentfeeperiodsstorage(i).rewardsclaimed.add(amountinperiod);
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

    
    function _payfees(address account, uint susdamount) internal notfeeaddress(account) {
        
        require(
            account != address(0) ||
                account != address(this) ||
                account != address(proxy) ||
                account != address(synthetix()),
            
        );

        
        synth susdsynth = synthetix().synths(susd);

        
        
        

        
        susdsynth.burn(fee_address, susdamount);

        
        susdsynth.issue(account, susdamount);
    }

    
    function _payrewards(address account, uint snxamount) internal notfeeaddress(account) {
        require(account != address(0), );
        require(account != address(this), );
        require(account != address(proxy), );
        require(account != address(synthetix()), );

        
        
        rewardescrow().appendvestingentry(account, snxamount);
    }

    
    function amountreceivedfromtransfer(uint value) external pure returns (uint) {
        return value;
    }

    
    function exchangefeeincurred(uint value) public view returns (uint) {
        return value.multiplydecimal(exchangefeerate);

        
        
        
        
        
        
        
    }

    
    function amountreceivedfromexchange(uint value) external view returns (uint) {
        return value.multiplydecimal(safedecimalmath.unit().sub(exchangefeerate));
    }

    
    function totalfeesavailable() external view returns (uint) {
        uint totalfees = 0;

        
        for (uint i = 1; i < fee_period_length; i++) {
            totalfees = totalfees.add(_recentfeeperiodsstorage(i).feestodistribute);
            totalfees = totalfees.sub(_recentfeeperiodsstorage(i).feesclaimed);
        }

        return totalfees;
    }

    
    function totalrewardsavailable() external view returns (uint) {
        uint totalrewards = 0;

        
        for (uint i = 1; i < fee_period_length; i++) {
            totalrewards = totalrewards.add(_recentfeeperiodsstorage(i).rewardstodistribute);
            totalrewards = totalrewards.sub(_recentfeeperiodsstorage(i).rewardsclaimed);
        }

        return totalrewards;
    }

    
    function feesavailable(address account) public view returns (uint, uint) {
        
        uint[2][fee_period_length] memory userfees = feesbyperiod(account);

        uint totalfees = 0;
        uint totalrewards = 0;

        
        for (uint i = 1; i < fee_period_length; i++) {
            totalfees = totalfees.add(userfees[i][0]);
            totalrewards = totalrewards.add(userfees[i][1]);
        }

        
        
        return (totalfees, totalrewards);
    }

    
    function isfeesclaimable(address account) public view returns (bool) {
        
        
        
        uint ratio = synthetix().collateralisationratio(account);
        uint targetratio = synthetixstate().issuanceratio();

        
        if (ratio < targetratio) {
            return true;
        }

        
        uint ratio_threshold = targetratio.multiplydecimal(safedecimalmath.unit().add(targetthreshold));

        
        if (ratio > ratio_threshold) {
            return false;
        }

        return true;
    }

    
    function feesbyperiod(address account) public view returns (uint[2][fee_period_length] memory results) {
        
        uint userownershippercentage;
        uint debtentryindex;
        feepoolstate _feepoolstate = feepoolstate();

        (userownershippercentage, debtentryindex) = _feepoolstate.getaccountsdebtentry(account, 0);

        
        
        
        if (debtentryindex == 0 && userownershippercentage == 0) return;

        
        
        uint feesfromperiod;
        uint rewardsfromperiod;
        (feesfromperiod, rewardsfromperiod) = _feesandrewardsfromperiod(0, userownershippercentage, debtentryindex);

        results[0][0] = feesfromperiod;
        results[0][1] = rewardsfromperiod;

        
        uint lastfeewithdrawal = getlastfeewithdrawal(account);

        
        
        for (uint i = fee_period_length  1; i > 0; i) {
            uint next = i  1;
            uint nextperiodstartingdebtindex = _recentfeeperiodsstorage(next).startingdebtindex;

            
            if (nextperiodstartingdebtindex > 0 && lastfeewithdrawal < _recentfeeperiodsstorage(i).feeperiodid) {
                
                
                
                uint closingdebtindex = uint256(nextperiodstartingdebtindex).sub(1);

                
                
                
                (userownershippercentage, debtentryindex) = _feepoolstate.applicableissuancedata(account, closingdebtindex);

                (feesfromperiod, rewardsfromperiod) = _feesandrewardsfromperiod(i, userownershippercentage, debtentryindex);

                results[i][0] = feesfromperiod;
                results[i][1] = rewardsfromperiod;
            }
        }
    }

    
    function _feesandrewardsfromperiod(uint period, uint ownershippercentage, uint debtentryindex)
        internal
        view
        returns (uint, uint)
    {
        
        if (ownershippercentage == 0) return (0, 0);

        uint debtownershipforperiod = ownershippercentage;

        
        if (period > 0) {
            uint closingdebtindex = uint256(_recentfeeperiodsstorage(period  1).startingdebtindex).sub(1);
            debtownershipforperiod = _effectivedebtratioforperiod(closingdebtindex, ownershippercentage, debtentryindex);
        }

        
        
        uint feesfromperiod = _recentfeeperiodsstorage(period).feestodistribute.multiplydecimal(debtownershipforperiod);

        uint rewardsfromperiod = _recentfeeperiodsstorage(period).rewardstodistribute.multiplydecimal(
            debtownershipforperiod
        );

        return (feesfromperiod.precisedecimaltodecimal(), rewardsfromperiod.precisedecimaltodecimal());
    }

    function _effectivedebtratioforperiod(uint closingdebtindex, uint ownershippercentage, uint debtentryindex)
        internal
        view
        returns (uint)
    {
        
        
        isynthetixstate _synthetixstate = synthetixstate();
        uint feeperioddebtownership = _synthetixstate
            .debtledger(closingdebtindex)
            .dividedecimalroundprecise(_synthetixstate.debtledger(debtentryindex))
            .multiplydecimalroundprecise(ownershippercentage);

        return feeperioddebtownership;
    }

    function effectivedebtratioforperiod(address account, uint period) external view returns (uint) {
        require(period != 0, );
        require(period < fee_period_length, );

        
        if (_recentfeeperiodsstorage(period  1).startingdebtindex == 0) return 0;

        uint closingdebtindex = uint256(_recentfeeperiodsstorage(period  1).startingdebtindex).sub(1);

        uint ownershippercentage;
        uint debtentryindex;
        (ownershippercentage, debtentryindex) = feepoolstate().applicableissuancedata(account, closingdebtindex);

        
        return _effectivedebtratioforperiod(closingdebtindex, ownershippercentage, debtentryindex);
    }

    
    function getlastfeewithdrawal(address _claimingaddress) public view returns (uint) {
        return feepooleternalstorage().getuintvalue(keccak256(abi.encodepacked(last_fee_withdrawal, _claimingaddress)));
    }

    
    function getpenaltythresholdratio() public view returns (uint) {
        uint targetratio = synthetixstate().issuanceratio();

        return targetratio.multiplydecimal(safedecimalmath.unit().add(targetthreshold));
    }

    
    function _setlastfeewithdrawal(address _claimingaddress, uint _feeperiodid) internal {
        feepooleternalstorage().setuintvalue(
            keccak256(abi.encodepacked(last_fee_withdrawal, _claimingaddress)),
            _feeperiodid
        );
    }

    
    modifier onlyexchangerorsynth {
        bool isexchanger = msg.sender == address(exchanger());
        bool issynth = synthetix().synthsbyaddress(msg.sender) != bytes32(0);

        require(isexchanger || issynth, );
        _;
    }

    modifier onlyissuer {
        require(msg.sender == address(issuer()), );
        _;
    }

    modifier onlyexchanger {
        require(msg.sender == address(exchanger()), );
        _;
    }

    modifier notfeeaddress(address account) {
        require(account != fee_address, );
        _;
    }

    

    event issuancedebtratioentry(
        address indexed account,
        uint debtratio,
        uint debtentryindex,
        uint feeperiodstartingdebtindex
    );
    bytes32 private constant issuancedebtratioentry_sig = keccak256(
        
    );

    function emitissuancedebtratioentry(
        address account,
        uint debtratio,
        uint debtentryindex,
        uint feeperiodstartingdebtindex
    ) internal {
        proxy._emit(
            abi.encode(debtratio, debtentryindex, feeperiodstartingdebtindex),
            2,
            issuancedebtratioentry_sig,
            bytes32(account),
            0,
            0
        );
    }

    event exchangefeeupdated(uint newfeerate);
    bytes32 private constant exchangefeeupdated_sig = keccak256();

    function emitexchangefeeupdated(uint newfeerate) internal {
        proxy._emit(abi.encode(newfeerate), 1, exchangefeeupdated_sig, 0, 0, 0);
    }

    event feeperioddurationupdated(uint newfeeperiodduration);
    bytes32 private constant feeperioddurationupdated_sig = keccak256();

    function emitfeeperioddurationupdated(uint newfeeperiodduration) internal {
        proxy._emit(abi.encode(newfeeperiodduration), 1, feeperioddurationupdated_sig, 0, 0, 0);
    }

    event feeperiodclosed(uint feeperiodid);
    bytes32 private constant feeperiodclosed_sig = keccak256();

    function emitfeeperiodclosed(uint feeperiodid) internal {
        proxy._emit(abi.encode(feeperiodid), 1, feeperiodclosed_sig, 0, 0, 0);
    }

    event feesclaimed(address account, uint susdamount, uint snxrewards);
    bytes32 private constant feesclaimed_sig = keccak256();

    function emitfeesclaimed(address account, uint susdamount, uint snxrewards) internal {
        proxy._emit(abi.encode(account, susdamount, snxrewards), 1, feesclaimed_sig, 0, 0, 0);
    }
}
