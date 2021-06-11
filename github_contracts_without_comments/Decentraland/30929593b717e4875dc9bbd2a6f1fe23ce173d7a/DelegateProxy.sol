pragma solidity ^0.4.18;

contract delegateproxy {
  
  function delegatedfwd(address _dst, bytes _calldata) internal {
    require(iscontract(_dst));
    assembly {
      let result := delegatecall(sub(gas, 10000), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
      let size := returndatasize

      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)

      
      
      switch result case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }

  function iscontract(address _target) constant internal returns (bool) {
    uint256 size;
    assembly { size := extcodesize(_target) }
    return size > 0;
  }
}
