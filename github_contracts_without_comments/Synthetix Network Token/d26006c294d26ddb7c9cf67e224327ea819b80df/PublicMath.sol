
pragma solidity ^0.4.19;

import ;

contract publicmath is safedecimalmath {
    function pubaddissafe(uint x, uint y)
        pure
        public
        returns (bool)
    {
        return addissafe(x, y);
    }

    function pubsafeadd(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safeadd(x, y);
    }

    function pubsubissafe(uint x, uint y)
        pure
        public
        returns (bool)
    {
        return subissafe(x, y);
    }

    function pubsafesub(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safesub(x, y);
    }

    function pubmulissafe(uint x, uint y)
        pure
        public
        returns (bool)
    {
        return mulissafe(x, y);
    }

	function pubsafemul(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safemul(x, y);
    }

    function pubsafedecmul(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safedecmul(x, y);
    }

    function pubdivissafe(uint x, uint y)
        pure
        public
        returns (bool)
    {
        return divissafe(x, y);
    }

	function pubsafediv(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safediv(x, y);
    }

    function pubsafedecdiv(uint x, uint y)
        pure
        public
        returns (uint)
    {
        return safedecdiv(x, y);
    }

    function pubinttodec(uint i)
        pure
        public
        returns (uint)
    {
        return inttodec(i);
    }
}
