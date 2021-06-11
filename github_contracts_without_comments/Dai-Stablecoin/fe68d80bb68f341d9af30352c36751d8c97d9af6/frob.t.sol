pragma solidity ^0.4.23;

import ;
import ;

import ;
import ;
import {dai20} from ;
import {adapter} from ;

import {warpflip as flipper} from ;
import {warpflop as flopper} from ;
import {warpflap as flapper} from ;


contract warpvat is vat {
    uint48 _era; function warp(uint48 era_) public { _era = era_; }
    function era() public view returns (uint48) { return _era; }

    function suck(address guy, uint wad) public {
        dai[guy] += int(wad);
    }
    function mint(address guy, uint wad) public {
        dai[guy] += int(wad);
    }
}

contract warpvow is vow {
    constructor(address vat_) vow(vat_) public { }

    function woe() public view returns (uint) {
        return woe;
    }
    function joy() public view returns (uint) {
        return joy();
    }
    function stun(uint wad) public {
        woe += wad;
    }
    function whip(uint wad) public {
        sin[era()] += wad;
        sin += wad;
    }
}

contract frobtest is dstest {
    warpvat vat;
    dai20   pie;

    dstoken gold;
    bytes32 gold_ilk;

    adapter adapter;

    function try_frob(bytes32 ilk, int ink, int art) public returns(bool) {
        bytes4 sig = bytes4(keccak256());
        return address(vat).call(sig, ilk, ink, art);
    }

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }

    function setup() public {
        vat = new warpvat();
        pie = new dai20(vat);

        gold = new dstoken();
        gold.mint(1000 ether);

        gold_ilk = vat.form();
        adapter = new adapter(vat, gold_ilk, gold);
        gold.approve(adapter);
        adapter.join(1000 ether);

        vat.file(gold_ilk, , ray(1 ether));
        vat.file(gold_ilk, , 1000 ether);
        vat.file(, 1000 ether);

        gold.approve(vat);
    }

    function test_join() public {
        gold.mint(500 ether);
        asserteq(gold.balanceof(this),     500 ether);
        asserteq(gold.balanceof(adapter), 1000 ether);
        adapter.join(500 ether);
        asserteq(gold.balanceof(this),       0 ether);
        asserteq(gold.balanceof(adapter), 1500 ether);
        adapter.exit(250 ether);
        asserteq(gold.balanceof(this),     250 ether);
        asserteq(gold.balanceof(adapter), 1250 ether);
    }
    function test_lock() public {
        asserteq(vat.ink(gold_ilk, this), 0 ether);
        asserteq(adapter.balanceof(this), 1000 ether);
        vat.frob(gold_ilk, 6 ether, 0);
        asserteq(vat.ink(gold_ilk, this), 6 ether);
        asserteq(adapter.balanceof(this), 994 ether);
        vat.frob(gold_ilk, 6 ether, 0);
        asserteq(vat.ink(gold_ilk, this), 0 ether);
        asserteq(adapter.balanceof(this), 1000 ether);
    }
    function test_calm() public {
        
        
        vat.file(gold_ilk, , 10 ether);
        asserttrue( try_frob(gold_ilk, 10 ether, 9 ether));
        
        asserttrue(!try_frob(gold_ilk,  0 ether, 2 ether));
    }
    function test_cool() public {
        
        
        vat.file(gold_ilk, , 10 ether);
        asserttrue(try_frob(gold_ilk, 10 ether,  8 ether));
        vat.file(gold_ilk, , 5 ether);
        
        asserttrue(try_frob(gold_ilk,  0 ether, 1 ether));
    }
    function test_safe() public {
        
        
        vat.frob(gold_ilk, 10 ether, 5 ether);                
        asserttrue(!try_frob(gold_ilk, 0 ether, 6 ether));  
    }
    function test_nice() public {
        
        

        vat.frob(gold_ilk, 10 ether, 10 ether);
        vat.file(gold_ilk, , ray(0.5 ether));  

        
        asserttrue(!try_frob(gold_ilk,  0 ether,  1 ether));
        
        asserttrue( try_frob(gold_ilk,  0 ether, 1 ether));
        
        asserttrue(!try_frob(gold_ilk, 1 ether,  0 ether));
        
        asserttrue( try_frob(gold_ilk,  1 ether,  0 ether));

        
        
        asserttrue(!this.try_frob(gold_ilk, 2 ether, 4 ether));
        
        asserttrue(!this.try_frob(gold_ilk,  5 ether,  1 ether));

        
        asserttrue( this.try_frob(gold_ilk, 1 ether, 4 ether));
        vat.file(gold_ilk, , ray(0.4 ether));  
        
        asserttrue( this.try_frob(gold_ilk,  5 ether, 1 ether));
    }
}

contract bitetest is dstest {
    warpvat vat;
    warpvow vow;
    dai20   pie;

    dstoken gold;
    bytes32 gold_ilk;

    adapter adapter;

    flipper flip;
    flopper flop;
    flapper flap;

    dstoken gov;

    function try_frob(bytes32 ilk, int ink, int art) public returns(bool) {
        bytes4 sig = bytes4(keccak256());
        return address(vat).call(sig, ilk, ink, art);
    }

    function ray(uint wad) internal pure returns (uint) {
        return wad * 10 ** 9;
    }

    function setup() public {
        gov = new dstoken();
        gov.mint(100 ether);

        vat = new warpvat();
        pie = new dai20(vat);

        flap = new flapper(vat, gov);
        flop = new flopper(vat, gov);
        gov.setowner(flop);

        vow = new warpvow(vat);
        vow.file(, address(flap));
        vow.file(, address(flop));

        gold = new dstoken();
        gold.mint(1000 ether);

        gold_ilk = vat.form();
        adapter = new adapter(vat, gold_ilk, gold);
        gold.approve(adapter);
        adapter.join(1000 ether);

        vat.file(gold_ilk, , ray(1 ether));
        vat.file(gold_ilk, , 1000 ether);
        vat.file(, 1000 ether);
        flip = new flipper(vat, gold_ilk);
        vow.fuss(gold_ilk, flip);
        vow.file(gold_ilk, , int(ray(1 ether)));

        gold.approve(vat);
        gov.approve(flap);
    }
    function test_happy_bite() public {
        
        
        vat.file(gold_ilk, , ray(2.5 ether));
        vat.frob(gold_ilk,  40 ether, 100 ether);

        
        vat.file(gold_ilk, , ray(2 ether));  

        asserteq(vat.ink(gold_ilk, this),  40 ether);
        asserteq(vat.art(gold_ilk, this), 100 ether);
        asserteq(vow.woe(), 0 ether);
        asserteq(adapter.balanceof(this), 960 ether);
        uint id = vow.bite(gold_ilk, this);
        asserteq(vat.ink(gold_ilk, this), 0);
        asserteq(vat.art(gold_ilk, this), 0);
        asserteq(vow.sin(vow.era()), 100 ether);
        asserteq(adapter.balanceof(this), 960 ether);

        vow.file(, uint(100 ether));
        uint auction = vow.flip(id, 100 ether);  

        asserteq(pie.balanceof(vow),   0 ether);
        flip.tend(auction, 40 ether,   1 ether);
        asserteq(pie.balanceof(vow),   1 ether);
        flip.tend(auction, 40 ether, 100 ether);
        asserteq(pie.balanceof(vow), 100 ether);

        asserteq(pie.balanceof(this),       0 ether);
        asserteq(adapter.balanceof(this), 960 ether);
        vat.mint(this, 100 ether);  
        flip.dent(auction, 38 ether,  100 ether);
        asserteq(pie.balanceof(this), 100 ether);
        asserteq(pie.balanceof(vow),  100 ether);
        asserteq(adapter.balanceof(this), 962 ether);
        asserteq(vat.gem(gold_ilk, this), 962 ether);

        asserteq(vow.sin(vow.era()), 100 ether);
        asserteq(pie.balanceof(vow), 100 ether);
    }

    function test_floppy_bite() public {
        vat.file(gold_ilk, , ray(2.5 ether));
        vat.frob(gold_ilk,  40 ether, 100 ether);
        vat.file(gold_ilk, , ray(2 ether));  

        asserteq(vow.sin(vow.era()),   0 ether);
        vow.bite(gold_ilk, this);
        asserteq(vow.sin(vow.era()), 100 ether);

        asserteq(vow.sin(), 100 ether);
        vow.flog(vow.era());
        asserteq(vow.sin(),   0 ether);
        asserteq(vow.woe(), 100 ether);
        asserteq(vow.joy(),   0 ether);
        asserteq(vow.ash(),   0 ether);

        vow.file(, uint(10 ether));
        uint f1 = vow.flop();
        asserteq(vow.woe(),  90 ether);
        asserteq(vow.joy(),   0 ether);
        asserteq(vow.ash(),  10 ether);
        flop.dent(f1, 1000 ether, 10 ether);
        asserteq(vow.woe(),  90 ether);
        asserteq(vow.joy(),  10 ether);
        asserteq(vow.ash(),  10 ether);

        asserteq(gov.balanceof(this),  100 ether);
        flop.warp(4 hours);
        flop.deal(f1);
        asserteq(gov.balanceof(this), 1100 ether);
    }

    function test_flappy_bite() public {
        
        vat.mint(vow, 100 ether);
        asserteq(pie.balanceof(vow),  100 ether);
        asserteq(gov.balanceof(this), 100 ether);

        vow.file(, uint(100 ether));
        asserteq(vow.awe(), 0 ether);
        uint id = vow.flap();

        asserteq(pie.balanceof(this),   0 ether);
        asserteq(gov.balanceof(this), 100 ether);
        flap.tend(id, 100 ether, 10 ether);
        flap.warp(4 hours);
        flap.deal(id);
        asserteq(pie.balanceof(this),   100 ether);
        asserteq(gov.balanceof(this),    90 ether);
    }
}
