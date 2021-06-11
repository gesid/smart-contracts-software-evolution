pragma solidity ^0.4.8;


import ;
import ;

contract irrevocablevestedtoken is erc20, safemath {
  struct tokengrant {
    address granter;
    uint256 value;
    uint64 cliff;
    uint64 vesting;
    uint64 start;
  }

  mapping (address => tokengrant[]) public grants;

  mapping (address => bool) public disabledgrants;

  modifier cantransfer(address _sender, uint _value) {
    if (_value > spendablebalanceof(_sender)) throw;
    _;
  }

  
  function transfer(address _to, uint _value)
           cantransfer(msg.sender, _value)
          returns (bool success) {

    return super.transfer(_to, _value);
  }

  function transferfrom(address _from, address _to, uint _value)
           cantransfer(_from, _value)
           returns (bool success) {
    return super.transferfrom(_from, _to, _value);
  }

  function spendablebalanceof(address _holder) constant public returns (uint) {
    return transferabletokens(_holder, uint64(now));
  }

  
  function setvestedgrantsdisabled(bool disabled) public {
    disabledgrants[msg.sender] = disabled;
  }

  function grantvestedtokens(
    address _to,
    uint256 _value,
    uint64 _start,
    uint64 _cliff,
    uint64 _vesting) {

    if (_cliff < _start) {
      throw;
    }
    if (_vesting < _start) {
      throw;
    }
    if (_vesting < _cliff) {
      throw;
    }

    if (disabledgrants[_to]) throw; 

    tokengrant memory grant = tokengrant(msg.sender, _value, _cliff, _vesting, _start);
    grants[_to].push(grant);

    transfer(_to, _value);
  }

  function revoketokengrant(address _holder, uint _grantid) {
    throw;
  }

  function tokengrantscount(address _holder) constant returns (uint index) {
    return grants[_holder].length;
  }

  function tokengrant(address _holder, uint _grantid) constant returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting) {
    tokengrant grant = grants[_holder][_grantid];

    granter = grant.granter;
    value = grant.value;
    start = grant.start;
    cliff = grant.cliff;
    vesting = grant.vesting;

    vested = vestedtokens(grant, uint64(now));
  }

  function vestedtokens(tokengrant grant, uint64 time) internal constant returns (uint256) {
    return calculatevestedtokens(
      grant.value,
      uint256(time),
      uint256(grant.start),
      uint256(grant.cliff),
      uint256(grant.vesting)
    );
  }

  function calculatevestedtokens(
    uint256 tokens,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) internal constant returns (uint256 vestedtokens)
    {

    if (time < cliff) {
      return 0;
    }

    if (time >= vesting) {
      return tokens;
    }

    uint256 clifftokens = safediv(safemul(tokens, safesub(cliff, start)), safesub(vesting, start));
    vestedtokens = clifftokens;

    uint256 vestingtokens = safesub(tokens, clifftokens);

    vestedtokens = safeadd(vestedtokens, safediv(safemul(vestingtokens, safesub(time, cliff)), safesub(vesting, cliff)));
  }

  function nonvestedtokens(tokengrant grant, uint64 time) internal constant returns (uint256) {
    return safesub(grant.value, vestedtokens(grant, time));
  }

  
  function lasttokenistransferabledate(address holder) constant public returns (uint64 date) {
    date = uint64(now);
    uint256 grantindex = grants[holder].length;
    for (uint256 i = 0; i < grantindex; i++) {
      date = max64(grants[holder][i].vesting, date);
    }
  }

  
  function transferabletokens(address holder, uint64 time) constant public returns (uint256) {
    uint256 grantindex = grants[holder].length;

    if (grantindex == 0) return balanceof(holder);

    uint256 nonvested = 0;
    for (uint256 i = 0; i < grantindex; i++) {
      nonvested = safeadd(nonvested, nonvestedtokens(grants[holder][i], time));
    }

    return safesub(balanceof(holder), nonvested);
  }
}
