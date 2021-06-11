pragma solidity ^0.4.8;

import ;
import ;
import ;

contract tokensale is ownable {
  using safemath for uint;

  uint public limit;
  uint public starttime;
  uint public distributed;
  uint public phaseoneend;
  uint public phasetwoend;
  uint public endtime;
  address public recipient;
  linktoken public token;

  function tokensale(
    uint _limit,
    uint _prepurchased,
    uint _start
  ) {
    limit = _limit;
    distributed = _prepurchased;
    starttime = _start;
    phaseoneend = _start + 1 weeks;
    phasetwoend = _start + 2 weeks;
    endtime = _start + 4 weeks;
    token = new linktoken();

    if (limit > token.totalsupply()) throw;
  }

  function ()
  payable ensurestarted ensurenotended underlimit {
    if (owner.send(msg.value)) {
      distributed += msg.value;
      token.transfer(msg.sender, purchased());
    }
  }

  function closeout()
  onlyowner ensurestarted ensurecompleted {
    token.transfer(owner, token.balanceof(this));
  }


  

  function purchased()
  private returns (uint) {
    if (block.timestamp <= phaseoneend) {
      return msg.value.div(10**15);
    } else if (block.timestamp <= phasetwoend) {
      return msg.value.mul(75).div(10**17);
    } else {
      return msg.value.mul(50).div(10**17);
    }
  }

  function started()
  private returns (bool) {
    return block.timestamp >= starttime;
  }

  function ended()
  private returns (bool) {
    return block.timestamp > endtime;
  }

  function funded()
  private returns (bool) {
    return distributed == limit;
  }

  function completed()
  private returns (bool) {
    return ended() || funded();
  }


  

  modifier ensurestarted() {
    if (!started()) throw; _;
  }

  modifier ensurenotended() {
    if (ended()) throw; _;
  }

  modifier ensurecompleted() {
    if (!completed()) throw; _;
  }

  modifier underlimit() {
    if (purchased() + distributed > limit) throw; _;
  }

}
