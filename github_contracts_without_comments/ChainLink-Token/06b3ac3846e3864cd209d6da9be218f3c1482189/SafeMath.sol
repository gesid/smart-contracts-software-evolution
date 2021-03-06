pragma solidity ^0.4.11;



library safemath {

  

  function mul(uint256 a, uint256 b)
  internal returns (uint256)
  {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b)
  internal returns (uint256)
  {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b)
  internal returns (uint256)
  {
    require(b <= a);
    return a  b;
  }

  function add(uint256 a, uint256 b)
  internal returns (uint256)
  {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}
