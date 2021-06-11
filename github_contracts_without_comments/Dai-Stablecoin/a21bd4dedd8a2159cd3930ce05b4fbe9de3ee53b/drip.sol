pragma solidity ^0.4.24;

import ;

contract vatlike {
    function ilks(bytes32) public returns (uint,uint,uint,uint);
    function fold(bytes32,bytes32,int) public;
}

contract drip is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) public note auth { wards[guy] = 1; }
    function deny(address guy) public note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct ilk {
        uint256 tax;
        uint48  rho;
    }

    mapping (bytes32 => ilk) public ilks;
    vatlike                  public vat;
    bytes32                  public vow;
    uint256                  public repo;

    function era() public view returns (uint48) { return uint48(now); }

    
    constructor(address vat_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
    }

    
    function rpow(uint x, uint n, uint base) internal pure returns (uint z) {
      assembly {
        switch x case 0 {switch n case 0 {z := base} default {z := 0}}
        default {
          switch mod(n, 2) case 0 { z := base } default { z := x }
          let half := div(base, 2)  
          for { n := div(n, 2) } n { n := div(n,2) } {
            let xx := mul(x, x)
            if iszero(eq(div(xx, x), x)) { revert(0,0) }
            let xxround := add(xx, half)
            if lt(xxround, xx) { revert(0,0) }
            x := div(xxround, base)
            if mod(n,2) {
              let zx := mul(z, x)
              if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
              let zxround := add(zx, half)
              if lt(zxround, zx) { revert(0,0) }
              z := div(zxround, base)
            }
          }
        }
      }
    }
    uint256 constant one = 10 ** 27;
    function add(uint x, uint y) internal pure returns (uint z) {
        z = x + y;
        require(z >= x);
    }
    function diff(uint x, uint y) internal pure returns (int z) {
        z = int(x)  int(y);
        require(int(x) >= 0 && int(y) >= 0);
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / one;
    }

    
    function init(bytes32 ilk) public note auth {
        ilk storage i = ilks[ilk];
        require(i.tax == 0);
        i.tax = one;
        i.rho = era();
    }
    function file(bytes32 ilk, bytes32 what, uint data) public note auth {
        ilk storage i = ilks[ilk];
        require(i.rho == era());
        if (what == ) i.tax = data;
    }
    function file(bytes32 what, uint data) public note auth {
        if (what == ) repo = data;
    }
    function file(bytes32 what, bytes32 data) public note auth {
        if (what == ) vow = data;
    }

    
    function drip(bytes32 ilk) public note {
        ilk storage i = ilks[ilk];
        require(era() >= i.rho);
        (uint take, uint rate, uint ink, uint art) = vat.ilks(ilk); art; ink; take;
        vat.fold(ilk, vow, diff(rmul(rpow(add(repo, i.tax), era()  i.rho, one), rate), rate));
        i.rho = era();
    }
}
