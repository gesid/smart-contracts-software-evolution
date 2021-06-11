pragma solidity ^0.5.16;


interface idepot {
    
    function fundswallet() external view returns (address payable);

    function maxethpurchase() external view returns (uint);

    function minimumdepositamount() external view returns (uint);

    function synthsreceivedforether(uint amount) external view returns (uint);

    function totalsellabledeposits() external view returns (uint);

    
    function depositsynths(uint amount) external;

    function exchangeetherforsynths() external payable returns (uint);

    function exchangeetherforsynthsatrate(uint guaranteedrate) external payable returns (uint);

    function withdrawmydepositedsynths() external;

    
    function exchangeetherforsnx() external payable returns (uint);

    function exchangeetherforsnxatrate(uint guaranteedrate, uint guaranteedsynthetixrate) external payable returns (uint);

    function exchangesynthsforsnx(uint synthamount) external returns (uint);

    function exchangesynthsforsnxatrate(uint synthamount, uint guaranteedrate) external returns (uint);
}