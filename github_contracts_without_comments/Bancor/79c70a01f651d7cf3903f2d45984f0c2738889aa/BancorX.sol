
pragma solidity 0.6.12;
import ;
import ;
import ;
import ;
import ;
import ;


contract bancorx is ibancorx, tokenhandler, tokenholder, contractregistryclient {
    using safemath for uint256;

    
    struct transaction {
        uint256 amount;
        bytes32 fromblockchain;
        address to;
        uint8 numofreports;
        bool completed;
    }

    uint16 public constant version = 4;

    uint256 public maxlocklimit;            
    uint256 public maxreleaselimit;         
    uint256 public minlimit;                
    uint256 public prevlocklimit;           
    uint256 public prevreleaselimit;        
    uint256 public limitincperblock;        
    uint256 public prevlockblocknumber;     
    uint256 public prevreleaseblocknumber;  
    uint8 public minrequiredreports;        

    ierc20token public override token;      

    bool public xtransfersenabled = true;   
    bool public reportingenabled = true;    

    
    mapping (uint256 => transaction) public transactions;

    
    mapping (uint256 => uint256) public transactionids;

    
    mapping (uint256 => mapping (address => bool)) public reportedtxs;

    
    mapping (address => bool) public reporters;

    
    event tokenslock(
        address indexed _from,
        uint256 _amount
    );

    
    event tokensrelease(
        address indexed _to,
        uint256 _amount
    );

    
    event xtransfer(
        address indexed _from,
        bytes32 _toblockchain,
        bytes32 indexed _to,
        uint256 _amount,
        uint256 _id
    );

    
    event txreport(
        address indexed _reporter,
        bytes32 _fromblockchain,
        uint256 _txid,
        address _to,
        uint256 _amount,
        uint256 _xtransferid
    );

    
    event xtransfercomplete(
        address _to,
        uint256 _id
    );

    
    constructor(
        uint256 _maxlocklimit,
        uint256 _maxreleaselimit,
        uint256 _minlimit,
        uint256 _limitincperblock,
        uint8 _minrequiredreports,
        icontractregistry _registry,
        ierc20token _token
    )   contractregistryclient(_registry)
        public
        greaterthanzero(_maxlocklimit)
        greaterthanzero(_maxreleaselimit)
        greaterthanzero(_minlimit)
        greaterthanzero(_limitincperblock)
        greaterthanzero(_minrequiredreports)
        validaddress(address(_token))
        notthis(address(_token))
    {
        
        require(_minlimit <= _maxlocklimit && _minlimit <= _maxreleaselimit, );

        
        maxlocklimit = _maxlocklimit;
        maxreleaselimit = _maxreleaselimit;
        minlimit = _minlimit;
        limitincperblock = _limitincperblock;
        minrequiredreports = _minrequiredreports;

        
        prevlocklimit = _maxlocklimit;
        prevreleaselimit = _maxreleaselimit;
        prevlockblocknumber = block.number;
        prevreleaseblocknumber = block.number;

        token = _token;
    }

    
    modifier reporteronly {
        _reporteronly();
        _;
    }

    
    function _reporteronly() internal view {
        require(reporters[msg.sender], );
    }

    
    modifier xtransfersallowed {
        _xtransfersallowed();
        _;
    }

    
    function _xtransfersallowed() internal view {
        require(xtransfersenabled, );
    }

    
    modifier reportingallowed {
        _reportingallowed();
        _;
    }

    
    function _reportingallowed() internal view {
        require(reportingenabled, );
    }

    
    function setmaxlocklimit(uint256 _maxlocklimit) public owneronly greaterthanzero(_maxlocklimit) {
        maxlocklimit = _maxlocklimit;
    }

    
    function setmaxreleaselimit(uint256 _maxreleaselimit) public owneronly greaterthanzero(_maxreleaselimit) {
        maxreleaselimit = _maxreleaselimit;
    }

    
    function setminlimit(uint256 _minlimit) public owneronly greaterthanzero(_minlimit) {
        
        require(_minlimit <= maxlocklimit && _minlimit <= maxreleaselimit, );

        minlimit = _minlimit;
    }

    
    function setlimitincperblock(uint256 _limitincperblock) public owneronly greaterthanzero(_limitincperblock) {
        limitincperblock = _limitincperblock;
    }

    
    function setminrequiredreports(uint8 _minrequiredreports) public owneronly greaterthanzero(_minrequiredreports) {
        minrequiredreports = _minrequiredreports;
    }

    
    function setreporter(address _reporter, bool _active) public owneronly {
        reporters[_reporter] = _active;
    }

    
    function enablextransfers(bool _enable) public owneronly {
        xtransfersenabled = _enable;
    }

    
    function enablereporting(bool _enable) public owneronly {
        reportingenabled = _enable;
    }

    
    function upgrade(address[] memory _reporters) public owneronly {
        ibancorxupgrader bancorxupgrader = ibancorxupgrader(addressof(bancor_x_upgrader));

        transferownership(address(bancorxupgrader));
        bancorxupgrader.upgrade(version, _reporters);
        acceptownership();
    }

    
    function xtransfer(bytes32 _toblockchain, bytes32 _to, uint256 _amount) public xtransfersallowed {
        
        uint256 currentlocklimit = getcurrentlocklimit();

        
        require(_amount >= minlimit && _amount <= currentlocklimit, );

        locktokens(_amount);

        
        prevlocklimit = currentlocklimit.sub(_amount);
        prevlockblocknumber = block.number;

        
        emit xtransfer(msg.sender, _toblockchain, _to, _amount, 0);
    }

    
    function xtransfer(bytes32 _toblockchain, bytes32 _to, uint256 _amount, uint256 _id) public override xtransfersallowed {
        
        uint256 currentlocklimit = getcurrentlocklimit();

        
        require(_amount >= minlimit && _amount <= currentlocklimit, );

        locktokens(_amount);

        
        prevlocklimit = currentlocklimit.sub(_amount);
        prevlockblocknumber = block.number;

        
        emit xtransfer(msg.sender, _toblockchain, _to, _amount, _id);
    }

    
    function reporttx(
        bytes32 _fromblockchain,
        uint256 _txid,
        address _to,
        uint256 _amount,
        uint256 _xtransferid
    )
        public
        reporteronly
        reportingallowed
        validaddress(_to)
        greaterthanzero(_amount)
    {
        
        require(!reportedtxs[_txid][msg.sender], );

        
        reportedtxs[_txid][msg.sender] = true;

        transaction storage txn = transactions[_txid];

        
        if (txn.numofreports == 0) {
            txn.to = _to;
            txn.amount = _amount;
            txn.fromblockchain = _fromblockchain;

            if (_xtransferid != 0) {
                
                require(transactionids[_xtransferid] == 0, );
                transactionids[_xtransferid] = _txid;
            }
        }
        else {
            
            require(txn.to == _to && txn.amount == _amount && txn.fromblockchain == _fromblockchain, );

            if (_xtransferid != 0)
                require(transactionids[_xtransferid] == _txid, );
        }

        
        txn.numofreports++;

        emit txreport(msg.sender, _fromblockchain, _txid, _to, _amount, _xtransferid);

        
        if (txn.numofreports >= minrequiredreports) {
            require(!transactions[_txid].completed, );

            
            transactions[_txid].completed = true;

            emit xtransfercomplete(_to, _xtransferid);

            releasetokens(_to, _amount);
        }
    }

    
    function getxtransferamount(uint256 _xtransferid, address _for) public view override returns (uint256) {
        
        transaction memory transaction = transactions[transactionids[_xtransferid]];

        
        require(transaction.to == _for, );

        return transaction.amount;
    }

    
    function getcurrentlocklimit() public view returns (uint256) {
        
        uint256 currentlocklimit = prevlocklimit.add(((block.number).sub(prevlockblocknumber)).mul(limitincperblock));
        if (currentlocklimit > maxlocklimit)
            return maxlocklimit;
        return currentlocklimit;
    }

    
    function getcurrentreleaselimit() public view returns (uint256) {
        
        uint256 currentreleaselimit = prevreleaselimit.add(((block.number).sub(prevreleaseblocknumber)).mul(limitincperblock));
        if (currentreleaselimit > maxreleaselimit)
            return maxreleaselimit;
        return currentreleaselimit;
    }

    
    function locktokens(uint256 _amount) private {
        safetransferfrom(token, msg.sender, address(this), _amount);
        emit tokenslock(msg.sender, _amount);
    }

    
    function releasetokens(address _to, uint256 _amount) private {
        
        uint256 currentreleaselimit = getcurrentreleaselimit();

        require(_amount >= minlimit && _amount <= currentreleaselimit, );

        
        prevreleaselimit = currentreleaselimit.sub(_amount);
        prevreleaseblocknumber = block.number;

        
        safetransfer(token, _to, _amount);

        emit tokensrelease(_to, _amount);
    }
}
