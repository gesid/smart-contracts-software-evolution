













pragma solidity ^0.4.24;

import ;

contract fusspot {
    function kick(address gal, uint lot, uint bid) public returns (uint);
    function dai() public returns (address);
}

contract hopeful {
    function hope(address) public;
    function nope(address) public;
}

contract vatlike {
    function dai (bytes32) public view returns (uint);
    function heal(bytes32,bytes32,int) public;
}

contract vow is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) public note auth { wards[guy] = 1; }
    function deny(address guy) public note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }


    
    address public vat;
    address public cow;  
    address public row;  

    mapping (uint48 => uint256) public sin; 
    uint256 public sin;   
    uint256 public woe;   
    uint256 public ash;   

    uint256 public wait;  
    uint256 public sump;  
    uint256 public bump;  
    uint256 public hump;  

    
    constructor() public { wards[msg.sender] = 1; }

    
    uint256 constant one = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {
      assembly {
          z := add(x, y)
          if gt(y, 0) { if iszero(gt(z, x)) { revert(0, 0) } }
      }
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
      assembly {
        z := sub(x, y)
        if gt(y, 0) { if iszero(lt(z, x)) { revert(0, 0) } }
      }
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
      assembly {
        z := mul(x, y)
        if iszero(eq(y, 0)) { if iszero(eq(div(z, y), x)) { revert(0, 0) } }
      }
    }

    
    function file(bytes32 what, uint data) public note auth {
        if (what == ) wait = data;
        if (what == ) bump = data;
        if (what == ) sump = data;
        if (what == ) hump = data;
    }
    function file(bytes32 what, address addr) public note auth {
        if (what == ) cow = addr;
        if (what == ) row = addr;
        if (what == )  vat = addr;
    }

    
    function awe() public view returns (uint) {
        return add(add(sin, woe), ash);
    }
    function joy() public view returns (uint) {
        return uint(vatlike(vat).dai(bytes32(address(this)))) / one;
    }

    
    function fess(uint tab) public note auth {
        sin[uint48(now)] = add(sin[uint48(now)], tab);
        sin = add(sin, tab);
    }
    function flog(uint48 era) public note {
        require(add(era, wait) <= now);
        sin = sub(sin, sin[era]);
        woe = add(woe, sin[era]);
        sin[era] = 0;
    }

    
    function heal(uint wad) public note {
        require(wad <= joy() && wad <= woe);
        woe = sub(woe, wad);
        require(int(mul(wad, one)) >= 0);
        vatlike(vat).heal(bytes32(address(this)), bytes32(address(this)), int(mul(wad, one)));
    }
    function kiss(uint wad) public note {
        require(wad <= ash && wad <= joy());
        ash = sub(ash, wad);
        require(int(mul(wad, one)) >= 0);
        vatlike(vat).heal(bytes32(address(this)), bytes32(address(this)), int(mul(wad, one)));
    }

    
    function flop() public returns (uint id) {
        require(woe >= sump);
        require(joy() == 0);
        woe = sub(woe, sump);
        ash = add(ash, sump);
        return fusspot(row).kick(this, uint(1), sump);
    }
    function flap() public returns (uint id) {
        require(joy() >= add(add(awe(), bump), hump));
        require(woe == 0);
        hopeful(fusspot(cow).dai()).hope(cow);
        id = fusspot(cow).kick(address(0), bump, 0);
        hopeful(fusspot(cow).dai()).nope(cow);
    }
}
