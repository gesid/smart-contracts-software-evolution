pragma solidity 0.4.25;

import ;
import ;
import ;
import ;
import ;
import ;

contract synth is externstatetoken, mixinresolver {
    

    
    bytes32 public currencykey;

    uint8 public constant decimals = 18;

    
    address public constant fee_address = 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef;

    

    constructor(
        address _proxy,
        tokenstate _tokenstate,
        string _tokenname,
        string _tokensymbol,
        address _owner,
        bytes32 _currencykey,
        uint _totalsupply,
        address _resolver
    )
        public
        externstatetoken(_proxy, _tokenstate, _tokenname, _tokensymbol, _totalsupply, decimals, _owner)
        mixinresolver(_owner, _resolver)
    {
        require(_proxy != address(0), );
        require(_owner != 0, );

        currencykey = _currencykey;
    }

    

    function transfer(address to, uint value) public optionalproxy returns (bool) {
        _ensurecantransfer(messagesender, value);

        
        if (to == fee_address) {
            return _transfertofeeaddress(to, value);
        }

        return super._internaltransfer(messagesender, to, value);
    }

    function transferandsettle(address to, uint value) public optionalproxy returns (bool) {
        exchanger().settle(messagesender, currencykey);

        
        uint balanceafter = tokenstate.balanceof(messagesender);

        
        value = value > balanceafter ? balanceafter : value;

        return super._internaltransfer(messagesender, to, value);
    }

    function transferfrom(address from, address to, uint value) public optionalproxy returns (bool) {
        _ensurecantransfer(from, value);

        return _internaltransferfrom(from, to, value);
    }

    function transferfromandsettle(address from, address to, uint value) public optionalproxy returns (bool) {
        exchanger().settle(from, currencykey);

        
        uint balanceafter = tokenstate.balanceof(from);

        
        value = value >= balanceafter ? balanceafter : value;

        return _internaltransferfrom(from, to, value);
    }

    
    function _transfertofeeaddress(address to, uint value) internal returns (bool) {
        uint amountinusd;

        
        if (currencykey == ) {
            amountinusd = value;
            super._internaltransfer(messagesender, to, value);
        } else {
            
            amountinusd = exchanger().exchange(messagesender, currencykey, value, , fee_address);
        }

        
        feepool().recordfeepaid(amountinusd);

        return true;
    }

    
    
    function issue(address account, uint amount) external onlyinternalcontracts {
        _internalissue(account, amount);
    }

    
    
    function burn(address account, uint amount) external onlyinternalcontracts {
        _internalburn(account, amount);
    }

    function _internalissue(address account, uint amount) internal {
        tokenstate.setbalanceof(account, tokenstate.balanceof(account).add(amount));
        totalsupply = totalsupply.add(amount);
        emittransfer(address(0), account, amount);
        emitissued(account, amount);
    }

    function _internalburn(address account, uint amount) internal {
        tokenstate.setbalanceof(account, tokenstate.balanceof(account).sub(amount));
        totalsupply = totalsupply.sub(amount);
        emittransfer(account, address(0), amount);
        emitburned(account, amount);
    }

    
    function settotalsupply(uint amount) external optionalproxy_onlyowner {
        totalsupply = amount;
    }

    
    function synthetix() internal view returns (isynthetix) {
        return isynthetix(resolver.requireandgetaddress(, ));
    }

    function feepool() internal view returns (ifeepool) {
        return ifeepool(resolver.requireandgetaddress(, ));
    }

    function exchanger() internal view returns (iexchanger) {
        return iexchanger(resolver.requireandgetaddress(, ));
    }

    function issuer() internal view returns (iissuer) {
        return iissuer(resolver.requireandgetaddress(, ));
    }

    function _ensurecantransfer(address from, uint value) internal view {
        require(exchanger().maxsecsleftinwaitingperiod(from, currencykey) == 0, );
        require(transferablesynths(from) >= value, );
    }

    function transferablesynths(address account) public view returns (uint) {
        (uint reclaimamount, ) = exchanger().settlementowing(account, currencykey);

        
        

        uint balance = tokenstate.balanceof(account);

        if (reclaimamount > balance) {
            return 0;
        } else {
            return balance.sub(reclaimamount);
        }
    }

    

    function _internaltransferfrom(address from, address to, uint value) internal returns (bool) {
        
        if (tokenstate.allowance(from, messagesender) != uint(1)) {
            
            
            tokenstate.setallowance(from, messagesender, tokenstate.allowance(from, messagesender).sub(value));
        }

        return super._internaltransfer(from, to, value);
    }

    

    modifier onlyinternalcontracts() {
        bool issynthetix = msg.sender == address(synthetix());
        bool isfeepool = msg.sender == address(feepool());
        bool isexchanger = msg.sender == address(exchanger());
        bool isissuer = msg.sender == address(issuer());

        require(
            issynthetix || isfeepool || isexchanger || isissuer,
            
        );
        _;
    }

    
    event issued(address indexed account, uint value);
    bytes32 private constant issued_sig = keccak256();

    function emitissued(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, issued_sig, bytes32(account), 0, 0);
    }

    event burned(address indexed account, uint value);
    bytes32 private constant burned_sig = keccak256();

    function emitburned(address account, uint value) internal {
        proxy._emit(abi.encode(value), 2, burned_sig, bytes32(account), 0, 0);
    }
}
