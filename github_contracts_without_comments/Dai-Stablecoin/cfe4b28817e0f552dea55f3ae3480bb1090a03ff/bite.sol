













pragma solidity >=0.5.0;
pragma experimental abiencoderv2;

import ;

contract flippy {
    function kick(bytes32 urn, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
    function gem() public returns (address);
}

contract hopeful {
    function hope(address) public;
    function nope(address) public;
}

contract vatlike {
    struct ilk {
        uint256 take;  
        uint256 rate;  
        uint256 ink;   
        uint256 art;   
    }
    struct urn {
        uint256 ink;   
        uint256 art;   
    }
    function ilks(bytes32) public view returns (ilk memory);
    function urns(bytes32,bytes32) public view returns (urn memory);
    function grab(bytes32,bytes32,bytes32,bytes32,int,int) public;
}

contract pitlike {
    function ilks(bytes32) public view returns (uint,uint);
}

contract vowlike {
    function fess(uint) public;
}

contract cat is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address guy) public note auth { wards[guy] = 1; }
    function deny(address guy) public note auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct ilk {
        address flip;  
        uint256 chop;  
        uint256 lump;  
    }
    struct flip {
        bytes32 ilk;  
        bytes32 urn;  
        uint256 ink;  
        uint256 tab;  
    }

    mapping (bytes32 => ilk)  public ilks;
    mapping (uint256 => flip) public flips;
    uint256                   public nflip;

    uint256 public live;
    vatlike public vat;
    pitlike public pit;
    vowlike public vow;

    
    event bite(
      bytes32 indexed ilk,
      bytes32 indexed urn,
      uint256 ink,
      uint256 art,
      uint256 tab,
      uint256 flip,
      uint256 iink,
      uint256 iart
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
        if (what == ) pit = pitlike(data);
        if (what == ) vow = vowlike(data);
    }
    function file(bytes32 ilk, bytes32 what, uint data) public note auth {
        if (what == ) ilks[ilk].chop = data;
        if (what == ) ilks[ilk].lump = data;
    }
    function file(bytes32 ilk, bytes32 what, address flip) public note auth {
        if (what == ) ilks[ilk].flip = flip;
    }

    
    function bite(bytes32 ilk, bytes32 urn) public returns (uint) {
        require(live == 1);
        vatlike.ilk memory i = vat.ilks(ilk);
        vatlike.urn memory u = vat.urns(ilk, urn);
        (uint spot, uint line) = pit.ilks(ilk); line;
        uint tab = rmul(u.art, i.rate);

        require(rmul(u.ink, spot) < tab);  

        vat.grab(ilk, urn, bytes32(bytes20(address(this))), bytes32(bytes20(address(vow))), int(u.ink), int(u.art));
        vow.fess(tab);

        flips[nflip] = flip(ilk, urn, u.ink, tab);

        emit bite(ilk, urn, u.ink, u.art, tab, nflip, i.ink, i.art);

        return nflip++;
    }
    function flip(uint n, uint wad) public note returns (uint id) {
        require(live == 1);
        flip storage f = flips[n];
        ilk  storage i = ilks[f.ilk];

        require(wad <= f.tab);
        require(wad == i.lump || (wad < i.lump && wad == f.tab));

        uint tab = f.tab;
        uint ink = mul(f.ink, wad) / tab;

        f.tab = wad;
        f.ink = ink;

        hopeful(flippy(i.flip).gem()).hope(i.flip);
        id = flippy(i.flip).kick({ urn: f.urn
                                 , gal: address(vow)
                                 , tab: rmul(wad, i.chop)
                                 , lot: ink
                                 , bid: 0
                                 });
        hopeful(flippy(i.flip).gem()).nope(i.flip);
    }
}
