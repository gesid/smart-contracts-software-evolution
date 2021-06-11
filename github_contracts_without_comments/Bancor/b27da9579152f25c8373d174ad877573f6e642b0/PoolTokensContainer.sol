
pragma solidity 0.6.12;
import ;
import ;
import ;


contract pooltokenscontainer is ipooltokenscontainer, owned {
    uint8 internal constant max_pool_tokens = 5;    

    string public name;                 
    string public symbol;               
    uint8 public decimals;              
    idstoken[] private _pooltokens;  

    
    constructor(string memory _name, string memory _symbol, uint8 _decimals) public {
         
        require(bytes(_name).length > 0, );
        require(bytes(_symbol).length > 0, );

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    
    function pooltokens() external view override returns (idstoken[] memory) {
        return _pooltokens;
    }

    
    function createtoken() external override owneronly returns (idstoken) {
        
        require(_pooltokens.length < max_pool_tokens, );

        string memory poolname = concatstrdigit(name, uint8(_pooltokens.length + 1));
        string memory poolsymbol = concatstrdigit(symbol, uint8(_pooltokens.length + 1));

        dstoken token = new dstoken(poolname, poolsymbol, decimals);
        _pooltokens.push(token);
        return token;
    }

    
    function mint(idstoken _token, address _to, uint256 _amount) external override owneronly {
        _token.issue(_to, _amount);
    }

    
    function burn(idstoken _token, address _from, uint256 _amount) external override owneronly {
        _token.destroy(_from, _amount);
    }

    
    function concatstrdigit(string memory _str, uint8 _digit) private pure returns (string memory) {
        return string(abi.encodepacked(_str, uint8(bytes1()) + _digit));
    }
}
