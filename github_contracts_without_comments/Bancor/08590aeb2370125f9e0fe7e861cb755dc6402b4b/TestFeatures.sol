pragma solidity 0.4.26;
import ;


contract testfeatures {
    icontractfeatures public features;

    constructor(icontractfeatures _features) public {
        features = _features;
    }

    function enablefeatures(uint256 _features, bool _enable) public {
        features.enablefeatures(_features, _enable);
    }
}
