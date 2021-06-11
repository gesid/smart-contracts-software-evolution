













pragma solidity ^0.4.24;

contract vat {
    modifier auth { _; }  

    struct ilk {
        int256  rate;  
        int256  art;   
    }
    struct urn {
        int256 ink;    
        int256 art;    
    }

    mapping (bytes32 => ilk)                      public ilks;
    mapping (bytes32 => mapping (bytes32 => urn)) public urns;
    mapping (bytes32 => mapping (bytes32 => int)) public gem;    
    mapping (bytes32 => int256)                   public dai;    
    mapping (bytes32 => int256)                   public sin;    

    int256  public tab;   
    int256  public vice;  

    function add(int x, int y) internal pure returns (int z) {
        z = x + y;
        require(y <= 0 || z > x);
        require(y >= 0 || z < x);
    }
    function sub(int x, int y) internal pure returns (int z) {
        require(y != 2**255);
        z = add(x, y);
    }
    function mul(int x, int y) internal pure returns (int z) {
        z = x * y;
        require(y >= 0 || x != 2**255);
        require(y == 0 || z / y == x);
    }

    
    function file(bytes32 ilk, bytes32 what, int risk) public auth {
        if (what == ) ilks[ilk].rate = risk;
    }

    
    function move(bytes32 src, bytes32 dst, uint256 rad) public auth {
        require(int(rad) >= 0);
        dai[src] = sub(dai[src], int(rad));
        dai[dst] = add(dai[dst], int(rad));
        require(dai[src] >= 0 && dai[dst] >= 0);
    }
    function slip(bytes32 ilk, bytes32 guy, int256 wad) public auth {
        gem[ilk][guy] = add(gem[ilk][guy], wad);
        require(gem[ilk][guy] >= 0);
    }
    function flux(bytes32 ilk, bytes32 src, bytes32 dst, int256 wad) public auth {
        gem[ilk][src] = sub(gem[ilk][src], wad);
        gem[ilk][dst] = add(gem[ilk][dst], wad);
        require(gem[ilk][src] >= 0 && gem[ilk][dst] >= 0);
    }

    
    function tune(bytes32 ilk, bytes32 u_, bytes32 v, bytes32 w, int dink, int dart) public auth {
        urn storage u = urns[ilk][u_];
        ilk storage i = ilks[ilk];

        u.ink = add(u.ink, dink);
        u.art = add(u.art, dart);
        i.art = add(i.art, dart);

        gem[ilk][v] = sub(gem[ilk][v], dink);
        dai[w]      = add(dai[w],      mul(i.rate, dart));
        tab         = add(tab,         mul(i.rate, dart));
    }

    
    function grab(bytes32 ilk, bytes32 u_, bytes32 v, bytes32 w, int dink, int dart) public auth {
        urn storage u = urns[ilk][u_];
        ilk storage i = ilks[ilk];

        u.ink = add(u.ink, dink);
        u.art = add(u.art, dart);
        i.art = add(i.art, dart);

        gem[ilk][v] = sub(gem[ilk][v], dink);
        sin[w]      = sub(sin[w],      mul(i.rate, dart));
        vice        = sub(vice,        mul(i.rate, dart));
    }
    function heal(bytes32 u, bytes32 v, int rad) public auth {
        sin[u] = sub(sin[u], rad);
        dai[v] = sub(dai[v], rad);
        vice   = sub(vice,   rad);
        tab    = sub(tab,    rad);

        require(sin[u] >= 0 && dai[v] >= 0);
        require(vice   >= 0 && tab    >= 0);
    }

    
    function fold(bytes32 ilk, bytes32 vow, int rate) public auth {
        ilk storage i = ilks[ilk];
        i.rate   = add(i.rate, rate);
        int rad  = mul(i.art, rate);
        dai[vow] = add(dai[vow], rad);
        tab      = add(tab, rad);
    }
}
