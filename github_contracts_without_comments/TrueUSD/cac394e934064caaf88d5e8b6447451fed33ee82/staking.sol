pragma solidity ^0.4.22;


import ;
import ;
import ;

contract staking is ownable {
    using safemath for uint;
    
    uint bignumber = 10**18;
    uint decimal = 10**3;

    struct stakinginfo {
        uint amount;
        bool requested;
        uint releasedate;
    }
    
    
    
    mapping (address => bool) public allowedtokens;
    

    mapping (address => mapping(address => stakinginfo)) public stakemap; 
    mapping (address => mapping(address => uint)) public usercummrewardperstake; 
    mapping (address => uint) public tokencummrewardperstake; 
    mapping (address => uint) public tokentotalstaked; 
    
    mapping (address => address) public mediator;
    
    
    modifier isvalidtoken(address _tokenaddr){
        require(allowedtokens[_tokenaddr]);
        _;
    }
    modifier ismediator(address _tokenaddr){
        require(mediator[_tokenaddr] == msg.sender);
        _;
    }

    address public staketokenaddr;
    
    
    constructor(address _tokenaddr) public{
        staketokenaddr= _tokenaddr;
    }
    
    
    
    
    function addtoken( address _tokenaddr) onlyowner external {
        allowedtokens[_tokenaddr] = true;
    }
    
    
    function removetoken( address _tokenaddr) onlyowner external {
        allowedtokens[_tokenaddr] = false;
    }

    
    
    function stake(uint _amount, address _tokenaddr) isvalidtoken(_tokenaddr) external returns (bool){
        require(_amount != 0);
        
        
        if (stakemap[_tokenaddr][msg.sender].amount ==0){
            stakemap[_tokenaddr][msg.sender].amount = _amount;
            usercummrewardperstake[_tokenaddr][msg.sender] = tokencummrewardperstake[_tokenaddr];
        }else{
            claim(_tokenaddr, msg.sender);
            stakemap[_tokenaddr][msg.sender].amount = stakemap[_tokenaddr][msg.sender].amount.add( _amount);
        }
        tokentotalstaked[_tokenaddr] = tokentotalstaked[_tokenaddr].add(_amount);
        return true;
    }
    
    
    
    function distribute(uint _reward,address _tokenaddr) isvalidtoken(_tokenaddr) external returns (bool){
        require(tokentotalstaked[_tokenaddr] != 0);
        uint reward = _reward.mul(bignumber); 
        uint rewardaddedpertoken = reward/tokentotalstaked[_tokenaddr];
        tokencummrewardperstake[_tokenaddr] = tokencummrewardperstake[_tokenaddr].add(rewardaddedpertoken);
        return true;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    event claimed(uint amount);
    
    function claim(address _tokenaddr, address _receiver) isvalidtoken(_tokenaddr)  public returns (uint) {
        uint stakedamount = stakemap[_tokenaddr][msg.sender].amount;
        
        uint amountowedpertoken = tokencummrewardperstake[_tokenaddr].sub(usercummrewardperstake[_tokenaddr][msg.sender]);
        uint claimableamount = stakedamount.mul(amountowedpertoken); 
        claimableamount = claimableamount.mul(decimal); 
        claimableamount = claimableamount.div(bignumber); 
        usercummrewardperstake[_tokenaddr][msg.sender]=tokencummrewardperstake[_tokenaddr];
        
        
        
        
        
        emit claimed(claimableamount);
        return claimableamount;

    }
    
    
    
    function initwithdraw(address _tokenaddr) isvalidtoken(_tokenaddr)  external returns (bool){
        require(stakemap[_tokenaddr][msg.sender].amount >0 );
        require(! stakemap[_tokenaddr][msg.sender].requested );
        stakemap[_tokenaddr][msg.sender].releasedate = now + 4 weeks;
        return true;

    }
    
    
    
    function finalizewithdraw(uint _amount, address _tokenaddr) isvalidtoken(_tokenaddr)  external returns(bool){
        require(stakemap[_tokenaddr][msg.sender].amount >0 );
        require(stakemap[_tokenaddr][msg.sender].requested );
        require(now > stakemap[_tokenaddr][msg.sender].releasedate );
        claim(_tokenaddr, msg.sender);
        require(erc20(_tokenaddr).transfer(msg.sender,_amount));
        tokentotalstaked[_tokenaddr] = tokentotalstaked[_tokenaddr].sub(_amount);
        stakemap[_tokenaddr][msg.sender].requested = false;
        return true;
    }
    
    function releasestake(address _tokenaddr, address[] _stakers, uint[] _amounts,address _dest) ismediator(_tokenaddr) isvalidtoken(_tokenaddr) constant external returns (bool){
        require(_stakers.length == _amounts.length);
        for (uint i =0; i< _stakers.length; i++){
            require(erc20(_tokenaddr).transfer(_dest,_amounts[i]));
            stakemap[_tokenaddr][_stakers[i]].amount = _amounts[i];
        }
        return true;
        
    }
}
