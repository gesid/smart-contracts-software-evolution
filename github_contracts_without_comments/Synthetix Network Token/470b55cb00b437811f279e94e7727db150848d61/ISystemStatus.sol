pragma solidity 0.4.25;

interface isystemstatus {
    function requiresystemactive() external view;

    function requireissuanceactive() external view;

    function requireexchangeactive() external view;

    function requiresynthactive(bytes32 currencykey) external view;

    function requiresynthsactive(bytes32 sourcecurrencykey, bytes32 destinationcurrencykey) external view;
}
