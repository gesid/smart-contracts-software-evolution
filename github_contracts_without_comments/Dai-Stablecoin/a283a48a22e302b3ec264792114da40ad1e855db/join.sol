













pragma solidity >=0.5.0;

import ;

contract gemlike {
    function transfer(address,uint) external returns (bool);
    function transferfrom(address,address,uint) external returns (bool);
}

contract dstokenlike {
    function mint(address,uint) external;
    function burn(address,uint) external;
}

contract vatlike {
    function slip(bytes32,address,int) external;
    function move(address,address,uint) external;
    function flux(bytes32,address,address,uint) external;
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
    function join(address usr, uint wad) external note {
        require(int(wad) >= 0);
        vat.slip(ilk, usr, int(wad));
        require(gem.transferfrom(msg.sender, address(this), wad));
    }
    function exit(address usr, uint wad) external note {
        require(wad <= 2 ** 255);
        vat.slip(ilk, msg.sender, int(wad));
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
    function join(address usr) external payable note {
        require(int(msg.value) >= 0);
        vat.slip(ilk, usr, int(msg.value));
    }
    function exit(address payable usr, uint wad) external note {
        require(int(wad) >= 0);
        vat.slip(ilk, msg.sender, int(wad));
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
    function join(address usr, uint wad) external note {
        vat.move(address(this), usr, mul(one, wad));
        dai.burn(msg.sender, wad);
    }
    function exit(address usr, uint wad) external note {
        vat.move(msg.sender, address(this), mul(one, wad));
        dai.mint(usr, wad);
    }
}
