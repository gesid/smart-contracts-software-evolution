pragma solidity 0.4.23;





import ;




contract nexotoken is token {

	
	string constant public name = ;
	string constant public symbol = ;
	uint8  constant public decimals = 18;


	
	


	

	
	

	address public investorsallocation = address(0xffffffffffffffffffffffffffffffffffffffff);
	uint256 public investorstotal = 525000000e18;


	

	
	
	
	

	address public overdraftallocation = address(0x1111111111111111111111111111111111111111);
	uint256 public overdrafttotal = 250000000e18;
	uint256 public overdraftperiodamount = 41666666e18;
	uint256 public overdraftunvested = 4e18;
	uint256 public overdraftcliff = 5 * 30 days;
	uint256 public overdraftperiodlength = 30 days;
	uint8   public overdraftperiodsnumber = 6;


	

	
	
	

	address public teamallocation  = address(0x2222222222222222222222222222222222222222);
	uint256 public teamtotal = 112500000e18;
	uint256 public teamperiodamount = 7031250e18;
	uint256 public teamunvested = 0;
	uint256 public teamcliff = 0;
	uint256 public teamperiodlength = 3 * 30 days;
	uint8   public teamperiodsnumber = 16;



	

	
	
	
	


	address public communityallocation  = address(0x3333333333333333333333333333333333333333);
	uint256 public communitytotal = 60000000e18;
	uint256 public communityperiodamount = 8333333e18;
	uint256 public communityunvested = 10000002e18;
	uint256 public communitycliff = 0;
	uint256 public communityperiodlength = 3 * 30 days;
	uint8   public communityperiodsnumber = 6;



	

	
	
	
	

	address public advisersallocation  = address(0x4444444444444444444444444444444444444444);
	uint256 public adviserstotal = 52500000e18;
	uint256 public advisersperiodamount = 2291666e18;
	uint256 public advisersunvested = 25000008e18;
	uint256 public adviserscliff = 0;
	uint256 public advisersperiodlength = 30 days;
	uint8   public advisersperiodsnumber = 12;


	

	function nexotoken() public {
		
		totalsupply = 1000000000e18;

		balances[investorsallocation] = investorstotal;
		balances[overdraftallocation] = overdrafttotal;
		balances[teamallocation] = teamtotal;
		balances[communityallocation] = communitytotal;
		balances[advisersallocation] = adviserstotal;

		
		allowed[investorsallocation][msg.sender] = investorstotal;
		allowed[overdraftallocation][msg.sender] = overdraftunvested;
		allowed[communityallocation][msg.sender] = communityunvested;
		allowed[advisersallocation][msg.sender] = advisersunvested;
	}

	

	function distributeinvestorstokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner
	{
		require(transferfrom(investorsallocation, _to, _amountwithdecimals));
	}

	

	function withdrawoverdrafttokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner
	{
		allowed[overdraftallocation][msg.sender] = allowance(overdraftallocation, msg.sender);
		require(transferfrom(overdraftallocation, _to, _amountwithdecimals));
	}

	function withdrawteamtokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner 
	{
		allowed[teamallocation][msg.sender] = allowance(teamallocation, msg.sender);
		require(transferfrom(teamallocation, _to, _amountwithdecimals));
	}

	function withdrawcommunitytokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner 
	{
		allowed[communityallocation][msg.sender] = allowance(communityallocation, msg.sender);
		require(transferfrom(communityallocation, _to, _amountwithdecimals));
	}

	function withdrawadviserstokens(address _to, uint256 _amountwithdecimals)
		public
		onlyowner 
	{
		allowed[advisersallocation][msg.sender] = allowance(advisersallocation, msg.sender);
		require(transferfrom(advisersallocation, _to, _amountwithdecimals));
	}

	
	function allowance(address _owner, address _spender)
		public
		view
		returns (uint256 remaining)
	{   
		if (_spender != owner) {
			return allowed[_owner][_spender];
		}

		uint256 unlockedtokens;
		uint256 spenttokens;

		if (_owner == overdraftallocation) {
			unlockedtokens = _calculateunlockedtokens(
				overdraftcliff,
				overdraftperiodlength,
				overdraftperiodamount,
				overdraftperiodsnumber,
				overdraftunvested
			);
			spenttokens = sub(overdrafttotal, balanceof(overdraftallocation));
		} else if (_owner == teamallocation) {
			unlockedtokens = _calculateunlockedtokens(
				teamcliff,
				teamperiodlength,
				teamperiodamount,
				teamperiodsnumber,
				teamunvested
			);
			spenttokens = sub(teamtotal, balanceof(teamallocation));
		} else if (_owner == communityallocation) {
			unlockedtokens = _calculateunlockedtokens(
				communitycliff,
				communityperiodlength,
				communityperiodamount,
				communityperiodsnumber,
				communityunvested
			);
			spenttokens = sub(communitytotal, balanceof(communityallocation));
		} else if (_owner == advisersallocation) {
			unlockedtokens = _calculateunlockedtokens(
				adviserscliff,
				advisersperiodlength,
				advisersperiodamount,
				advisersperiodsnumber,
				advisersunvested
			);
			spenttokens = sub(adviserstotal, balanceof(advisersallocation));
		} else {
			return allowed[_owner][_spender];
		}

		return sub(unlockedtokens, spenttokens);
	}

	
	function confirmownership()
		public
		onlypotentialowner
	{   
		
		allowed[investorsallocation][owner] = 0;

		
		allowed[investorsallocation][msg.sender] = balanceof(investorsallocation);

		
		allowed[overdraftallocation][owner] = 0;
		allowed[teamallocation][owner] = 0;
		allowed[communityallocation][owner] = 0;
		allowed[advisersallocation][owner] = 0;

		super.confirmownership();
	}

	function _calculateunlockedtokens(
		uint256 _cliff,
		uint256 _periodlength,
		uint256 _periodamount,
		uint8 _periodsnumber,
		uint256 _unvestedamount
	)
		private
		view
		returns (uint256) 
	{
		
		if (now < add(creationtime, _cliff)) {
			return _unvestedamount;
		}
		
		uint256 periods = div(sub(now, add(creationtime, _cliff)), _periodlength);
		periods = periods > _periodsnumber ? _periodsnumber : periods;
		return add(_unvestedamount, mul(periods, _periodamount));
	}
}
pragma solidity 0.4.21;





import ;
import ;
import ;



contract standardtoken is abstracttoken, owned, safemath {

	
	mapping (address => uint256) internal balances;
	mapping (address => mapping (address => uint256)) internal allowed;
	uint256 public totalsupply;

	
	
	
	
	function transfer(address _to, uint256 _value) public returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}

	
	
	
	
	function transferfrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(allowed[_from][msg.sender] >= _value);
		allowed[_from][msg.sender] = _value;

		return _transfer(_from, _to, _value);
	}

	
	
	function balanceof(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

	
	
	
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		emit approval(msg.sender, _spender, _value);
		return true;
	}

	
	
	
	
	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

	
	function _transfer(address _from, address _to, uint256 _value) private returns (bool success) {
		require(_to != address(0));
		require(balances[_from] >= _value);
		balances[_from] = _value;
		balances[_to] = add(balances[_to], _value);
		emit transfer(_from, _to, _value);
		return true;
	}
}
pragma solidity 0.4.21;






contract owned {

	address public owner = msg.sender;
	address public potentialowner;

	modifier onlyowner {
		require(msg.sender == owner);
		_;
	}

	modifier onlypotentialowner {
		require(msg.sender == potentialowner);
		_;
	}

	event newowner(address old, address current);
	event newpotentialowner(address old, address potential);

	function setowner(address _new)
		public
		onlyowner
	{
		emit newpotentialowner(owner, _new);
		potentialowner = _new;
	}

	function confirmownership()
		public
		onlypotentialowner
	{
		emit newowner(owner, potentialowner);
		owner = potentialowner;
		potentialowner = address(0);
	}
}
pragma solidity 0.4.21;





import ;




contract token is standardtoken {

	
	uint256 public creationtime;

	function token() public {
		
		creationtime = now;
	}

	
	function transfererc20token(abstracttoken _token, address _to, uint256 _value)
		public
		onlyowner
		returns (bool success)
	{
		require(_token.balanceof(address(this)) >= _value);
		uint256 receiverbalance = _token.balanceof(_to);
		require(_token.transfer(_to, _value));

		uint256 receivernewbalance = _token.balanceof(_to);
		assert(receivernewbalance == add(receiverbalance, _value));

		return true;
	}

	
	function increaseapproval(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = add(allowed[msg.sender][_spender], _value);
		emit approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	
	function decreaseapproval(address _spender, uint256 _value) public returns (bool success) {
		uint256 oldvalue = allowed[msg.sender][_spender];
		if (_value > oldvalue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = sub(oldvalue, _value);
		}
		emit approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
}
pragma solidity 0.4.21;









contract safemath {
	
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return a / b;
	}

	
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a  b;
	}

	
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}

	
	function pow(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a ** b;
		assert(c >= a);
		return c;
	}
}
pragma solidity 0.4.21;







contract abstracttoken {
	function balanceof(address owner) public view returns (uint256 balance);
	function transfer(address to, uint256 value) public returns (bool success);
	function transferfrom(address from, address to, uint256 value) public returns (bool success);
	function approve(address spender, uint256 value) public returns (bool success);
	function allowance(address owner, address spender) public view returns (uint256 remaining);

	event transfer(address indexed from, address indexed to, uint256 value);
	event approval(address indexed owner, address indexed spender, uint256 value);
}