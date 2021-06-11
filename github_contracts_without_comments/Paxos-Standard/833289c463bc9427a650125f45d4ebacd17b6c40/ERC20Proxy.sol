pragma solidity ^0.4.24;


import ;



contract erc20proxy is upgradeabilitystorage {
    
    constructor(address _impl) public {
        _setimplementation(_impl);
    }


    
    function () external payable {
        _delegate();
    }

    
    function _delegate() internal {
        address impl = _implementation();

        assembly {
            
            
            
            calldatacopy(0, 0, calldatasize)

            
            
            let result := delegatecall(gas, impl, 0, calldatasize, 0, 0)

            
            returndatacopy(0, 0, returndatasize)

            switch result
            
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }

    

    event transfer(address indexed from, address indexed to, uint256 value);
    event approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() public view returns (string) {
        _delegate();
    }

    function symbol() public view returns (string) {
        _delegate();
    }

    function decimals() public view returns (uint8) {
        _delegate();
    }

    function totalsupply() public view returns (uint256) {
        _delegate();
    }

    function balanceof(address who) public view returns (uint256) {
        _delegate();
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _delegate();
    }

    function allowance(address owner, address spender)
        public view returns (uint256) {
        _delegate();
    }

    function transferfrom(address from, address to, uint256 value)
    public returns (bool) {
        _delegate();
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _delegate();
    }
}
