pragma solidity ^0.4.23;







interface energy {
    
    function name() external pure returns (string);

    
    
    function decimals() external pure returns (uint8);

    
    function symbol() external pure returns (string);

    
    function totalsupply() external view returns (uint256);

    
    function totalburned() external view returns(uint256);

    
    function balanceof(address _owner) external view returns (uint256 balance);

    
    function transfer(address _to, uint256 _amount) external returns (bool success);

    
    
    
    
    function move(address _from, address _to, uint256 _amount) external returns (bool success);

    
    function transferfrom(address _from, address _to, uint256 _amount) external returns(bool success);

    
    
    function allowance(address _owner, address _spender)  external view returns (uint256 remaining);

    
    function approve(address _spender, uint256 _value) external returns (bool success);
}
