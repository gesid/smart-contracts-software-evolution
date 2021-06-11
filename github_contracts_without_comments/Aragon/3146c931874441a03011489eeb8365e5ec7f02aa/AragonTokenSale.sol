pragma solidity ^0.4.6;

import ;
import ;
import ;

contract aragontokensale is tokencontroller, safemath {
    uint public initialblock;             
    uint public finalblock;               
    uint public totalcollected;           
    bool public salestopped;              
    uint public initialprice;
    uint public finalprice;
    uint8 public pricestages;

    mapping (address => bool) public activated;

    minimetoken public token;           
    address public aragondevmultisig;   
    address public communitymultisig;   
    address public aragonnetwork;       

    uint public dust = 1 finney;        












    function aragontokensale (
        uint _initialblock,
        uint _finalblock,
        address _aragondevmultisig,
        address _communitymultisig,
        uint256 _initialprice,
        uint256 _finalprice,
        uint8 _pricestages
    ) {
        if ((_finalblock < block.number) ||
            (_finalblock <= _initialblock) ||
            (_aragondevmultisig == 0x0 || communitymultisig == 0x0) ||
            (_initialprice > _finalprice) ||
            (_pricestages < 1))
        {
          throw;
        }

        
        initialblock = _initialblock;
        finalblock = _finalblock;
        aragondevmultisig = _aragondevmultisig;
        communitymultisig = _communitymultisig;
        initialprice = _initialprice;
        finalprice = _finalprice;
        pricestages = _pricestages;

        
        deployant();
    }

    
    function deployant() private {
      
      if (activated[this]) throw;
      
      minimetokenfactory factory = new minimetokenfactory();
      
      if (address(factory) != addressforcontract(1)) throw;

      
      
      token = new minimetoken(address(factory), 0x0, 0, , 18, , true);
      if (address(token) != addressforcontract(2)) throw; 

      aragonnetwork = addressforcontract(3); 

      
      
      doactivatesale(this);
    }

    
    
    
    function activatesale() {
      doactivatesale(msg.sender);
    }

    function doactivatesale(address _entity) only_before_sale private {
      activated[_entity] = true;
    }

    
    
    function isactivated() constant returns (bool) {
      return activated[this] && activated[aragondevmultisig] && activated[communitymultisig];
    }

    
    
    
    
    function getprice(uint _blocknumber) constant returns (uint256) {
      if (_blocknumber < initialblock || _blocknumber > finalblock) return 2**250;

      return priceforstage(stagefordate(_blocknumber));
    }

    
    
    
    function stagefordate(uint _blocknumber) constant returns (uint8) {
      uint blockn = safesub(_blocknumber, initialblock);
      uint totalblocks = safesub(finalblock, initialblock);

      return uint8(safediv(safemul(pricestages, blockn), totalblocks));
    }

    
    
    
    
    function priceforstage(uint8 _stage) constant returns (uint256) {
      if (_stage >= pricestages) return 2**250;
      uint pricedifference = safesub(finalprice, initialprice);
      uint stagedelta = safediv(pricedifference, uint(pricestages  1));
      return safeadd(initialprice, safemul(uint256(_stage), stagedelta));
    }

    
    
    
    
    
    function allocatepresaletokens(address _receiver, uint _amount) only_before_sale_activation only_before_sale only(aragondevmultisig) {
      if (!token.generatetokens(_receiver, _amount)) throw;
    }

    
    
    function deploynetwork(bytes _networkcode) only_after_sale only(communitymultisig) {
      address deployedaddress;
      assembly {
        deployedaddress := create(0,add(_networkcode,0x20), mload(_networkcode))
        jumpi(invalidjumplabel,iszero(extcodesize(deployedaddress)))
      }

      if (deployedaddress != aragonnetwork) throw;
    }

    function addressforcontract(uint8 n) constant returns (address) {
      return address(sha3(0xd6, 0x94, this, n));
    }






    function () payable {
      dopayment(msg.sender);
    }









    function proxypayment(address _owner) payable returns (bool) {
      dopayment(_owner);
      return true;
    }







    function ontransfer(address _from, address _to, uint _amount) returns (bool) {
      return true;
    }







    function onapprove(address _owner, address _spender, uint _amount) returns (bool) {
      return true;
    }





    function dopayment(address _owner) only_during_sale_period only_sale_not_stopped only_sale_activated internal {
      if (token.controller() != address(this)) throw; 
      if (msg.value < dust) throw; 

      totalcollected = safeadd(totalcollected, msg.value); 
      uint256 boughttokens = safediv(msg.value, getprice(block.number)); 

      if (!aragondevmultisig.send(msg.value)) throw; 
      if (!token.generatetokens(_owner, boughttokens)) throw; 
    }

    
    
    function emergencystopsale() only_sale_activated only_sale_not_stopped only(aragondevmultisig) {
      salestopped = true;
    }

    
    
    function restartsale() only_during_sale_period only_sale_stopped only(aragondevmultisig) {
      salestopped = false;
    }

    
    
    
    

    function finalizesale() only(aragondevmultisig) {
      if (block.number < finalblock) throw;

      
      uint256 aragontokens = token.totalsupply() / 3;
      if (!token.generatetokens(aragondevmultisig, aragontokens)) throw;
      token.changecontroller(aragonnetwork);

      salestopped = true;
    }

    function setaragondevmultisig(address _newmultisig) only(aragondevmultisig) {
      aragondevmultisig = _newmultisig;
    }

    function setcommunitymultisig(address _newmultisig) only(communitymultisig) {
      communitymultisig = _newmultisig;
    }

    modifier only(address x) {
      if (msg.sender != x) throw;
      _;
    }

    modifier only_before_sale {
      if (block.number >= initialblock) throw;
      _;
    }

    modifier only_during_sale_period {
      if (block.number < initialblock) throw;
      if (block.number > finalblock) throw;
      _;
    }

    modifier only_sale_stopped {
      if (!salestopped) throw;
      _;
    }

    modifier only_sale_not_stopped {
      if (salestopped) throw;
      _;
    }

    modifier only_before_sale_activation {
      if (isactivated()) throw;
      _;
    }

    modifier only_sale_activated {
      if (!isactivated()) throw;
      _;
    }

    modifier only_after_sale {
      if (block.number <= finalblock) throw;
      if (!salestopped) throw;
      _;
    }

}
