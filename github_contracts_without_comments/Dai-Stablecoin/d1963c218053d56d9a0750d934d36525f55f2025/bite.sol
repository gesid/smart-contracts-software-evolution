













pragma solidity ^0.4.24;

contract flippy{
    function kick(address lad, address gal, uint tab, uint lot, uint bid)
        public returns (uint);
}

contract vatlike {
    function ilks(bytes32) public view returns (int,int);
    function urns(bytes32,bytes32) public view returns (int,int);
    function grab(bytes32,bytes32,bytes32,bytes32,int,int) public returns (uint);
}

contract pitlike {
    function ilks(bytes32) public view returns (int,int);
}

contract vowlike {
    function fess(uint) public;
}

contract cat {
    address public vat;
    address public pit;
    address public vow;
    uint256 public lump;  

    modifier auth { _; }  

    struct ilk {
        int256  chop;
        address flip;
    }
    mapping (bytes32 => ilk) public ilks;

    struct flip {
        bytes32 ilk;
        address lad;
        uint256 ink;
        uint256 tab;
    }

    uint256                   public nflip;
    mapping (uint256 => flip) public flips;

    constructor(address vat_, address pit_, address vow_) public {
        vat = vat_;
        pit = pit_;
        vow = vow_;
    }

    function file(bytes32 what, uint risk) public auth {
        if (what == ) lump = risk;
    }
    function file(bytes32 ilk, bytes32 what, int risk) public auth {
        if (what == ) ilks[ilk].chop = risk;
    }
    function fuss(bytes32 ilk, address flip) public auth {
        ilks[ilk].flip = flip;
    }

    function bite(bytes32 ilk, address guy) public returns (uint) {
        (int rate, int art)           = vatlike(vat).ilks(ilk); art;
        (int spot, int line)          = pitlike(pit).ilks(ilk); line;
        (int ink , int art) = vatlike(vat).urns(ilk, bytes32(guy));
        int tab = rmul(art, rate);

        require(rmul(ink, spot) < tab);  

        vatlike(vat).grab(ilk, bytes32(guy), bytes32(address(this)), bytes32(vow), ink, art);
        vowlike(vow).fess(uint(tab));

        flips[nflip] = flip(ilk, guy, uint(ink), uint(tab));

        return nflip++;
    }

    function flip(uint n, uint wad) public returns (uint) {
        flip storage f = flips[n];
        ilk  storage i = ilks[f.ilk];

        require(wad <= f.tab);
        require(wad == lump || (wad < lump && wad == f.tab));

        uint tab = f.tab;
        uint ink = f.ink * wad / tab;

        f.tab = wad;
        f.ink = ink;

        return flippy(i.flip).kick({ lad: f.lad
                                   , gal: vow
                                   , tab: uint(rmul(int(wad), i.chop))
                                   , lot: uint(ink)
                                   , bid: uint(0)
                                   });
    }

    int constant ray = 10 ** 27;
    function rmul(int x, int y) internal pure returns (int z) {
        z = x * y / ray;
    }
}
