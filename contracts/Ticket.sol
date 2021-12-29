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
}