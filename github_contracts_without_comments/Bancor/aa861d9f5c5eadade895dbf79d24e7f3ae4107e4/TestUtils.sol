pragma solidity ^0.4.11;
import ;


contract testutils is utils {
    function testutils() {
    }

    function testsafeadd(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.safeadd(_x, _y);
    }

    function testsafesub(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.safesub(_x, _y);
    }

    function testsafemul(uint256 _x, uint256 _y) public constant returns (uint256) {
        return super.safemul(_x, _y);
    }
}
