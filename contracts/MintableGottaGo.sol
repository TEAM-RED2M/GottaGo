pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./StandardToken.sol";

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) hasMintPermission canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

contract MintableGottaGo is MintableToken {
    
    string coinName;                   
    string symbol;                 
    address adminWallet;
    uint initialQuantity = 2000000000000000000;
    
    constructor() public {
        coinName = "Gotta Go";
        symbol = "GOT";
        totalSupply_ = initialQuantity;
        balances[owner] = initialQuantity;
        emit Transfer(address(0x0), owner, initialQuantity);                 
    }
    
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }
    
}