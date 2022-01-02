// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Tiket {
    uint256 internal ticketsLength = 0;
    address internal cUdstAddress =  0x3B00Ef435fA4FcFF5C209a37d1f3dcff37c705aD;

    modifier onlyTicketOwner(uint256 _index) {
        Ticket storage ticket = tickets[_index];
        require(
            msg.sender == ticket.owner,
            "only the owner of this tickete can call this function"
        );
        _;
    }

    struct Ticket {
        address payable owner;
        string name;
        string date;
        string venue;
        string time;
        string details;
        string image;
        uint256 createdAt;
        uint256 price;
        uint256 totalAvailable;
        uint256 ticketsSold;
    }
    
    mapping(uint256 => Ticket) internal tickets;

    function getTicketsLength() public view returns (uint256) {
        return (ticketsLength);
    }

    function validateTicketData(
        string memory _name,
        string memory _venue,
        string memory _details,
        string memory _image,
        uint256 _price
    ) internal pure {
        require(bytes(_name).length > 1, "Please enter a valid ticket name");
        require(bytes(_venue).length > 1, "Please enter a valid ticket name");
        require(bytes(_details).length > 1, "Please enter a valid ticket name");
        require(bytes(_image).length > 1, "Please enter a valid ticket name");
        require(_price > 0, "Please enter a valid ticket name");
    }

    function createTicket(
        string memory _name,
        string memory _date,
        string memory _venue,
        string memory _time,
        string memory _details,
        string memory _image,
        uint256 _price,
        uint256 _totalAvailable
    ) public {
        validateTicketData(_name, _venue, _details, _image, _price);
        uint256 _ticketsSold = 0;
        uint256 _createdAt = block.timestamp;
        tickets[ticketsLength] = Ticket(
            payable(msg.sender),
            _name,
            _date,
            _venue,
            _time,
            _details,
            _image,
            _createdAt,
            _price,
            _totalAvailable,
            _ticketsSold
        );
        ticketsLength++;
    }

    function editTicket(
        uint256 _index,
        string memory _name,
        string memory _date,
        string memory _venue,
        string memory _time,
        string memory _details,
        string memory _image,
        uint256 _price,
        uint256 _totalAvailable
    ) public onlyTicketOwner(_index) {
        validateTicketData(_name, _venue, _details, _image, _price);
        Ticket storage ticket = tickets[_index];
        uint256 _ticketsSold = ticket.ticketsSold;
        uint256 _createdAt = ticket.createdAt;
        ticket.name = _name;
        ticket.date = _date;
        ticket.venue = _venue;
        ticket.time = _time;
        ticket.details = _details;
        ticket.image = _image;
        ticket.createdAt = _createdAt;
        ticket.price = _price;
        ticket.totalAvailable = _totalAvailable;
        ticket.ticketsSold = _ticketsSold;
    }

    function getTicket(uint256 _index)
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Ticket storage ticket = tickets[_index];
        return (
            ticket.owner,
            ticket.name,
            ticket.date,
            ticket.venue,
            ticket.time,
            ticket.details,
            ticket.image,
            ticket.createdAt,
            ticket.price,
            ticket.totalAvailable,
            ticket.ticketsSold
        );
    }

    function buyTicket(uint256 _index) public payable {
        require(
            IERC20(cUdstAddress).transferFrom(
                msg.sender,
                tickets[_index].owner,
                tickets[_index].price
            ),
            "Transfer failed"
        );
        tickets[_index].ticketsSold++;
    }

}