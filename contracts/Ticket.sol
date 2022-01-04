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

    struct TicketItem {
        address payable owner;
        string ticketId;
        string name;
        string image;
        uint256 price;
        uint256 totalItemsAvailable;
        uint256 itemsSold;
    }

    // Maps ticket to its ticketItems
    mapping(string => TicketItem[]) public ticketItems;

    function getTicketsItemsLength(string memory _id)
        public
        view
        returns (uint256)
    {
        return ticketItems[_id].length;
    }

    function createTicketItem(
        string memory _ticketId,
        string memory _name,
        string memory _image,
        uint256 _price,
        uint256 _totalItemsAvailable
    ) public {
        uint256 _itemsSold = 0;

        TicketItem memory item = TicketItem(
            payable(msg.sender),
            _ticketId,
            _name,
            _image,
            _price,
            _totalItemsAvailable,
            _itemsSold
        );

        ticketItems[_ticketId].push(item);
    }
 function getTicketItem(string memory _ticket, uint256 _index)
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            string memory,
            uint256,
            uint256,
            uint256
        )
    {
        require(_index >= 0);
        require(
            ticketItems[_ticket].length > 0,
            "This ticket has no items available for sale!"
        );

        TicketItem storage item = ticketItems[_ticket][_index];

        return (
            item.owner,
            item.ticketId,
            item.name,
            item.image,
            item.price,
            item.totalItemsAvailable,
            item.itemsSold
        );
    }
    function buyTicketItem(string memory _ticket, uint256 _index)
        public
        payable
    {
        TicketItem storage item = ticketItems[_ticket][_index];

        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                item.owner,
                item.price
            ),
            "Transfer failed"
        );
        // update sold ticket item
        item.itemsSold++;
    }

    struct PurchasedTicket {
        string ticketId;
        uint256 boughtOn;
        bool isValid;
    }

    // Maps purchased tickets to a user
    mapping(address => PurchasedTicket[]) public userTickets;

    function getUserTicketsLength(address _owner)
        public
        view
        returns (uint256)
    {
        return userTickets[_owner].length;
    }

    function createPurchasedTicket(string memory _ticketId) public {
        uint256 _boughtOn = block.timestamp;
        bool _isValid = true;

        PurchasedTicket memory item = PurchasedTicket(
            _ticketId,
            _boughtOn,
            _isValid
        );

        userTickets[msg.sender].push(item);
    }
    function getPurchasedTicket(address _owner, uint256 _index)
        public
        view
        returns (
            string memory,
            uint256,
            bool
        )
    {
        require(_index >= 0);
        require(
            userTickets[_owner].length > 0,
            "You have no tickets for this address."
        );

        PurchasedTicket storage item = userTickets[_owner][_index];

        return (item.ticketId, item.boughtOn, item.isValid);
    }

    struct PurchasedTicketItem {
        string ticketItemId;
        uint256 boughtOn;
    }

    // Maps purchased tickets to a user
    mapping(address => PurchasedTicketItem[]) public userTicketItems;
    function getUserTicketItemsLength(address _owner)
        public
        view
        returns (uint256)
    {
        return userTicketItems[_owner].length;
    }

    /**
     * @dev function called after a ticketItem is bought
     */
    function createPurchasedTicketItem(string memory _ticketItemId) public {
        uint256 _boughtOn = block.timestamp;

        PurchasedTicketItem memory item = PurchasedTicketItem(
            _ticketItemId,
            _boughtOn
        );

        userTicketItems[msg.sender].push(item);
    }

    /**
     * @dev function called to get a purchased ticket item
     */
    function getPurchasedTicketItem(address _owner, uint256 _index)
        public
        view
        returns (string memory, uint256)
    {
        require(_index >= 0);
        require(
            userTicketItems[_owner].length > 0,
            "You have no ticket items bought for this address."
        );

        PurchasedTicketItem storage item = userTicketItems[_owner][_index];

        return (item.ticketItemId, item.boughtOn);
    }
}