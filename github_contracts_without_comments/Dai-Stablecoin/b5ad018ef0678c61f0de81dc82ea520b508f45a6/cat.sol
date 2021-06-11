













pragma solidity >=0.5.0;
pragma experimental abiencoderv2;

import ;

contract kicker {
    function kick(address urn, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
}

contract vatlike {
    struct ilk {
        uint256 art;   
        uint256 rate;  
        uint256 spot;  
        uint256 line;  
    }
    struct urn {
        uint256 ink;   
        uint256 art;   
    }
    function ilks(bytes32) public view returns (ilk memory);
    function urns(bytes32,address) public view returns (urn memory);
    function grab(bytes32,address,address,address,int,int) public;
    function hope(address) public;
}

contract vowlike {
    function fess(uint) public;
}

contract cat is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) public note auth { wards[usr] = 1; }
    function deny(address usr) public note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct ilk {
        address flip;  
        uint256 chop;  
        uint256 lump;  
    }

    mapping (bytes32 => ilk) public ilks;

    uint256 public live;
    vatlike public vat;
    vowlike public vow;

    
    event bite(
      bytes32 indexed ilk,
      address indexed urn,
      uint256 ink,
      uint256 art,
      uint256 tab,
      address flip,
      uint256 id
    );

    
    constructor(address vat_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
        live = 1;
    }

    
    uint constant one = 10 ** 27;

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = mul(x, y) / one;
    }
    function min(uint x, uint y) internal pure returns (uint z) {
        if (x > y) { z = y; } else { z = x; }
    }

    
    function file(bytes32 what, address data) public note auth {
        if (what == ) vow = vowlike(data);
    }
    function file(bytes32 ilk, bytes32 what, uint data) public note auth {
        if (what == ) ilks[ilk].chop = data;
        if (what == ) ilks[ilk].lump = data;
    }
    function file(bytes32 ilk, bytes32 what, address flip) public note auth {
        if (what == ) { ilks[ilk].flip = flip; vat.hope(flip); }
    }

    
    function bite(bytes32 ilk, address urn) public returns (uint id) {
        vatlike.ilk memory i = vat.ilks(ilk);
        vatlike.urn memory u = vat.urns(ilk, urn);

        require(live == 1);
        require(mul(u.ink, i.spot) < mul(u.art, i.rate));

        uint art = min(u.art, ilks[ilk].lump / i.rate);
        uint lot = min(u.ink, mul(art, u.ink) / u.art);
        uint tab = mul(art, i.rate);

        require(int(lot) < 0 && int(art) < 0);
        vat.grab(ilk, urn, address(this), address(vow), int(lot), int(art));

        vow.fess(tab);
        id = kicker(ilks[ilk].flip).kick({ urn: urn
                                         , gal: address(vow)
                                         , tab: rmul(tab, ilks[ilk].chop)
                                         , lot: lot
                                         , bid: 0
                                         });

        emit bite(ilk, urn, lot, art, tab, ilks[ilk].flip, id);
    }

    function cage() public note auth {
        live = 0;
    }
}
