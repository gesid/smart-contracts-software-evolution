pragma solidity ^0.4.18;
import ;
import ;
import ;


contract ibancorconverterfactory {
    function createconverter(ismarttoken _token, ibancorconverterextensions _extensions, uint32 _maxconversionfee, ierc20token _connectortoken, uint32 _connectorweight) public returns (address);
}
