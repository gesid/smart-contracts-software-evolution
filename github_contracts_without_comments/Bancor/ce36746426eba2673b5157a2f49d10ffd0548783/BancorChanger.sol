pragma solidity ^0.4.10;
import ;
import ;
import ;
import ;





contract smarttoken {
    function totalsupply() public constant returns (uint256 totalsupply);

    function issue(address _to, uint256 _amount) public returns (bool success);
    function destroy(address _from, uint256 _amount) public returns (bool success);
    function setchanger(address _changer, bool _disabletransfers) public returns (bool success);
}

contract bancorformula {
    function calculatepurchasereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _depositamount) public constant returns (uint256 amount);
    function calculatesalereturn(uint256 _supply, uint256 _reservebalance, uint16 _reserveratio, uint256 _sellamount) public constant returns (uint256 amount);
    function newformula() public constant returns (address newformula);
}

contract bancorevents is bancoreventsinterface {
    function tokenchange(address _fromtoken, address _totoken, address _changer, uint256 _amount, uint256 _return) public;
}


contract bancorchanger is owned, tokenchangerinterface {
    struct reserve {
        uint8 ratio;    
        bool isenabled; 
        bool isset;     
    }

    address public token = 0x0;                     
    address public formula = 0x0;                   
    address public events = 0x0;                    
    bool public isactive = false;                   
    address[] public reservetokens;                 
    mapping (address => reserve) public reserves;   
    uint8 private totalreserveratio = 0;            

    
    event change(address indexed _fromtoken, address indexed _totoken, address indexed _changer, uint256 _amount, uint256 _return);

    
    function bancorchanger(address _token, address _formula, address _events)
        validaddress(_token)
        validaddress(_formula)
    {
        token = _token;
        formula = _formula;
        events = _events;
    }

    
    modifier validaddress(address _address) {
        assert(_address != 0x0);
        _;
    }

    
    modifier validreserve(address _address) {
        assert(reserves[_address].isset);
        _;
    }

    
    modifier validtoken(address _address) {
        assert(_address == token || reserves[_address].isset);
        _;
    }

    
    modifier activeonly() {
        assert(isactive);
        _;
    }

    
    function setformula(address _formula) public owneronly returns (bool success) {
        bancorformula formulacontract = bancorformula(formula);
        require(_formula == formulacontract.newformula());
        formula = _formula;
        return true;
    }

    
    function reservetokencount() public constant returns (uint16 count) {
        return uint16(reservetokens.length);
    }

    
    function changeabletokencount() public constant returns (uint16 count) {
        return reservetokencount() + 1;
    }

    
    function changeabletoken(uint16 _tokenindex) public constant returns (address tokenaddress) {
        if (_tokenindex == 0)
            return token;
        return reservetokens[_tokenindex  1];
    }

    
    function addreserve(address _token, uint8 _ratio) public owneronly returns (bool success) {
        require(_token != address(this) && _token != token && !reserves[_token].isset && _ratio > 0 && _ratio <= 100 && totalreserveratio + _ratio <= 100); 

        reserves[_token].ratio = _ratio;
        reserves[_token].isenabled = true;
        reserves[_token].isset = true;
        reservetokens.push(_token);
        totalreserveratio += _ratio;
        return true;
    }

    
    function withdraw(address _reservetoken, address _to, uint256 _amount) public owneronly returns (bool success) {
        require(reserves[_reservetoken].isset && _amount != 0); 
        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        return reservetoken.transfer(_to, _amount);
    }

    
    function disablereserve(address _reservetoken, bool _disable)
        public
        owneronly
        validreserve(_reservetoken)
    {
        reserves[_reservetoken].isenabled = !_disable;
    }

    
    function activate() public owneronly returns (bool success) {
        smarttoken maintoken = smarttoken(token);
        assert(maintoken.totalsupply() != 0 && reservetokens.length > 0); 
        isactive = true;
        return true;
    }

    
    function getreturn(address _fromtoken, address _totoken, uint256 _amount)
        public
        constant
        validtoken(_fromtoken)
        validtoken(_totoken)
        returns (uint256 amount)
    {
        require(_fromtoken != _totoken); 

        
        if (_totoken == token)
            return getpurchasereturn(_fromtoken, _amount);
        else if (_fromtoken == token)
            return getsalereturn(_totoken, _amount);

        
        uint256 tempamount = getpurchasereturn(_fromtoken, _amount);
        return getsalereturn(_totoken, tempamount);
    }

    
    function change(address _fromtoken, address _totoken, uint256 _amount, uint256 _minreturn)
        public
        validtoken(_fromtoken)
        validtoken(_totoken)
        returns (uint256 amount)
    {
        require(_fromtoken != _totoken); 

        
        if (_totoken == token)
            return buy(_fromtoken, _amount, _minreturn);
        else if (_fromtoken == token)
            return sell(_totoken, _amount, _minreturn);

        
        uint256 tempamount = buy(_fromtoken, _amount, 0);
        return sell(_totoken, tempamount, _minreturn);
    }

    
    function getpurchasereturn(address _reservetoken, uint256 _depositamount)
        public
        constant
        activeonly
        validreserve(_reservetoken)
        returns (uint256 amount)
    {
        reserve reserve = reserves[_reservetoken];
        require(reserve.isenabled && _depositamount != 0); 

        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);
        assert(reservebalance != 0); 

        erc20tokeninterface maintoken = erc20tokeninterface(token);
        uint256 mainsupply = maintoken.totalsupply();
        bancorformula formulacontract = bancorformula(formula);
        return formulacontract.calculatepurchasereturn(mainsupply, reservebalance, reserve.ratio, _depositamount);
    }

    
    function getsalereturn(address _reservetoken, uint256 _sellamount)
        public
        constant
        activeonly
        validreserve(_reservetoken)
        returns (uint256 amount)
    {
        erc20tokeninterface maintoken = erc20tokeninterface(token);
        require(_sellamount != 0 && _sellamount <= maintoken.balanceof(msg.sender)); 

        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);
        assert(reservebalance != 0); 
        
        uint256 mainsupply = maintoken.totalsupply();
        reserve reserve = reserves[_reservetoken];
        bancorformula formulacontract = bancorformula(formula);
        return formulacontract.calculatesalereturn(mainsupply, reservebalance, reserve.ratio, _sellamount);
    }

    
    function buy(address _reservetoken, uint256 _depositamount, uint256 _minreturn) public returns (uint256 amount) {
        amount = getpurchasereturn(_reservetoken, _depositamount);
        assert(amount != 0 && amount >= _minreturn); 

        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        assert(reservetoken.transferfrom(msg.sender, this, _depositamount)); 

        smarttoken maintoken = smarttoken(token);
        assert(maintoken.issue(msg.sender, amount)); 
        dispatchchange(_reservetoken, token, msg.sender, _depositamount, amount);
        return amount;
    }

    
    function sell(address _reservetoken, uint256 _sellamount, uint256 _minreturn) public returns (uint256 amount) {
        amount = getsalereturn(_reservetoken, _sellamount);
        assert(amount != 0 && amount >= _minreturn); 
        
        erc20tokeninterface reservetoken = erc20tokeninterface(_reservetoken);
        uint256 reservebalance = reservetoken.balanceof(this);
        assert(amount < reservebalance); 

        smarttoken maintoken = smarttoken(token);
        assert(maintoken.destroy(msg.sender, _sellamount)); 
        assert(reservetoken.transfer(msg.sender, amount)); 

        dispatchchange(this, _reservetoken, msg.sender, _sellamount, amount);

        
        if (maintoken.totalsupply() == 0)
            maintoken.setchanger(0x0, false);

        return amount;
    }

    

    function dispatchchange(address _fromtoken, address _totoken, address _changer, uint256 _amount, uint256 _return) private {
        change(_fromtoken, _totoken, _changer, _amount, _return);
        if (events == 0x0)
            return;

        bancoreventsinterface eventscontract = bancoreventsinterface(events);
        eventscontract.tokenchange(_fromtoken, _totoken, _changer, _amount, _return);
    }

    
    function() {
        assert(false);
    }
}
