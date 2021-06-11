













pragma solidity >=0.5.0;

import ;

contract vatlike {
    function move(address,address,uint) public;
}
contract gemlike {
    function mint(address,uint) public;
}



contract flopper is dsnote {
    
    mapping (address => uint) public wards;
    function rely(address usr) public note auth { wards[usr] = 1; }
    function deny(address usr) public note auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    
    struct bid {
        uint256 bid;
        uint256 lot;
        address guy;  
        uint48  tic;  
        uint48  end;
    }

    mapping (uint => bid) public bids;

    vatlike  public   vat;
    gemlike  public   gem;

    uint256  constant one = 1.00e27;
    uint256  public   beg = 1.05e27;  
    uint48   public   ttl = 3 hours;  
    uint48   public   tau = 2 days;   
    uint256  public kicks = 0;
    uint256  public live;

    
    event kick(
      uint256 id,
      uint256 lot,
      uint256 bid,
      address indexed gal
    );

    
    constructor(address vat_, address gem_) public {
        wards[msg.sender] = 1;
        vat = vatlike(vat_);
        gem = gemlike(gem_);
        live = 1;
    }

    
    function add(uint48 x, uint48 y) internal pure returns (uint48 z) {
        require((z = x + y) >= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    
    function file(bytes32 what, uint data) public note auth {
        if (what == ) beg = data;
        if (what == ) ttl = uint48(data);
        if (what == ) tau = uint48(data);
    }

    
    function kick(address gal, uint lot, uint bid) public auth returns (uint id) {
        require(live == 1);
        require(kicks < uint(1));
        id = ++kicks;

        bids[id].bid = bid;
        bids[id].lot = lot;
        bids[id].guy = gal;
        bids[id].end = add(uint48(now), tau);

        emit kick(id, lot, bid, gal);
    }
    function dent(uint id, uint lot, uint bid) public note {
        require(live == 1);
        require(bids[id].guy != address(0));
        require(bids[id].tic > now || bids[id].tic == 0);
        require(bids[id].end > now);

        require(bid == bids[id].bid);
        require(lot <  bids[id].lot);
        require(mul(beg, lot) / one <= bids[id].lot);  

        vat.move(msg.sender, bids[id].guy, bid);

        bids[id].guy = msg.sender;
        bids[id].lot = lot;
        bids[id].tic = add(uint48(now), ttl);
    }
    function deal(uint id) public note {
        require(live == 1);
        require(bids[id].tic < now && bids[id].tic != 0 ||
                bids[id].end < now);
        gem.mint(bids[id].guy, bids[id].lot);
        delete bids[id];
    }

    function cage() public note auth {
       live = 0;
    }
    function yank(uint id) public note {
        require(live == 0);
        require(bids[id].guy != address(0));
        vat.move(address(this), bids[id].guy, bids[id].bid);
        delete bids[id];
    }
}
