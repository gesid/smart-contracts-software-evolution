

pragma solidity >=0.4.10;


contract safemath {
    function safemul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function safesub(uint a, uint b) internal returns (uint) {
        require(b <= a);
        return a  b;
    }

    function safeadd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        require(c>=a && c>=b);
        return c;
    }
}

contract owned {
    address public owner;
    address newowner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }

    function changeowner(address _newowner) onlyowner {
        newowner = _newowner;
    }

    function acceptownership() {
        if (msg.sender == newowner) {
            owner = newowner;
        }
    }
}

contract itoken {
    function transfer(address _to, uint _value) returns (bool);
    function balanceof(address owner) returns(uint);
}



contract tokenreceivable is owned {
    function claimtokens(address _token, address _to) onlyowner returns (bool) {
        itoken token = itoken(_token);
        return token.transfer(_to, token.balanceof(this));
    }
}

contract eventdefinitions {
    event transfer(address indexed from, address indexed to, uint value);
    event approval(address indexed owner, address indexed spender, uint value);
    event burn(address indexed from, bytes32 indexed to, uint value);
    event claimed(address indexed claimer, uint value);
}

contract pausable is owned {
    bool public paused;

    function pause() onlyowner {
        paused = true;
    }

    function unpause() onlyowner {
        paused = false;
    }

    modifier notpaused() {
        require(!paused);
        _;
    }
}

contract finalizable is owned {
    bool public finalized;

    function finalize() onlyowner {
        finalized = true;
    }

    modifier notfinalized() {
        require(!finalized);
        _;
    }
}

contract ledger is owned, safemath, finalizable {
    controller public controller;
    mapping(address => uint) public balanceof;
    mapping (address => mapping (address => uint)) public allowance;
    uint public totalsupply;
    uint public mintingnonce;
    bool public mintingstopped;

    
    mapping(uint256 => bytes32) public proofs;

    
    mapping(address => uint256) public locked;

    
    mapping(bytes32 => bytes32) public metadata;

    
    address public burnaddress;

    
    mapping(address => bool) public bridgenodes;

    

    function ledger() {
    }

    function setcontroller(address _controller) onlyowner notfinalized {
        controller = controller(_controller);
    }

    
    function stopminting() onlyowner {
        mintingstopped = true;
    }

    
    function multimint(uint nonce, uint256[] bits) onlyowner {
        require(!mintingstopped);
        if (nonce != mintingnonce) return;
        mintingnonce += 1;
        uint256 lomask = (1 << 96)  1;
        uint created = 0;
        for (uint i=0; i<bits.length; i++) {
            address a = address(bits[i]>>96);
            uint value = bits[i]&lomask;
            balanceof[a] = balanceof[a] + value;
            controller.ledgertransfer(0, a, value);
            created += value;
        }
        totalsupply += created;
    }

    

    modifier onlycontroller() {
        require(msg.sender == address(controller));
        _;
    }

    function transfer(address _from, address _to, uint _value) onlycontroller returns (bool success) {
        if (balanceof[_from] < _value) return false;

        balanceof[_from] = safesub(balanceof[_from], _value);
        balanceof[_to] = safeadd(balanceof[_to], _value);
        return true;
    }

    function transferfrom(address _spender, address _from, address _to, uint _value) onlycontroller returns (bool success) {
        if (balanceof[_from] < _value) return false;

        var allowed = allowance[_from][_spender];
        if (allowed < _value) return false;

        balanceof[_to] = safeadd(balanceof[_to], _value);
        balanceof[_from] = safesub(balanceof[_from], _value);
        allowance[_from][_spender] = safesub(allowed, _value);
        return true;
    }

    function approve(address _owner, address _spender, uint _value) onlycontroller returns (bool success) {
        
        if ((_value != 0) && (allowance[_owner][_spender] != 0)) {
            return false;
        }

        allowance[_owner][_spender] = _value;
        return true;
    }

    function increaseapproval (address _owner, address _spender, uint _addedvalue) onlycontroller returns (bool success) {
        uint oldvalue = allowance[_owner][_spender];
        allowance[_owner][_spender] = safeadd(oldvalue, _addedvalue);
        return true;
    }

    function decreaseapproval (address _owner, address _spender, uint _subtractedvalue) onlycontroller returns (bool success) {
        uint oldvalue = allowance[_owner][_spender];
        if (_subtractedvalue > oldvalue) {
            allowance[_owner][_spender] = 0;
        } else {
            allowance[_owner][_spender] = safesub(oldvalue, _subtractedvalue);
        }
        return true;
    }

    function setproof(uint256 _key, bytes32 _proof) onlycontroller {
        proofs[_key] = _proof;
    }

    function setlocked(address _key, uint256 _value) onlycontroller {
        locked[_key] = _value;
    }

    function setmetadata(bytes32 _key, bytes32 _value) onlycontroller {
        metadata[_key] = _value;
    }

    

    
    function setburnaddress(address _address) onlycontroller {
        burnaddress = _address;
    }

    function setbridgenode(address _address, bool enabled) onlycontroller {
        bridgenodes[_address] = enabled;
    }
}

contract controllereventdefinitions {
    
    event controllerburn(address indexed from, bytes32 indexed to, uint value);
}


contract controller is owned, finalizable, controllereventdefinitions {
    ledger public ledger;
    token public token;
    address public burnaddress;

    function controller() {
    }

    


    function settoken(address _token) onlyowner {
        token = token(_token);
    }

    function setledger(address _ledger) onlyowner {
        ledger = ledger(_ledger);
    }

    
    function setburnaddress(address _address) onlyowner {
        burnaddress = _address;
        ledger.setburnaddress(_address);
        token.setburnaddress(_address);
    }

    modifier onlytoken() {
        require(msg.sender == address(token));
        _;
    }

    modifier onlyledger() {
        require(msg.sender == address(ledger));
        _;
    }

    function totalsupply() constant returns (uint) {
        return ledger.totalsupply();
    }

    function balanceof(address _a) constant returns (uint) {
        return ledger.balanceof(_a);
    }

    function allowance(address _owner, address _spender) constant returns (uint) {
        return ledger.allowance(_owner, _spender);
    }

    

    
    
    
    function ledgertransfer(address from, address to, uint val) onlyledger {
        token.controllertransfer(from, to, val);
    }

    

    function transfer(address _from, address _to, uint _value) onlytoken returns (bool success) {
        return ledger.transfer(_from, _to, _value);
    }

    function transferfrom(address _spender, address _from, address _to, uint _value) onlytoken returns (bool success) {
        return ledger.transferfrom(_spender, _from, _to, _value);
    }

    function approve(address _owner, address _spender, uint _value) onlytoken returns (bool success) {
        return ledger.approve(_owner, _spender, _value);
    }

    function increaseapproval (address _owner, address _spender, uint _addedvalue) onlytoken returns (bool success) {
        return ledger.increaseapproval(_owner, _spender, _addedvalue);
    }

    function decreaseapproval (address _owner, address _spender, uint _subtractedvalue) onlytoken returns (bool success) {
        return ledger.decreaseapproval(_owner, _spender, _subtractedvalue);
    }

    

    
    function enableburning() onlyowner {
        token.enableburning();
    }

    
    function disableburning() onlyowner {
        token.disableburning();
    }

    

     
    function burn(address _from, bytes32 _to, uint _amount) onlytoken returns (bool success) {
        if (ledger.transfer(_from, burnaddress, _amount)) {
            controllerburn(_from, _to, _amount);
            token.controllerburn(_from, _to, _amount);
            return true;
        }
        return false;
    }

    
    function claimbyproof(address _claimer, bytes32[] data, bytes32[] proofs, uint256 number)
        onlytoken
        returns (bool success) {
        return false;
    }

    
    function claim(address _claimer) onlytoken returns (bool success) {
        return false;
    }
}

contract token is finalizable, tokenreceivable, safemath, eventdefinitions, pausable {
    
    string constant public name = ;
    uint8 constant public decimals = 8;
    string constant public symbol = ;
    controller public controller;
    string public motd;
    event motd(string message);

    address public burnaddress; 
    bool public burnable = false;

    

    
    function setmotd(string _m) onlyowner {
        motd = _m;
        motd(_m);
    }

    function setcontroller(address _c) onlyowner notfinalized {
        controller = controller(_c);
    }

    

    function balanceof(address a) constant returns (uint) {
        return controller.balanceof(a);
    }

    function totalsupply() constant returns (uint) {
        return controller.totalsupply();
    }

    function allowance(address _owner, address _spender) constant returns (uint) {
        return controller.allowance(_owner, _spender);
    }

    function transfer(address _to, uint _value) notpaused returns (bool success) {
        if (controller.transfer(msg.sender, _to, _value)) {
            transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transferfrom(address _from, address _to, uint _value) notpaused returns (bool success) {
        if (controller.transferfrom(msg.sender, _from, _to, _value)) {
            transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint _value) notpaused returns (bool success) {
        
        if (controller.approve(msg.sender, _spender, _value)) {
            approval(msg.sender, _spender, _value);
            return true;
        }
        return false;
    }

    function increaseapproval (address _spender, uint _addedvalue) notpaused returns (bool success) {
        if (controller.increaseapproval(msg.sender, _spender, _addedvalue)) {
            uint newval = controller.allowance(msg.sender, _spender);
            approval(msg.sender, _spender, newval);
            return true;
        }
        return false;
    }

    function decreaseapproval (address _spender, uint _subtractedvalue) notpaused returns (bool success) {
        if (controller.decreaseapproval(msg.sender, _spender, _subtractedvalue)) {
            uint newval = controller.allowance(msg.sender, _spender);
            approval(msg.sender, _spender, newval);
            return true;
        }
        return false;
    }

    
    
    
    

    

    modifier onlycontroller() {
        assert(msg.sender == address(controller));
        _;
    }

    
    
    

    function controllertransfer(address _from, address _to, uint _value) onlycontroller {
        transfer(_from, _to, _value);
    }

    function controllerapprove(address _owner, address _spender, uint _value) onlycontroller {
        approval(_owner, _spender, _value);
    }

    
    function controllerburn(address _from, bytes32 _to, uint256 _value) onlycontroller {
        burn(_from, _to, _value);
    }

    function controllerclaim(address _claimer, uint256 _value) onlycontroller {
        claimed(_claimer, _value);
    }

    
    function setburnaddress(address _address) onlycontroller {
        burnaddress = _address;
    }

    
    function enableburning() onlycontroller {
        burnable = true;
    }

    
    function disableburning() onlycontroller {
        burnable = false;
    }

    
    modifier burnenabled() {
        require(burnable == true);
        _;
    }

    
    function burn(bytes32 _to, uint _amount) notpaused burnenabled returns (bool success) {
        return controller.burn(msg.sender, _to, _amount);
    }

    
    function claimbyproof(bytes32[] data, bytes32[] proofs, uint256 number) notpaused burnenabled returns (bool success) {
        return controller.claimbyproof(msg.sender, data, proofs, number);
    }

    
    function claim() notpaused burnenabled returns (bool success) {
        return controller.claim(msg.sender);
    }
}