













pragma solidity >=0.5.0;
pragma experimental abiencoderv2;

import ;

contract flippy {
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
    struct flip {
        bytes32 ilk;  
        address urn;  
        uint256 ink;  
        uint256 tab;  
    }

    mapping (bytes32 => ilk)  public ilks;
    mapping (uint256 => flip) public flips;
    uint256                   public nflip;

    uint256 public live;
    vatlike public vat;
    vowlike public vow;

    
    event bite(
      bytes32 indexed ilk,
      address indexed urn,
      uint256 ink,
      uint256 art,
      uint256 tab,
      uint256 flip
    );

    event flipkick(
      uint256 indexed nflip,
      uint256 nbid
    );

    
    constructor(address vat_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
        live = 1;
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

    
    function file(bytes32 what, address data) public note auth {
        if (what == ) vow = vowlike(data);
    }
    function file(bytes32 ilk, bytes32 what, uint data) public note auth {
        if (what == ) ilks[ilk].chop = data;
        if (what == ) ilks[ilk].lump = data;
    }
    function file(bytes32 ilk, bytes32 what, address flip) public note auth {
        if (what == ) ilks[ilk].flip = flip; vat.hope(flip);
    }
    function cage() public note auth {
        live = 0;
    }

    
    function bite(bytes32 ilk, address urn) public returns (uint) {
        require(live == 1);
        vatlike.ilk memory i = vat.ilks(ilk);
        vatlike.urn memory u = vat.urns(ilk, urn);

        uint tab = mul(u.art, i.rate);

        require(mul(u.ink, i.spot) < tab);  

        vat.grab(ilk, urn, address(this), address(vow), int(u.ink), int(u.art));
        vow.fess(tab);

        flips[nflip] = flip(ilk, urn, u.ink, tab);

        emit bite(ilk, urn, u.ink, u.art, tab, nflip);

        return nflip++;
    }
    function flip(uint n, uint rad) public note returns (uint id) {
        flip storage f = flips[n];
        ilk  storage i = ilks[f.ilk];

        require(rad <= f.tab);
        require(rad == i.lump || (rad < i.lump && rad == f.tab));

        uint tab = f.tab;
        uint ink = mul(f.ink, rad) / tab;

        f.tab = rad;
        f.ink = ink;

        id = flippy(i.flip).kick({ urn: f.urn
                                 , gal: address(vow)
                                 , tab: rmul(rad, i.chop)
                                 , lot: ink
                                 , bid: 0
                                 });
        emit flipkick(n, id);
    }
}
