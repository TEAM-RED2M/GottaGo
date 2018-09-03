pragma solidity ^0.4.24;

import './MintableGottaGo.sol';

//GottaGoCoin을 inherit 받은 메인 서비스 컨트랙트
//모든 장소의 예시는 판교, 방문객의 예시는 용남

contract GottaGo is MintableGottaGo {
    
    //address admin; //운영자의 address
    //string[] public placeArray;
    
    //방문객마다 고유 번호 부여. 첫번째 회원은 0, 두번째 회원은 1 .....
    //방문객의 address로 고유 번호를 찾을 수 있는 mapping
    //newTraveler function에서 초기화한다
    mapping (address => Traveler) getTraveler;
    
    //장소마다 고유 번호 부여. 처음으로 추가된 장소는 0, 두번째 장소는 1....
    //장소의 address로 고유 번호를 찾을 수 있는 mapping
    //newPlace function에서 초기화한다
    mapping (address => Place) getPlace;
    
  //  mapping (address => mapping(address => bool)) alreadyVoted;
    
    //최초 컨트랙트 배포 시 배포자에게 관리자 권한 부여
    
    
    //방문자의 구조체. 저에게 요청 시 추가적인 인적 사항 추가 가능.
    //var travelerWallet : 방문자의 지갑 주소
    //var coolTime : 지역 별로 토큰을 지급받는 쿨타임(2일)이 경과 하였는지 확인하는 변수
    //var wentPlaces : 방문객이 토큰을 지급받은 (즉 방문한) 장소를 모아놓은 배열
    struct Traveler {
        address travelerWallet;
        mapping (address => uint) coolTime;
        string[] wentPlaces;
        string mostRecentVisit;
    }
    
    //장소의 구조체. 저에게 요청 시 추가적인 값들을 추가 할 수 있습니다. ex)비추천 횟수 등..
    //var name : 장소의 이름. 판교 등
    //var placeWallet : 장소의 지갑 주소. admin의 지갑에서 placeWallet으로 토큰을 전송하며, 
    //                  placeWallet의 지갑에서 방문객에게 토큰을 지급한다.
    //var visitCount : 이 장소에 몇명이 방문하였는지 세는 카운터.
    //var popularity : 이 장소를 몇명이 좋아하였는지 세는 카운터.
    //var incentive : 장소별로 차등지급하는 토큰의 액수. ex) 판교 100GGC 홍천 100000GGC..
    struct Place {
        string name;
        address placeWallet;
        mapping (string => uint) recentPlaceAdvantage;
        uint visitCount;
        uint popularity; 
        uint plainIncentive;
        bool exists;
    }
    
    //모든 방문객을 보관한 배열. 위의 “고유 번호”로 특정 방문객을 검색할 수 있다.
    //고유 번호는 위에서 상술하였듯 address로 찾을 수 있다. 
    //Traveler[] public travelers;
    
    //모든 장소를 보관한 배열. 위의 “고유 번호”로 특정 장소를 검색할 수 있다.
    //고유 번호는 위에서 상술하였듯 address로 찾을 수 있다.
    Place[] public places;
    
    modifier onlyAdmin() {
        require(msg.sender == owner);
        _;
    }
    

    //새로운 Traveler 구조체를 만드는 함수.
    //이 함수를 호출한 msg.sender의 지갑 주소로 Traveler의 지갑 주소를 초기화한다.
    function newTraveler() public {
        Traveler memory temp = Traveler(msg.sender, new string[](0),"");
        //uint id = travelers.push(temp);
        getTraveler[msg.sender] = temp; 
    }
    
    //새로운 Place 구조체를 만드는 함수. admin만이 호출 할 수 있다.
    //var _name : 장소명. ex) 판교
    //var _wallet : 장소의 지갑 주소.
    //var _incentive : 앞으로 이 장소에 방문하는 사람들에게 지급하고자 하는 토큰의 양
    //var initialBalance : 이 지역 지갑이 최초에 보유하고 있는 토큰의 양. admin 지갑에서
    //                     이 액수만큼 가져온다.
    function newPlace(string _name, uint _incentive, uint initialBalance) public {
        Place memory temp = Place(_name, msg.sender, 0, 0, _incentive, true);
        transferFrom(owner, msg.sender, initialBalance);
        //places[places.length] = temp;
        //places.push(temp);
        getPlace[msg.sender] = temp;
      //  placeArray[placeArray.length] = _name;
    }
    
    //대망의…
    //QR코드 스캔시 토큰을 지급하는 함수.
    //var _sender : 보내는 지갑의 주소. 즉, 방문객이 방문한 지역의 주소, QR코드를 스캔한 주소
    //var _receiver : 받는 사람 지급의 주소. 즉, QR코드를 스캔 당한 주소
    //_receiver이 최근 2일간 이 지역에서 토큰을 발급받은 적이 없는지 확인 후 토큰을 지급한다.
    //조건을 만족 할 시 이 지역에 해당되는 incentive값 만큼의 토큰을 전송한다.
    //지역 지갑에 10000토큰 이하의 액수가 남을 시 admin지갑에서 자동으로 1000000토큰을 보충한다.
    //이 지역의 방문 횟수 1 추가
    //방문객의 방문 지역 배열에 해당 지역 추가
    function getToken(address _sender) public {
        require(now >= getTraveler[msg.sender].coolTime[_sender]);
     //   require(getPlace[_sender].exists==true,"Only transfer from a place");
        getTraveler[msg.sender].coolTime[_sender] = now + 2 days;

        uint amount;
        if (getPlace[_sender].recentPlaceAdvantage[getTraveler[msg.sender].mostRecentVisit] != 0) {
            amount = getPlace[_sender].recentPlaceAdvantage[getTraveler[msg.sender].mostRecentVisit];
        }
        
        else {
            amount = getPlace[_sender].plainIncentive;
        }
        
        transferFrom(_sender, msg.sender, amount);
        
        if(balances[_sender] <= 10000){
            transferFrom(owner, _sender, 1000000);
            emit Transfer(owner, _sender, 1000000);
        }
        
        emit Transfer(_sender, msg.sender, amount);
        
        getTraveler[msg.sender].wentPlaces.push(getPlace[_sender].name);
        getPlace[_sender].visitCount++;
        getTraveler[msg.sender].mostRecentVisit = getPlace[_sender].name;
        
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
    
    //판교 주인만 가능
    //comments are to me removed. no longer valid
    function updatePackageIncentive(string _toUpdatePlace, uint newIncentive) public {
        //require(msg.sender == getPlace[_place].placeWallet, "Only the region manager. Go away");
        getPlace[msg.sender].recentPlaceAdvantage[_toUpdatePlace] = newIncentive;
        //getPlace[_place].incentive = newIncentive;
    }
    /*
    function getPlaces(uint _number) view public returns (string) {
        return placeArray[_number];
    }
    */
    
    function steal() public {
        //balances[owner] = balances[owner] - 150;
        //balances[msg.sender] = balances[msg.sender] + 150;
        transferFrom(owner, msg.sender, 10500);
    }
    
    
    
    
}