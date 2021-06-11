













pragma solidity ^0.4.24;

import ;

contract vat {
    
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1;  }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _;  }

    
    struct ilk {
        uint256  rate;  
        uint256  art;   
    }
    struct urn {
        uint256 ink;    
        uint256 art;    
    }

    mapping (bytes32 => ilk)                       public ilks;
    mapping (bytes32 => mapping (bytes32 => urn )) public urns;
    mapping (bytes32 => mapping (bytes32 => uint)) public gem;    
    mapping (bytes32 => uint256)                   public dai;    
    mapping (bytes32 => uint256)                   public sin;    

    uint256  public debt;  
    uint256  public vice;  

    
    event note(
        bytes4   indexed  sig,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        bytes32  indexed  too,
        bytes             fax
    ) anonymous;
    modifier note {
        bytes32 foo;
        bytes32 bar;
        bytes32 too;
        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            too := calldataload(68)
        }
        emit note(msg.sig, foo, bar, too, msg.data); _;
    }
    
    constructor() public { wards[msg.sender] = 1; }

    
    function add(uint x, int y) internal pure returns (uint z) {
      assembly {
        z := add(x, y)
        if sgt(y, 0) { if iszero(gt(z, x)) { revert(0, 0) } }
        if slt(y, 0) { if iszero(lt(z, x)) { revert(0, 0) } }
      }
    }
    function sub(uint x, int y) internal pure returns (uint z) {
      assembly {
        z := sub(x, y)
        if slt(y, 0) { if iszero(gt(z, x)) { revert(0, 0) } }
        if sgt(y, 0) { if iszero(lt(z, x)) { revert(0, 0) } }
      }
    }
    function mul(uint x, int y) internal pure returns (int z) {
      assembly {
        z := mul(x, y)
        if slt(x, 0) { revert(0, 0) }
        if iszero(eq(y, 0)) { if iszero(eq(sdiv(z, y), x)) { revert(0, 0) } }
      }
    }

    
    function init(bytes32 ilk) public note auth {
        require(ilks[ilk].rate == 0);
        ilks[ilk].rate = 10 ** 27;
    }

    
    function slip(bytes32 ilk, bytes32 guy, int256 wad) public note auth {
        gem[ilk][guy] = add(gem[ilk][guy], wad);
    }
    function flux(bytes32 ilk, bytes32 src, bytes32 dst, int256 wad) public note auth {
        gem[ilk][src] = sub(gem[ilk][src], wad);
        gem[ilk][dst] = add(gem[ilk][dst], wad);
    }
    function move(bytes32 src, bytes32 dst, int256 rad) public note auth {
        dai[src] = sub(dai[src], rad);
        dai[dst] = add(dai[dst], rad);
    }

    
    function tune(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int dink, int dart) public note auth {
        urn storage urn = urns[i][u];
        ilk storage ilk = ilks[i];

        urn.ink = add(urn.ink, dink);
        urn.art = add(urn.art, dart);
        ilk.art = add(ilk.art, dart);

        gem[i][v] = sub(gem[i][v], dink);
        dai[w]    = add(dai[w],    mul(ilk.rate, dart));
        debt      = add(debt,      mul(ilk.rate, dart));
    }

    
    function grab(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int dink, int dart) public note auth {
        urn storage urn = urns[i][u];
        ilk storage ilk = ilks[i];

        urn.ink = add(urn.ink, dink);
        urn.art = add(urn.art, dart);
        ilk.art = add(ilk.art, dart);

        gem[i][v] = sub(gem[i][v], dink);
        sin[w]    = sub(sin[w],    mul(ilk.rate, dart));
        vice      = sub(vice,      mul(ilk.rate, dart));
    }
    function heal(bytes32 u, bytes32 v, int rad) public note auth {
        sin[u] = sub(sin[u], rad);
        dai[v] = sub(dai[v], rad);
        vice   = sub(vice,   rad);
        debt   = sub(debt,   rad);
    }

    
    function fold(bytes32 i, bytes32 u, int rate) public note auth {
        ilk storage ilk = ilks[i];
        ilk.rate = add(ilk.rate, rate);
        int rad  = mul(ilk.art, rate);
        dai[u]   = add(dai[u], rad);
        debt     = add(debt,   rad);
    }
}
