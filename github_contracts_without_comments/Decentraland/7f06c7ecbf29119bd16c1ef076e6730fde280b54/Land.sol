pragma solidity ^0.4.15;

import ;

contract land is basicnft {

  string public name = ;
  string public symbol = ;

  address public claimcontract;
  mapping (uint => uint) public latestping;

  event tokenping(uint tokenid);

  function land(address _claimcontract) {
    claimcontract = _claimcontract;
  }

  function assignnewparcel(address beneficiary, uint tokenid, string metadata) public {
    require(msg.sender == claimcontract);
    require(tokenowner[tokenid] == 0);
    latestping[tokenid] = now;
    _addtokento(beneficiary, tokenid);
    totaltokens++;
    tokencreated(tokenid, beneficiary, metadata);
  }

  function ping(uint tokenid) public {
    require(msg.sender == tokenowner[tokenid]);
    latestping[tokenid] = now;
    tokenping(tokenid);
  }

  function buildtokenid(uint x, uint y) public constant returns (uint256) {
    return uint256(sha3(x, , y));
  }

  function exists(uint x, uint y) public constant returns (bool) {
    return tokenowner[buildtokenid(x, y)] != 0;
  }

  function claimforgottenparcel(address beneficiary, uint tokenid) public {
    require(msg.sender == claimcontract);
    require(tokenowner[tokenid] != 0);
    require(latestping[tokenid] < now);
    require(now  latestping[tokenid] > 1 years);
    address oldowner = tokenowner[tokenid];
    latestping[tokenid] = now;
    _transfer(oldowner, beneficiary, tokenid);
    tokentransferred(tokenid, oldowner, beneficiary);
  }
}