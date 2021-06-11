pragma solidity ^0.4.24;

import ;

import {warpflop as flop} from ;
import {warpflap as flap} from ;
import {warpvat  as vat}  from ;
import {vow}              from ;

contract gem {
    mapping (address => uint256) public balanceof;
    function mint(address guy, uint wad) public {
        balanceof[guy] += wad;
    }
}

contract warpvow is vow {
    uint48 _era; function warp(uint48 era_) public { _era = era_; }
    function era() public view returns (uint48) { return _era; }
}

contract vowtest is dstest {
    vat      vat;
    warpvow  vow;
    flop     flop;
    flap     flap;
    gem      gov;

    function setup() public {
        vat = new vat();
        vow = new warpvow();
        gov = new gem();

        flop = new flop(vat, gov);
        flap = new flap(vat, gov);

        vow.file(,  address(vat));
        vow.file(, address(flop));
        vow.file(, address(flap));
        vow.file(, uint256(100 ether));
    }

    function try_flog(uint48 era) internal returns (bool) {
        bytes4 sig = bytes4(keccak256());
        return address(vow).call(sig, era);
    }
    function try_flop() internal returns (bool) {
        bytes4 sig = bytes4(keccak256());
        return address(vow).call(sig);
    }
    function try_flap() internal returns (bool) {
        bytes4 sig = bytes4(keccak256());
        return address(vow).call(sig);
    }
    function try_dent(uint id, uint lot, uint bid) internal returns (bool) {
        bytes4 sig = bytes4(keccak256());
        return address(flop).call(sig, id, lot, bid);
    }

    uint256 constant one = 10 ** 27;
    function suck(address who, uint wad) internal {
        vow.fess(wad);
        vat.init();
        vat.heal(bytes32(address(vow)), bytes32(who), int(wad * one));
    }
    function flog(uint wad) internal {
        suck(address(0), wad);  
        vow.flog(vow.era());
    }

    function test_flog_wait() public {
        asserteq(vow.wait(), 0);
        vow.file(, uint(100 seconds));
        asserteq(vow.wait(), 100 seconds);

        uint48 tic = uint48(now);
        vow.fess(100 ether);
        asserttrue(!try_flog(tic) );
        vow.warp(tic + uint48(100 seconds));
        asserttrue( try_flog(tic) );
    }

    function test_no_reflop() public {
        flog(100 ether);
        asserttrue( try_flop() );
        asserttrue(!try_flop() );
    }

    function test_no_flop_pending_joy() public {
        flog(200 ether);

        vat.mint(vow, 100 ether);
        asserttrue(!try_flop() );

        vow.heal(100 ether);
        asserttrue( try_flop() );
    }

    function test_flap() public {
        vat.mint(vow, 100 ether);
        asserttrue( try_flap() );
    }

    function test_no_flap_pending_sin() public {
        vow.file(, uint256(0 ether));
        flog(100 ether);

        vat.mint(vow, 50 ether);
        asserttrue(!try_flap() );
    }
    function test_no_flap_nonzero_woe() public {
        vow.file(, uint256(0 ether));
        flog(100 ether);
        vat.mint(vow, 50 ether);
        asserttrue(!try_flap() );
    }
    function test_no_flap_pending_flop() public {
        flog(100 ether);
        vow.flop();

        vat.mint(vow, 100 ether);

        asserttrue(!try_flap() );
    }
    function test_no_flap_pending_kiss() public {
        flog(100 ether);
        uint id = vow.flop();

        vat.mint(this, 100 ether);
        flop.dent(id, 0 ether, 100 ether);

        asserttrue(!try_flap() );
    }

    function test_no_surplus_after_good_flop() public {
        flog(100 ether);
        uint id = vow.flop();
        vat.mint(this, 100 ether);

        flop.dent(id, 0 ether, 100 ether);  

        asserttrue(!try_flap() );
    }

    function test_multiple_flop_dents() public {
        flog(100 ether);
        uint id = vow.flop();

        vat.mint(this, 100 ether);
        asserttrue(try_dent(id, 2 ether,  100 ether));

        vat.mint(this, 100 ether);
        asserttrue(try_dent(id, 1 ether,  100 ether));
    }
}
