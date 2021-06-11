pragma solidity 0.4.25;


interface iissuer {
    function issuesynths(address from, uint amount) external;

    function issuemaxsynths(address from) external;

    function burnsynths(address from, uint amount) external;
    
    function burnsynthstotarget(address from) external;

    function canburnsynths(address account) external view returns (bool);

    function lastissueevent(address account) external view returns (uint);
}
