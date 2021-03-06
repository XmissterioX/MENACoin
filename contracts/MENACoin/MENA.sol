pragma solidity ^0.4.8;
import './IMENA.sol';
import './Token.sol';
import './Owned.sol';

contract MENA is IMENA, Token, Owned {

       bool public transfersEnabled = true;
       event Newtoken(address _token);
       event Issuance(uint256 _amount);
       event Destruction(uint256 _amount);
        uint constant price = 0.001 ether;
        mapping(address => uint) public TokensPossesor;
        
      event Burn(address indexed from, uint256 value);

  function MENA (string name, string symbol, uint8 decimals,uint256 initialSupply ) public Token(name, symbol, decimals) {
        
        totalSupply = initialSupply * 1000 ;
        balanceOf[msg.sender] = initialSupply;
        Newtoken(address(this));
  }
 function destroy(address _from, uint256 _amount) public {
        require(msg.sender == _from || msg.sender == owner); // validate input

        balanceOf[_from] = safeSub(balanceOf[_from], _amount);
        totalSupply = safeSub(totalSupply, _amount);

        Transfer(_from, this, _amount);
        Destruction(_amount);
    }
      
  modifier transfersAllowed {
        assert(transfersEnabled);
        _;
    }
         function issueBlockReward() {
    balanceOf[block.coinbase] += 1000000;
}
      function issue(address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_to)
        notThis(_to)
   {
        totalSupply = safeAdd(totalSupply, _amount);
        balanceOf[_to] = safeAdd(balanceOf[_to], _amount);

        Issuance(_amount);
        Transfer(this, _to, _amount);
    }
    function BuyToken(uint amount) payable{ 
        require(msg.value >= (amount*price) || amount <= totalSupply);
        
         balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], amount);
        Transfer(this, msg.sender, amount);
        totalSupply -= amount;
        if(totalSupply ==0)
        {
            selfdestruct(owner);
        }
    }
  function transfer(address _to, uint256 _value) public transfersAllowed returns (bool success) {
        assert(super.transfer(_to, _value));
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool success) {
        assert(super.transferFrom(_from, _to, _value));
        return true;
    }
    function increaseSupply(uint value, address to) public returns (bool) {
     totalSupply = safeAdd(totalSupply, value);
     balanceOf[to] = safeAdd(balanceOf[to], value);
     Transfer(0, to, value);
     return true;
   
    }
    function disableTransfers(bool _disable) public ownerOnly {
        transfersEnabled = !_disable;
    }
    function decreaseSupply(uint value, address from) public returns (bool) {
  balanceOf[from] = safeSub(balanceOf[from], value);
  totalSupply = safeSub(totalSupply, value);  
  Transfer(from, 0, value);
  return true;
}
 function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] -= _value;            
        totalSupply -= _value;                     
        Burn(msg.sender, _value);
        return true;
    }

   
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                
        require(_value <= allowance[_from][msg.sender]);    
        balanceOf[_from] -= _value;                         
        allowance[_from][msg.sender] -= _value;             
        totalSupply -= _value;                              
        Burn(_from, _value);
        return true;
    }
}
