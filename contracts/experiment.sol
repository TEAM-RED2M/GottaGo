// 보지 마세욧!!!    
    

pragma solidity ^0.4.24;
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract practice {
    
    uint[] a = [1,2,3];
    string[] b = ["asd", "asssss"];
    mapping (string => uint) ac;
    uint c;
    
    function asd() public returns (uint[]){
        return a;
    }
    
    function add() {
        a.push(1);
        a.push(2);
    }
    
    function getC() returns (uint) {
        return c;
    }
    
    modifier assssaa(address _a){
        assert(msg.sender == _a);
        _;
    }
    
    function getMap(string adccc) returns (uint) {
        return ac[adccc];
    }
    modifier timeIs(uint time) {
        require(time == 1991 years + 12 weeks + 1 days + 1 hours + 12 minutes + 1 seconds);
        _;
    }
    
}
