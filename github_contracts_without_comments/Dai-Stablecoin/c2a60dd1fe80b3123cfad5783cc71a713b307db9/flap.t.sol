pragma solidity ^0.4.24;

import ;
import {dstoken} from ;

import {flapper} from ;


contract hevm {
    function warp(uint256) public;
}

contract guy {
    flapper fuss;
    constructor(flapper fuss_) public {
        fuss = fuss_;
        dstoken(fuss.dai()).approve(fuss);
        dstoken(fuss.gem()).approve(fuss);
    }
    function tend(uint id, uint lot, uint bid) public {
        fuss.tend(id, lot, bid);
    }
    function deal(uint id) public {
        fuss.deal(id);
    }
    function try_tend(uint id, uint lot, uint bid)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(fuss).call(sig, id, lot, bid);
    }
    function try_deal(uint id)
        public returns (bool)
    {
        bytes4 sig = bytes4(keccak256());
        return address(fuss).call(sig, id);
    }
}

contract gal {}

contract vatlike is dstoken() {
    uint constant one = 10 ** 27;
    function move(bytes32 src, bytes32 dst, int wad) public {
        move(address(src), address(dst), uint(wad) / one);
    }
}

contract flaptest is dstest {
    hevm hevm;

    flapper fuss;
    vatlike dai;
    dstoken gem;

    guy  ali;
    guy  bob;
    gal  gal;

    function setup() public {
        hevm = hevm(0x7109709ecfa91a80626ff3989d68f67f5b1dd12d);
        hevm.warp(1 hours);

        dai = new vatlike();
        gem = new dstoken();

        fuss = new flapper(dai, gem);

        ali = new guy(fuss);
        bob = new guy(fuss);
        gal = new gal();

        dai.approve(fuss);
        gem.approve(fuss);

        dai.mint(1000 ether);
        gem.mint(1000 ether);

        gem.push(ali, 200 ether);
        gem.push(bob, 200 ether);
    }
    function test_kick() public {
        asserteq(dai.balanceof(this), 1000 ether);
        asserteq(dai.balanceof(fuss),    0 ether);
        fuss.kick({ lot: 100 ether
                  , gal: gal
                  , bid: 0
                  });
        asserteq(dai.balanceof(this),  900 ether);
        asserteq(dai.balanceof(fuss),  100 ether);
    }
    function test_tend() public {
        uint id = fuss.kick({ lot: 100 ether
                            , gal: gal
                            , bid: 0
                            });
        
        asserteq(dai.balanceof(this), 900 ether);

        ali.tend(id, 100 ether, 1 ether);
        
        asserteq(gem.balanceof(ali), 199 ether);
        
        asserteq(gem.balanceof(gal),   1 ether);

        bob.tend(id, 100 ether, 2 ether);
        
        asserteq(gem.balanceof(bob), 198 ether);
        
        asserteq(gem.balanceof(ali), 200 ether);
        
        asserteq(gem.balanceof(gal),   2 ether);

        hevm.warp(5 weeks);
        bob.deal(id);
        
        asserteq(dai.balanceof(fuss),  0 ether);
        asserteq(dai.balanceof(bob), 100 ether);
    }
    function test_beg() public {
        uint id = fuss.kick({ lot: 100 ether
                            , gal: gal
                            , bid: 0
                            });
        asserttrue( ali.try_tend(id, 100 ether, 1.00 ether));
        asserttrue(!bob.try_tend(id, 100 ether, 1.01 ether));
        
        asserttrue(!ali.try_tend(id, 100 ether, 1.01 ether));
        asserttrue( bob.try_tend(id, 100 ether, 1.07 ether));
    }
}