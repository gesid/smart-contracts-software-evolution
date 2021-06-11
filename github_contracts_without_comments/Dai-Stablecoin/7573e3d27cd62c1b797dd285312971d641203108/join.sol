













pragma solidity >=0.5.0;

import ;

contract gemlike {
    function transfer(address,uint) public returns (bool);
    function transferfrom(address,address,uint) public returns (bool);
}

contract dstokenlike {
    function mint(address,uint) public;
    function burn(address,uint) public;
}

contract vatlike {
    function slip(bytes32,bytes32,int) public;
    function move(bytes32,bytes32,uint) public;
    function flux(bytes32,bytes32,bytes32,uint) public;
}



contract gemjoin is dsnote {
    vatlike public vat;
    bytes32 public ilk;
    gemlike public gem;
    constructor(address vat_, bytes32 ilk_, address gem_) public {
        vat = vatlike(vat_);
        ilk = ilk_;
        gem = gemlike(gem_);
    }
    function join(bytes32 urn, uint wad) public note {
        require(int(wad) >= 0);
        vat.slip(ilk, urn, int(wad));
        require(gem.transferfrom(msg.sender, address(this), wad));
    }
    function exit(bytes32 urn, address usr, uint wad) public note {
        require(bytes20(urn) == bytes20(msg.sender));
        require(int(wad) >= 0);
        vat.slip(ilk, urn, int(wad));
        require(gem.transfer(usr, wad));
    }
}

contract ethjoin is dsnote {
    vatlike public vat;
    bytes32 public ilk;
    constructor(address vat_, bytes32 ilk_) public {
        vat = vatlike(vat_);
        ilk = ilk_;
    }
    function join(bytes32 urn) public payable note {
        require(int(msg.value) >= 0);
        vat.slip(ilk, urn, int(msg.value));
    }
    function exit(bytes32 urn, address payable usr, uint wad) public note {
        require(bytes20(urn) == bytes20(msg.sender));
        require(int(wad) >= 0);
        vat.slip(ilk, urn, int(wad));
        usr.transfer(wad);
    }
}

contract daijoin is dsnote {
    vatlike public vat;
    dstokenlike public dai;
    constructor(address vat_, address dai_) public {
        vat = vatlike(vat_);
        dai = dstokenlike(dai_);
    }
    uint constant one = 10 ** 27;
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
    function join(bytes32 urn, uint wad) public note {
        vat.move(bytes32(bytes20(address(this))), urn, mul(one, wad));
        dai.burn(msg.sender, wad);
    }
    function exit(bytes32 urn, address usr, uint wad) public note {
        require(bytes20(urn) == bytes20(msg.sender));
        vat.move(urn, bytes32(bytes20(address(this))), mul(one, wad));
        dai.mint(usr, wad);
    }
}
