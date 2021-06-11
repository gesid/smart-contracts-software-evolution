pragma solidity ^0.4.23;


import ;
import ;
import ;
import ;

import ;
import ;




contract estateregistry is migratable, iestateregistry, erc721token, erc721receiver, ownable, estatestorage {
  modifier cantransfer(uint256 estateid) {
    require(isapprovedorowner(msg.sender, estateid), );
    _;
  }

  modifier onlyregistry() {
    require(msg.sender == address(registry), );
    _;
  }

  modifier onlyupdateauthorized(uint256 estateid) {
    require(_isupdateauthorized(msg.sender, estateid), );
    _;
  }

  modifier onlylandupdateauthorized(uint256 estateid, uint256 landid) {
    require(_islandupdateauthorized(msg.sender, estateid, landid), );
    _;
  }

  modifier cansetupdateoperator(uint256 estateid) {
    address owner = ownerof(estateid);
    require(
      isapprovedorowner(msg.sender, estateid) || updatemanager[owner][msg.sender],
      
    );
    _;
  }

  
  function mint(address to, string metadata) external onlyregistry returns (uint256) {
    return _mintestate(to, metadata);
  }

  
  function transferland(
    uint256 estateid,
    uint256 landid,
    address destinatary
  )
    external
    cantransfer(estateid)
  {
    return _transferland(estateid, landid, destinatary);
  }

  
  function transfermanylands(
    uint256 estateid,
    uint256[] landids,
    address destinatary
  )
    external
    cantransfer(estateid)
  {
    uint length = landids.length;
    for (uint i = 0; i < length; i++) {
      _transferland(estateid, landids[i], destinatary);
    }
  }

  
  function getlandestateid(uint256 landid) external view returns (uint256) {
    return landidestate[landid];
  }

  function setlandregistry(address _registry) external onlyowner {
    require(_registry.iscontract(), );
    require(_registry != 0, );
    registry = landregistry(_registry);
    emit setlandregistry(registry);
  }

  function ping() external {
    registry.ping();
  }

  
  function getestatesize(uint256 estateid) external view returns (uint256) {
    return estatelandids[estateid].length;
  }

  
  function getlandssize(address _owner) public view returns (uint256) {
    
    uint256 landssize;
    uint256 balance = ownedtokenscount[_owner];
    for (uint256 i; i < balance; i++) {
      uint256 estateid = ownedtokens[_owner][i];
      landssize += estatelandids[estateid].length;
    }
    return landssize;
  }

  
  function updatemetadata(
    uint256 estateid,
    string metadata
  )
    external
    onlyupdateauthorized(estateid)
  {
    _updatemetadata(estateid, metadata);

    emit update(
      estateid,
      ownerof(estateid),
      msg.sender,
      metadata
    );
  }

  function getmetadata(uint256 estateid) external view returns (string) {
    return estatedata[estateid];
  }

  function isupdateauthorized(address operator, uint256 estateid) external view returns (bool) {
    return _isupdateauthorized(operator, estateid);
  }

  
  function setupdatemanager(address _owner, address _operator, bool _approved) external {
    require(_operator != msg.sender, );
    require(
      _owner == msg.sender
      || operatorapprovals[_owner][msg.sender],
      
    );

    updatemanager[_owner][_operator] = _approved;

    emit updatemanager(
      _owner,
      _operator,
      msg.sender,
      _approved
    );
  }

  
  function setupdateoperator(
    uint256 estateid,
    address operator
  )
    public
    cansetupdateoperator(estateid)
  {
    updateoperator[estateid] = operator;
    emit updateoperator(estateid, operator);
  }

  
  function setmanyupdateoperator(
    uint256[] _estateids,
    address _operator
  )
    public
  {
    for (uint i = 0; i < _estateids.length; i++) {
      setupdateoperator(_estateids[i], _operator);
    }
  }

  
  function setlandupdateoperator(
    uint256 estateid,
    uint256 landid,
    address operator
  )
    public
    cansetupdateoperator(estateid)
  {
    require(landidestate[landid] == estateid, );
    registry.setupdateoperator(landid, operator);
  }

 
  function setmanylandupdateoperator(
    uint256 _estateid,
    uint256[] _landids,
    address _operator
  )
    public
    cansetupdateoperator(_estateid)
  {
    for (uint i = 0; i < _landids.length; i++) {
      require(landidestate[_landids[i]] == _estateid, );
    }
    registry.setmanyupdateoperator(_landids, _operator);
  }

  function initialize(
    string _name,
    string _symbol,
    address _registry
  )
    public
    isinitializer(, )
  {
    require(_registry != 0, );

    erc721token.initialize(_name, _symbol);
    ownable.initialize(msg.sender);
    registry = landregistry(_registry);
  }

  
  function onerc721received(
    address _operator,
    address _from,
    uint256 _tokenid,
    bytes _data
  )
    public
    onlyregistry
    returns (bytes4)
  {
    uint256 estateid = _bytestouint(_data);
    _pushlandid(estateid, _tokenid);
    return erc721_received;
  }

  
  function getfingerprint(uint256 estateid)
    public
    view
    returns (bytes32 result)
  {
    result = keccak256(abi.encodepacked(, estateid));

    uint256 length = estatelandids[estateid].length;
    for (uint i = 0; i < length; i++) {
      result ^= keccak256(abi.encodepacked(estatelandids[estateid][i]));
    }
    return result;
  }

  
  function verifyfingerprint(uint256 estateid, bytes fingerprint) public view returns (bool) {
    return getfingerprint(estateid) == _bytestobytes32(fingerprint);
  }

  
  function safetransfermanyfrom(address from, address to, uint256[] estateids) public {
    safetransfermanyfrom(
      from,
      to,
      estateids,
      
    );
  }

  
  function safetransfermanyfrom(
    address from,
    address to,
    uint256[] estateids,
    bytes data
  )
    public
  {
    for (uint i = 0; i < estateids.length; i++) {
      safetransferfrom(
        from,
        to,
        estateids[i],
        data
      );
    }
  }

  
  function updatelanddata(uint256 estateid, uint256 landid, string data) public {
    _updatelanddata(estateid, landid, data);
  }

  
  function updatemanylanddata(uint256 estateid, uint256[] landids, string data) public {
    uint length = landids.length;
    for (uint i = 0; i < length; i++) {
      _updatelanddata(estateid, landids[i], data);
    }
  }

  function transferfrom(address _from, address _to, uint256 _tokenid)
  public
  {
    updateoperator[_tokenid] = address(0);
    _updateestatelandbalance(_from, _to, estatelandids[_tokenid].length);
    super.transferfrom(_from, _to, _tokenid);
  }

  
  function _supportsinterface(bytes4 _interfaceid) internal view returns (bool) {
    
    return super._supportsinterface(_interfaceid)
      || _interfaceid == interfaceid_getmetadata
      || _interfaceid == interfaceid_verifyfingerprint;
  }

  
  function _mintestate(address to, string metadata) internal returns (uint256) {
    require(to != address(0), );
    uint256 estateid = _getnewestateid();
    _mint(to, estateid);
    _updatemetadata(estateid, metadata);
    emit createestate(to, estateid, metadata);
    return estateid;
  }

  
  function _updatemetadata(uint256 estateid, string metadata) internal {
    estatedata[estateid] = metadata;
  }

  
  function _getnewestateid() internal view returns (uint256) {
    return totalsupply().add(1);
  }

  
  function _pushlandid(uint256 estateid, uint256 landid) internal {
    require(exists(estateid), );
    require(landidestate[landid] == 0, );
    require(registry.ownerof(landid) == address(this), );

    estatelandids[estateid].push(landid);

    landidestate[landid] = estateid;

    estatelandindex[estateid][landid] = estatelandids[estateid].length;

    address owner = ownerof(estateid);
    _updateestatelandbalance(address(registry), owner, 1);

    emit addland(estateid, landid);
  }

  
  function _transferland(
    uint256 estateid,
    uint256 landid,
    address destinatary
  )
    internal
  {
    require(destinatary != address(0), );

    uint256[] storage landids = estatelandids[estateid];
    mapping(uint256 => uint256) landindex = estatelandindex[estateid];

    
    require(landindex[landid] != 0, );

    uint lastindexinarray = landids.length.sub(1);

    
    uint indexinarray = landindex[landid].sub(1);

    
    uint temptokenid = landids[lastindexinarray];

    
    landindex[temptokenid] = indexinarray.add(1);
    landids[indexinarray] = temptokenid;

    
    delete landids[lastindexinarray];
    landids.length = lastindexinarray;

    
    landindex[landid] = 0;

    
    landidestate[landid] = 0;

    address owner = ownerof(estateid);
    _updateestatelandbalance(owner, address(registry), 1);

    registry.safetransferfrom(this, destinatary, landid);


    emit removeland(estateid, landid, destinatary);
  }

  function _isupdateauthorized(address operator, uint256 estateid) internal view returns (bool) {
    address owner = ownerof(estateid);

    return isapprovedorowner(operator, estateid)
      || updateoperator[estateid] == operator
      || updatemanager[owner][operator];
  }

  function _islandupdateauthorized(
    address operator,
    uint256 estateid,
    uint256 landid
  )
    internal returns (bool)
  {
    return _isupdateauthorized(operator, estateid) || registry.updateoperator(landid) == operator;
  }

  function _bytestouint(bytes b) internal pure returns (uint256) {
    return uint256(_bytestobytes32(b));
  }

  function _bytestobytes32(bytes b) internal pure returns (bytes32) {
    bytes32 out;

    for (uint i = 0; i < b.length; i++) {
      out |= bytes32(b[i] & 0xff) >> i.mul(8);
    }

    return out;
  }

  function _updatelanddata(
    uint256 estateid,
    uint256 landid,
    string data
  )
    internal
    onlylandupdateauthorized(estateid, landid)
  {
    require(landidestate[landid] == estateid, );
    int x;
    int y;
    (x, y) = registry.decodetokenid(landid);
    registry.updatelanddata(x, y, data);
  }

  
  function _setestatelandbalancetoken(address _newestatelandbalance) internal {
    require(_newestatelandbalance != address(0), );
    emit setestatelandbalancetoken(estatelandbalance, _newestatelandbalance);
    estatelandbalance = iminimetoken(_newestatelandbalance);
  }

   
  function registerbalance() external {
    require(!registeredbalance[msg.sender], );

    
    uint256 currentbalance = estatelandbalance.balanceof(msg.sender);
    if (currentbalance > 0) {
      require(
        estatelandbalance.destroytokens(msg.sender, currentbalance),
        
      );
    }

    
    registeredbalance[msg.sender] = true;

    
    uint256 newbalance = getlandssize(msg.sender);

    
    require(
      estatelandbalance.generatetokens(msg.sender, newbalance),
      
    );
  }

  
  function unregisterbalance() external {
    require(registeredbalance[msg.sender], );

    
    registeredbalance[msg.sender] = false;

    
    uint256 currentbalance = estatelandbalance.balanceof(msg.sender);

    
    require(
      estatelandbalance.destroytokens(msg.sender, currentbalance),
      
    );
  }

  
  function _updateestatelandbalance(address _from, address _to, uint256 _amount) internal {
    if (registeredbalance[_from]) {
      estatelandbalance.destroytokens(_from, _amount);
    }

    if (registeredbalance[_to]) {
      estatelandbalance.generatetokens(_to, _amount);
    }
  }
}
