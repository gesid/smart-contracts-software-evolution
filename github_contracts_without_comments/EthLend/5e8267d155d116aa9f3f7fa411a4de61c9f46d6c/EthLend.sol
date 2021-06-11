pragma solidity ^0.4.16;


library safemath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a  b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract erc20token {
     function balanceof(address _address) constant returns (uint balance);
     function transfer(address _to, uint _value) returns (bool success);
}

contract reputationtokeninterface {
     function issuetokens(address _foraddress, uint _tokencount) returns (bool success);
     function burntokens(address _foraddress) returns (bool success);
     function locktokens(address _foraddress, uint _tokencount) returns (bool success);
     function unlocktokens(address _foraddress, uint _tokencount) returns (bool success);
     function approve(address _spender, uint256 _value) returns (bool success);
     function nonlockedtokenscount(address _foraddress) constant returns (uint tokencount);
}

contract abstractens {
     function owner(bytes32 _node) constant returns(address);
     function resolver(bytes32 _node) constant returns(address);
     function ttl(bytes32 _node) constant returns(uint64);
     function setowner(bytes32 _node, address _owner);
     function setsubnodeowner(bytes32 _node, bytes32 _label, address _owner);
     function setresolver(bytes32 _node, address _resolver);
     function setttl(bytes32 _node, uint64 _ttl);
}

contract registrar {
     function transfer(bytes32, address){
          return;
     } 
}


contract ledger is safemath {

     address public mainaddress = 0x0;        
     address public wheretosendfee = 0x0;
     address public reptokenaddress = 0x0;
     address public ensregistryaddress = 0x0;
     address public registraraddress = 0x0;

     mapping (address => mapping(uint => address)) lrsperuser;
     mapping (address => uint) lrscountperuser;

     uint public totallrcount = 0;
     mapping (uint => address) lrs;

     
     uint public borrowerfeeamount = 0.01 ether;


     modifier byanyone(){
          _;
     }


     function ledger(address _wheretosendfee,address _reptokenaddress,address _ensregistryaddress, address _registraraddress){
          mainaddress = msg.sender;
          wheretosendfee = _wheretosendfee;
          reptokenaddress = _reptokenaddress;
          ensregistryaddress = _ensregistryaddress;
          registraraddress = _registraraddress;
     }

     function getreptokenaddress()constant returns(address out){
          out = reptokenaddress;
          return;
     }

     function getfeesum()constant returns(uint out){
          out = borrowerfeeamount;
          return;
     }

     
     
     function createnewlendingrequest()payable byanyone returns(address out){
          out = newlr(0);
     }
     
     function createnewlendingrequestens()payable byanyone returns(address out){
          out = newlr(1);
     }
     
     function createnewlendingrequestrep()payable byanyone returns(address out){
          out = newlr(2);
     }

     function newlr(int _collateraltype)payable byanyone returns(address out){
          
          uint feeamount = borrowerfeeamount;
          if(msg.value<feeamount){
               revert();
          }

          wheretosendfee.transfer(feeamount);

          
          

          out = new lendingrequest(msg.sender,collateraltype);

          
          uint currentcount = lrscountperuser[msg.sender];
          lrsperuser[msg.sender][currentcount] = out;
          lrscountperuser[msg.sender]++;

          lrs[totallrcount] = out;
          totallrcount++;
          return;
     }

     function getlrcount()constant returns(uint out){
          out = totallrcount;
          return;
     }

     function getlr(uint _index) constant returns (address out){
          out = lrs[_index];  
          return;
     }

     function getlrcountforuser(address _a)constant returns(uint out){
          out = lrscountperuser[_a];
          return;
     }

     function getlrforuser(address _a,uint _index) constant returns (address out){
          out = lrsperuser[_a][_index];  
          return;
     }

     function getlrfundedcount()constant returns(uint out){
          out = 0;

          for(uint i=0; i<totallrcount; ++i){
               lendingrequest lr = lendingrequest(lrs[i]);
               if(lr.getstate()==lendingrequest.state.waitingforpayback){
                    out++;
               }
          }

          return;
     }

     function getlrfunded(uint _index) constant returns (address out){
          uint indexfound = 0;
          for(uint i=0; i<totallrcount; ++i){
               lendingrequest lr = lendingrequest(lrs[i]);
               if(lr.getstate()==lendingrequest.state.waitingforpayback){
                    if(indexfound==_index){
                         out = lrs[i];
                         return;
                    }

                    indexfound++;
               }
          }
          return;
     }

     function addreptokens(address _potentialborrower, uint _weisum){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);  

          
          require((lr.borrower()==_potentialborrower) && (address(this)==lr.creator()));

          
          uint reptokens = (_weisum/10);
          reptoken.issuetokens(_potentialborrower,reptokens);               
     }

     function lockreptokens(address _potentialborrower, uint _weisum){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);  

          
          require((lr.borrower()==_potentialborrower) && (address(this)==lr.creator()));

          
          uint reptokens = (_weisum);
          reptoken.locktokens(_potentialborrower,reptokens);               
     }

     function unlockreptokens(address _potentialborrower, uint _weisum){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);

          
          require((lr.borrower()==_potentialborrower) && (address(this)==lr.creator()));

          
          uint reptokens = (_weisum);
          reptoken.unlocktokens(_potentialborrower,reptokens);               
     }

     function burnreptokens(address _potentialborrower){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          lendingrequest lr = lendingrequest(msg.sender);  

          
          require((lr.borrower()==_potentialborrower) && (address(this)==lr.creator()));

          
          reptoken.burntokens(_potentialborrower);               
     }     

     function approvereptokens(address _potentialborrower, uint _weisum) returns (bool success){
          reputationtokeninterface reptoken = reputationtokeninterface(reptokenaddress);
          success = (reptoken.nonlockedtokenscount(_potentialborrower) >= _weisum);
          return;             
     } 

     function() payable{
          createnewlendingrequest();
     }
}

contract lendingrequest {
     using safemath for uint256;
     
     address public mainaddress = 0x0;
     string public name = ;
     address public creator = 0x0;
     address public registraraddress = 0x0;

     
     uint public lenderfeeamount   = 0.01 ether;
     
     ledger ledger;

     enum state {
          waitingfordata,

          
          waitingfortokens,
          cancelled,

          
          waitingforlender,

          
          waitingforpayback,

          default,

          finished
     }

     enum type {
          tokenscollateral,
          enscollateral,
          repcollateral
     }

     state public currentstate = state.waitingfordata;
     type public currenttype = type.tokenscollateral;

     address public wheretosendfee = 0x0;
     uint public start = 0;

     
     address public borrower = 0x0;
     uint public wanted_wei = 0;
     uint public token_amount = 0;
     uint public premium_wei = 0;
     string public token_name = ;
     bytes32 public ens_domain_hash; 
     string public token_infolink = ;
     address public token_smartcontract_address = 0x0;
     uint public days_to_lend = 0;
     address public ensregistryaddress = 0;       
     address public lender = 0x0;


     function getborrower()constant returns(address out){
          out = borrower;
     }

     function getwantedwei()constant returns(uint out){
          out = wanted_wei;
     }

     function getpremiumwei()constant returns(uint out){
          out = premium_wei;
     }

     function gettokenamount()constant returns(uint out){
          out = token_amount;
     }

     function gettokenname()constant returns(string out){
          out = token_name;
     }

     function gettokeninfolink()constant returns(string out){
          out = token_infolink;
     }

     function gettokensmartcontractaddress()constant returns(address out){
          out = token_smartcontract_address;
     }

     function getdaystolen()constant returns(uint out){
          out = days_to_lend;
     }
     
     function getstate()constant returns(state out){
          out = currentstate;
          return;
     }

     function getlender()constant returns(address out){
          out = lender;
     }

     function isens()constant returns(bool out){
          out = (currenttype==type.enscollateral);
     }

     function isrep()constant returns(bool out){
          out = (currenttype==type.repcollateral);
     }


     function getensdomainhash()constant returns(bytes32 out){
          out = ens_domain_hash;
     }


     modifier byanyone(){
          _;
     }

     modifier onlybyledger(){
          require(ledger(msg.sender) == ledger);
          _;
     }

     modifier onlybymain(){
          require(msg.sender == mainaddress);
          _;
     }

     modifier byledgerormain(){
          require(msg.sender == mainaddress || ledger(msg.sender) == ledger);
          _;
     }

     modifier byledgermainorborrower(){
          require(msg.sender == mainaddress || ledger(msg.sender) == ledger || msg.sender == borrower);
          _;
     }

     modifier onlybylender(){
          require(msg.sender == lender);
          _;
     }

     modifier onlyinstate(state state){
          require(currentstate == state);
          _;
     }

     function lendingrequest(address _borrower, int _collateraltype){
          creator = msg.sender;
          ledger = ledger(msg.sender);

          borrower = _borrower;
          mainaddress = ledger.mainaddress();
          wheretosendfee = ledger.wheretosendfee();
          registraraddress = ledger.registraraddress();
          ensregistryaddress = ledger.ensregistryaddress();
                    
          
          if (_collateraltype == 0){
               currenttype = type.tokenscollateral;
          } else if(_collateraltype == 1){
               currenttype = type.enscollateral;
          } else if(_collateraltype == 2){
               currenttype = type.repcollateral;
          } else {
               revert();
          }
     }

     function changeledgeraddress(address new_)onlybyledger{
          ledger = ledger(new_);
     }

     function changemainaddress(address new_)onlybymain{
          mainaddress = new_;
     }


     function setdata(uint _wanted_wei, uint _token_amount, uint _premium_wei,
          string _token_name, string _token_infolink_, address _token_smartcontract_address, uint _days_to_lend, bytes32 _ens_domain_hash) byledgermainorborrower onlyinstate(state.waitingfordata)
     {
          wanted_wei = _wanted_wei;
          premium_wei = _premium_wei;
          token_amount = _token_amount; 
          token_name = _token_name;
          token_infolink = _token_infolink_;
          token_smartcontract_address = _token_smartcontract_address;
          days_to_lend = _days_to_lend;
          ens_domain_hash = _ens_domain_hash;

          if(currenttype==type.repcollateral){
               if(ledger.approvereptokens(borrower, wanted_wei)){
                    ledger.lockreptokens(borrower, wanted_wei);
                    currentstate = state.waitingforlender;
               }
          } else {
               currentstate = state.waitingfortokens;
          }
     }

     function cancell() byledgermainorborrower {
          
          require((currentstate==state.waitingfordata) || (currentstate==state.waitingforlender));

          if(currentstate==state.waitingforlender){
               
               releasetoborrower();
          }
          currentstate = state.cancelled;
     }

     
     function checktokens()byledgermainorborrower onlyinstate(state.waitingfortokens){
          require(currenttype==type.tokenscollateral);

          erc20token token = erc20token(token_smartcontract_address);

          uint tokenbalance = token.balanceof(this);
          if(tokenbalance >= token_amount){
               
               
               currentstate = state.waitingforlender;
          }
     }

     function checkdomain() onlyinstate(state.waitingfortokens){
          
          abstractens ens = abstractens(ensregistryaddress);
          if(ens.owner(ens_domain_hash)==address(this)){
               
               
               currentstate = state.waitingforlender;
               return;
          }
     }

     
     
     
     
     
     function() payable {
          if(currentstate == state.waitingforlender){
               waitingforlender();
          } else if(currentstate == state.waitingforpayback){
               waitingforpayback();
          } else {
               revert(); 
          }
     }

     
     function returntokens() byledgermainorborrower onlyinstate(state.waitingforlender){
          
          releasetoborrower();
          currentstate = state.finished;
     }

     function waitingforlender()payable onlyinstate(state.waitingforlender){
          if(msg.value < wanted_wei.add(lenderfeeamount)){
               revert();
          }

          
          wheretosendfee.transfer(lenderfeeamount);

          
          lender = msg.sender;     

          
          
          borrower.transfer(wanted_wei);

          currentstate = state.waitingforpayback;

          start = now;
     }

     
     
     
     
     function waitingforpayback()payable onlyinstate(state.waitingforpayback){
          if(msg.value < wanted_wei.add(premium_wei)){
               revert();
          }

          
          lender.transfer(msg.value);

          releasetoborrower(); 
          ledger.addreptokens(borrower,wanted_wei);
          currentstate = state.finished; 
     }

     
     function getneededsumbylender()constant returns(uint out){
          uint total = wanted_wei.add(lenderfeeamount);
          out = total;
          return;
     }

     
     function getneededsumbyborrower()constant returns(uint out){
          uint total = wanted_wei.add(premium_wei);
          out = total;
          return;
     }

     
     
     function requestdefault()onlyinstate(state.waitingforpayback){
          require(now >= (start + days_to_lend * 1 days));

          releasetolender(); 
          currentstate = state.default; 
     }

     function releasetolender() internal {
          if(currenttype==type.enscollateral){
               abstractens ens = abstractens(ensregistryaddress);
               registrar registrar = registrar(registraraddress);

               ens.setowner(ens_domain_hash,lender);
               registrar.transfer(ens_domain_hash,lender);
          }else if (currenttype==type.repcollateral){
               ledger.unlockreptokens(borrower, wanted_wei);
          }else{
               erc20token token = erc20token(token_smartcontract_address);
               uint tokenbalance = token.balanceof(this);
               token.transfer(lender,tokenbalance);
          }

          ledger.burnreptokens(borrower);
     }

     function releasetoborrower() internal {
          if(currenttype==type.enscollateral){
               abstractens ens = abstractens(ensregistryaddress);
               registrar registrar = registrar(registraraddress);
               ens.setowner(ens_domain_hash,borrower);
               registrar.transfer(ens_domain_hash,borrower);
          }else if (currenttype==type.repcollateral){
               ledger.unlockreptokens(borrower, wanted_wei);
          }else{
               erc20token token = erc20token(token_smartcontract_address);
               uint tokenbalance = token.balanceof(this);
               token.transfer(borrower,tokenbalance);
          }
     }
}

