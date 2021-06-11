
pragma solidity 0.6.12;
import ;


contract testchainlinkpriceoracle is ichainlinkpriceoracle {
    int256 private answer;
    uint256 private timestamp;

    function setanswer(int256 _answer) public {
        answer = _answer;
    }

    function settimestamp(uint256 _timestamp) public {
        timestamp = _timestamp;
    }

    function latestanswer() external view override returns (int256) {
        return answer;
    }

    function latesttimestamp() external view override returns (uint256) {
        return timestamp;
    }
}
