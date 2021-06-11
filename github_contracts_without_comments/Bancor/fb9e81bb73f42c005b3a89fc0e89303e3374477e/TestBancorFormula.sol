
pragma solidity 0.6.12;
import ;


contract testbancorformula is bancorformula {
    function powertest(uint256 _basen, uint256 _based, uint32 _expn, uint32 _expd) external view returns (uint256, uint8) {
        return super.power(_basen, _based, _expn, _expd);
    }

    function generallogtest(uint256 x) external pure returns (uint256) {
        return super.generallog(x);
    }

    function floorlog2test(uint256 _n) external pure returns (uint8) {
        return super.floorlog2(_n);
    }

    function findpositioninmaxexparraytest(uint256 _x) external view returns (uint8) {
        return super.findpositioninmaxexparray(_x);
    }

    function generalexptest(uint256 _x, uint8 _precision) external pure returns (uint256) {
        return super.generalexp(_x, _precision);
    }

    function optimallogtest(uint256 x) external pure returns (uint256) {
        return super.optimallog(x);
    }

    function optimalexptest(uint256 x) external pure returns (uint256) {
        return super.optimalexp(x);
    }

    function normalizedweightstest(uint256 _a, uint256 _b) external pure returns (uint32, uint32) {
        return super.normalizedweights(_a, _b);
    }

    function accurateweightstest(uint256 _a, uint256 _b) external pure returns (uint32, uint32) {
        return super.accurateweights(_a, _b);
    }

    function rounddivtest(uint256 _n, uint256 _d) external pure returns (uint256) {
        return super.rounddiv(_n, _d);
    }
}
