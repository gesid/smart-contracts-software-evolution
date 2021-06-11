pragma solidity ^0.4.24;

contract vatlike {
    function ilks(bytes32) public returns (uint,uint);
    function fold(bytes32,bytes32,int) public;
}

contract drip {
    vatlike vat;
    struct ilk {
        bytes32 vow;
        uint256 tax;
        uint48  rho;
    }
    mapping (bytes32 => ilk) public ilks;

    modifier auth { _; }  

    function era() public view returns (uint48) { return uint48(now); }

    constructor(address vat_) public { vat = vatlike(vat_); }

    function file(bytes32 ilk, bytes32 vow, uint tax) public auth {
        ilk storage i = ilks[ilk];
        require(i.rho == era());
        i.vow = vow;
        i.tax = tax;
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
    function diff(uint x, uint y) internal pure returns (int z) {
        z = int(x)  int(y);
        require(int(x) >= 0 && int(y) >= 0);
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / one;
    }
    function drip(bytes32 ilk) public {
        ilk storage i = ilks[ilk];
        if ( i.rho == era() ) return;
        if ( i.tax == one   ) return;
        require(era() >= i.rho);
        (uint rate, uint art) = vat.ilks(ilk); art;
        vat.fold(ilk, i.vow, diff(rmul(rpow(i.tax, era()  i.rho, one), rate), rate));
        i.rho = era();
    }
}
