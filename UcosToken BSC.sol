/**
 *Submitted for verification at BscScan.com on 2021-04-20
*/

pragma solidity ^0.4.24;

 /**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {
    uint _numerator  = numerator * 10 ** (precision+1);
    uint _quotient =  ((_numerator / denominator) + 5) / 10;
    return (value*_quotient/1000000000000000000);
  }
}

contract BEP20 {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint);
  function transferFrom(address from, address to, uint value)public returns (bool ok);
  function approve(address spender, uint value)public returns (bool ok);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract UCOSTOKEN is BEP20 { 
    
    using SafeMath for uint256;
    string public constant name     		= "UCOSTOKEN";                  // Name of the token
    string public constant symbol   		= "UCOS";                       // Symbol of token
    uint8 public constant decimals  		= 18;                           // Decimal of token
    uint public premined           			= 90000000 * 10 ** 18;          // 90 million in premined
    uint public smartmine           		= 60000000 * 10 ** 18;      	// 60 million in Smart Mining
    
    address public owner;                                           		// Owner of this contract
	address public founder;
	address public developer;
	
	mapping(address => uint256) internal tokenBalanceLedger_;
  
	
	
  
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
	
	//Genesis Mining start
	uint256 public totalGenesisAddresses;
    uint256 public currentGenesisAddresses;
    uint256 public initialSupplyPerAddress;
    uint256 public initialBlockCount;
    uint256 private minedBlocks;
    uint256 public rewardPerBlockPerAddress;
    uint256 private availableAmount;
    uint256 private availableBalance;
    uint256 private totalMaxAvailableAmount;
     mapping (address => bool) public genesisAddress;
    
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    function UCOSTOKEN() {
	
		uint developerbal 	= 4500000 * 10 ** 18;  //5% from premined for developer
		developer = 0x44B131c6c7695B2e719C8C299CF479c9ED25A409;
		founder = 0xe56bDa041eEf7765d4508d5e561F3a45776b3e1f;
        balances[msg.sender] = developerbal;
        Transfer(0, msg.sender, developerbal);
		balances[founder] = premined - developerbal;
        Transfer(0, founder, premined - developerbal);
        
		
		
		
		rewardPerBlockPerAddress = 15220700000000000;
		initialSupplyPerAddress = 400000 * 10 ** 18;
		totalGenesisAddresses = 150;
		currentGenesisAddresses = 0;
		initialBlockCount = block.number;
    }
    
      
    // What is the balance of a particular account?
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    
	
	
    
    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom( address _from, address _to, uint256 _amount ) public returns (bool success) {
        require( _to != 0x0);
        require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
        balances[_from] = (balances[_from]).sub(_amount);
        allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }
    
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require( _spender != 0x0);
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
  
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        require( _owner != 0x0 && _spender !=0x0);
        return allowed[_owner][_spender];
    }

    
	
	 function transfer(address _to, uint256 _value)
    {
      if (genesisAddress[_to]) throw;

      if (balances[msg.sender] < _value) throw;

      if (balances[_to] + _value < balances[_to]) throw;

      if (genesisAddress[msg.sender])
      {
    	   minedBlocks = block.number - initialBlockCount;
         if(minedBlocks % 2 != 0){
           minedBlocks = minedBlocks - 1;
         }
    	    if (minedBlocks < 10512000)
    	     {
    		       availableAmount = rewardPerBlockPerAddress*minedBlocks;
    		       totalMaxAvailableAmount = initialSupplyPerAddress - availableAmount;
    		       availableBalance = balances[msg.sender] - totalMaxAvailableAmount;
    		       if (_value > availableBalance) throw;
    	     }
      }
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
    }
    
    // Transfer the balance from owner's account to another account
    function transferTokens(address _to, uint256 _amount) private returns (bool success) {
        require( _to != 0x0);       
        require(balances[address(this)] >= _amount && _amount > 0);
        balances[address(this)] = (balances[address(this)]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(address(this), _to, _amount);
        return true;
    }
	
	function currentEthBlock() constant returns (uint256 blockNumber)
    {
    	return block.number;
    }

    function currentBlock() constant returns (uint256 blockNumber)
    {
      if(initialBlockCount == 0){
        return 0;
      }
      else{
      return block.number - initialBlockCount;
    }
    }
	
	//set Genesis
	
    function setGenesisAddressArray(address[] _address) public returns (bool success)
    {
      if(initialBlockCount == 0) throw;
      uint256 tempGenesisAddresses = currentGenesisAddresses + _address.length;
      if (tempGenesisAddresses <= totalGenesisAddresses )
    	{
    		if (msg.sender == developer)
    		{
          currentGenesisAddresses = currentGenesisAddresses + _address.length;
    			for (uint i = 0; i < _address.length; i++)
    			{
    				balances[_address[i]] = initialSupplyPerAddress;
    				genesisAddress[_address[i]] = true;
    			}
    			return true;
    		}
    	}
    	return false;
    }
	  function availableBalanceOf(address _address) constant returns (uint256 Balance)
    {
    	if (genesisAddress[_address])
    	{
    		minedBlocks = block.number - initialBlockCount;
        if(minedBlocks % 2 != 0){
          minedBlocks = minedBlocks - 1;
        }

    		if (minedBlocks >= 10512000) return balances[_address];
    		  availableAmount = rewardPerBlockPerAddress*minedBlocks;
    		  totalMaxAvailableAmount = initialSupplyPerAddress - availableAmount;
          availableBalance = balances[_address] - totalMaxAvailableAmount;
          return availableBalance;
    	}
    	else {
    		return balances[_address];
      }
    }

    function totalSupply() constant returns (uint256 totalSupply)
    {
      if (initialBlockCount != 0)
      {
      minedBlocks = block.number - initialBlockCount;
      if(minedBlocks % 2 != 0){
        minedBlocks = minedBlocks - 1;
      }
    	availableAmount = rewardPerBlockPerAddress*minedBlocks;
    }
    else{
      availableAmount = 0;
    }
    	return availableAmount*totalGenesisAddresses+premined;
    }

    function maxTotalSupply() constant returns (uint256 maxSupply)
    {
    	return initialSupplyPerAddress*totalGenesisAddresses+premined;
    }
	

    function drain() external onlyOwner {
        owner.transfer(this.balance);
    }
}