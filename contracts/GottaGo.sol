pragma solidity ^0.4.24;

import './MintableGottaGo.sol';

contract GottaGo is MintableGottaGo {
    
    
    uint initialBalance = 1000;
    
    mapping (address => Traveler) getTraveler;
    
    mapping (address => Place) getPlace;
    
    mapping (string => bool) existingId;
    mapping (address => bool) alreadyHaveId;
    
    mapping(string => mapping(string => address)) Login;
 
    struct Traveler {
        //address travelerWallet;
        string id;
        string password;
        mapping (address => uint) coolTime;
        uint[] wentPlaces;
        //string mostRecentVisit;
    }
    
   
    struct Place {
        string id;
        string password;
        string name;
        //address placeWallet;
        //mapping (string => uint) recentPlaceAdvantage;
        uint visitCount;
        uint popularity; 
        uint plainIncentive;
        uint idNumber;
        bool exists;
    }
    
   
    Place[] places;
    
    modifier onlyAdmin() {
        require(msg.sender == owner);
        _;
    }
    
    function myPlaces() public view returns (uint[]) {
        return getTraveler[msg.sender].wentPlaces;
    }
    function returnPlaceName(uint index) public view returns (string) {
        return places[index].name;
    }
    function isPlace(address _place) public view returns (bool) {
        return getPlace[_place].exists;
    }
    
    function returnLoginInfo(string _id, string _password) public view returns (bool) {
        return (Login[_id][_password] == msg.sender);
    }
    
    function changeInitialBalance(uint _newInit) onlyAdmin public {
        initialBalance = _newInit;
    }

    
    function newTraveler(string _id, string _password) public {
        //require(Login[_id][_password] == address(0x0), "ID already taken");
        Traveler memory temp;
        temp.id = _id;
        temp.password = _password;
        temp.wentPlaces = new uint[](0);
        //uint id = travelers.push(temp);
        getTraveler[msg.sender] = temp; 
        Login[_id][_password] = msg.sender;
        existingId[_id] = true;
        alreadyHaveId[msg.sender] = true;
    }
    
    function newPlace(string _name, uint _incentive, string _id, string _password) public {
        //require(Login[_id][_password] == address(0x0), "ID already taken");
        Place memory temp;
        temp.name = _name;
        temp.id = _id;
        temp.password = _password;
        temp.visitCount = 0;
        temp.popularity = 0;
        temp. plainIncentive = _incentive;
        temp.idNumber = places.length;
        temp.exists = true;
        transferFrom(owner, msg.sender, initialBalance);
        places.push(temp);
        getPlace[msg.sender] = temp;
        Login[_id][_password] = msg.sender;
        existingId[_id] = true;
        alreadyHaveId[msg.sender] = true;
    }
    
    
    function getToken(address _sender) public {
    //    require(now >= getTraveler[msg.sender].coolTime[_sender]);
      //  require(getPlace[_sender].exists==true,"Only transfer from a place");
        getTraveler[msg.sender].coolTime[_sender] = now + 2 days;

        uint amount;
       // if (getPlace[_sender].recentPlaceAdvantage[getTraveler[msg.sender].mostRecentVisit] != 0) {
     //       amount = getPlace[_sender].recentPlaceAdvantage[getTraveler[msg.sender].mostRecentVisit];
        //}
        
      //  else {
            amount = getPlace[_sender].plainIncentive;
   //     }
        
        transferFrom(_sender, msg.sender, amount);
        
        if(balances[_sender] <= 200){
            transferFrom(owner, _sender, 500);
            emit Transfer(owner, _sender, 500);
        }
        
        emit Transfer(_sender, msg.sender, amount);
        
        getTraveler[msg.sender].wentPlaces.push(getPlace[_sender].idNumber);
        getPlace[_sender].visitCount++;
        //getTraveler[msg.sender].mostRecentVisit = getPlace[_sender].name;
        
    }
    
    function payToken(address _market, uint _amount) public {
        transferFrom(msg.sender, _market, _amount);
    }
    
    //장소에 투표를 하는 함수
    function votePlace(address _place) public {
      //  require(alreadyVoted[_place][msg.sender]==false);
        getPlace[_place].popularity++;
      //  alreadyVoted[_place][msg.sender]==true;
    }
    
    function checkIfIdExists(string _id) public view returns (bool) {
        return existingId[_id];
    }
    
    function haveIdAlready() public view returns (bool) {
        return alreadyHaveId[msg.sender];
    }
    
    function coolTimeIsReady(address _place) public view returns (bool) {
        return (now >= getTraveler[msg.sender].coolTime[_place]);
    }
    
    function remainingCoolTime(address _place) public view returns (uint) {
        return getTraveler[msg.sender].coolTime[_place];
    }
    
    
    
}
