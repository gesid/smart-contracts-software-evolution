
pragma solidity 0.6.12;
import ;
import ;
import ;


interface ismarttoken is iconverteranchor, ierc20token {
    function disabletransfers(bool _disable) external;
    function issue(address _to, uint256 _amount) external;
    function destroy(address _from, uint256 _amount) external;
}
