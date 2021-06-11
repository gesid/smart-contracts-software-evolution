


pragma solidity ^0.4.19



contract havvenconfig {

    string public        name               = ;
    string public        symbol             = ;

    address public       owner              = msg.sender;
    address public       fund_wallet        = 0x0;

    uint public constant max_tokens         = 150000000;
    uint public constant start_date         = 1517443200;
    uint public constant max_funding_period = 60 days;

    
    
    
    
 

}

library safemath {

    
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        assert(c >= a);
    }

    
    function sub(uint a, uint b) internal pure returns (uint c) {
        c = a  b;
        assert(c <= a);
    }

    
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        assert(a == 0 || c / a == b);
    }

    
    function div(uint a, uint b) internal pure returns (uint c) {
        assert(b != 0);
        c = a / b;
    }
}


contract erc20token {

    using safemath for uint;





    uint public totalsupply;
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
 


 
    event transfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );

    event approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );




    
    function balanceof(address _addr)
        public
        view
        returns (uint)
    {
        return balances[_addr];
    }

    
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint)
    {
        return allowed[_owner][_spender];
    }

    
    function transfer(address _to, uint256 _amount)
        public
        returns (bool)
    {
        return xfer(msg.sender, _to, _amount);
    }

    
    function transferfrom(address _from, address _to, uint256 _amount)
        public
        returns (bool)
    {
        require(_amount <= allowed[_from][msg.sender]);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        return xfer(_from, _to, _amount);
    }

    
    function xfer(address _from, address _to, uint _amount)
        internal
        returns (bool)
    {
        require(_amount <= balances[_from]);

        transfer(_from, _to, _amount);

        
        if(_amount == 0) return true;

        balances[_from] = balances[_from].sub(_amount);
        balances[_to]   = balances[_to].add(_amount);

        return true;
    }

    
    function approve(address _spender, uint256 _amount)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _amount;
        approval(msg.sender, _spender, _amount);
        return true;
    }
}

contract havventokensaleabstract {




    event deposit(address indexed _from, uint _value);
    event withdrawal(address indexed _from, address indexed _to, uint _value);
    event ownerchangecomplete(address indexed _from, address indexed _to);
    event ownerchangeinit(address indexed _to); 
    event contractaborted();
    
    
    
    
    

    
    
    
    





    
    
    bool public __abortfuse = true;

    
    
    
    bool public tssucceeded;

    
    
    address public owner;

    
    
    address public newowner;

    
    
    uint public etherraised;

    
    uint public wholesaleleft;

    
    uint public refunded;

    
    uint public nextreleasedate;

    
    mapping (address => uint) public ethercontributed;

    
    mapping (address => bool) public mustkyc;




    modifier onlyowner() {
        require(msg.sender == owner);
        _;
    }




    
    function fundraised() public view returns (bool);

    
    
    function fundfailed() public view returns (bool);

    
    function currentrate() public view returns (uint);

    
    
    
    function ethtotokens(uint _wei)
        public view returns (uint alltokens_, uint wholesaletokens_);

    
    
    
    
    function proxypurchase(address _addr) public payable returns (bool);

    
    
    function finalizets() public returns (bool);

    
    
    function clearkyc(address[] _addrs) public returns (bool);

    
    
    
    
    function transfertomany(address[] _addrs, uint[] _amounts)
        public returns (bool);

    
    
    function releasevested() public returns (bool);

    
    
    function refund() public returns (bool);

    
    
    
    function refundfor(address[] _addrs) public returns (bool);

    
    function abort() public returns (bool);

    
    
    
    
    
    function transferexternaltoken(address _kaddr, address _to, uint _amount)
        public returns (bool);

}
