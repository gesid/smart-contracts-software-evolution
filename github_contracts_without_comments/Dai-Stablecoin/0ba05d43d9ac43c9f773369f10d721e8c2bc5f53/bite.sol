













pragma solidity ^0.4.24;

contract flippy {
    function kick(bytes32 lad, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
}

contract vatlike {
    function ilks(bytes32) public view returns (uint,uint);
    function urns(bytes32,bytes32) public view returns (uint,uint);
    function grab(bytes32,bytes32,bytes32,bytes32,int,int) public;
}

contract pitlike {
    function ilks(bytes32) public view returns (uint,uint);
}

contract vowlike {
    function fess(uint) public;
}

contract cat {
    
    mapping (address => bool) public wards;
    function rely(address guy) public auth { wards[guy] = true;  }
    function deny(address guy) public auth { wards[guy] = false; }
    modifier auth { require(wards[msg.sender]); _;  }

    
    struct ilk {
        address flip;
        uint256 chop;
        uint256 lump;
    }
    struct flip {
        bytes32 ilk;
        bytes32 lad;
        uint256 ink;
        uint256 tab;
    }

    mapping (bytes32 => ilk)  public ilks;
    mapping (uint256 => flip) public flips;
    uint256                   public nflip;

    vatlike public vat;
    pitlike public pit;
    vowlike public vow;

    
    constructor(address vat_, address pit_, address vow_) public {
        wards[msg.sender] = true;
        vat = vatlike(vat_);
        pit = pitlike(pit_);
        vow = vowlike(vow_);
    }

    
    uint constant one = 10 ** 27;

    function mul(uint x, uint y) internal pure returns (uint z) {
        z = x * y;
        require(y == 0 || z / y == x);
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / one;
    }

    
    function file(bytes32 ilk, bytes32 what, uint risk) public auth {
        if (what == ) ilks[ilk].chop = risk;
        if (what == ) ilks[ilk].lump = risk;
    }
    function file(bytes32 ilk, bytes32 what, address flip) public auth {
        if (what == ) ilks[ilk].flip = flip;
    }

    
    function bite(bytes32 ilk, bytes32 lad) public returns (uint) {
        (uint rate, uint art)  = vat.ilks(ilk); art;
        (uint spot, uint line) = pit.ilks(ilk); line;
        (uint ink , uint art)  = vat.urns(ilk, lad);
        uint tab = rmul(art, rate);

        require(rmul(ink, spot) < tab);  

        vat.grab(ilk, lad, bytes32(address(this)), bytes32(address(vow)), int(ink), int(art));
        vow.fess(tab);

        flips[nflip] = flip(ilk, lad, ink, tab);

        return nflip++;
    }
    function flip(uint n, uint wad) public returns (uint) {
        flip storage f = flips[n];
        ilk  storage i = ilks[f.ilk];

        require(wad <= f.tab);
        require(wad == i.lump || (wad < i.lump && wad == f.tab));

        uint tab = f.tab;
        uint ink = mul(f.ink, wad) / tab;

        f.tab = wad;
        f.ink = ink;

        return flippy(i.flip).kick({ lad: f.lad
                                   , gal: vow
                                   , tab: rmul(wad, i.chop)
                                   , lot: ink
                                   , bid: 0
                                   });
    }
}
