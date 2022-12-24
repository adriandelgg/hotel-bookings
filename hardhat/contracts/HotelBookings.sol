// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract HotelBookings is Ownable {
	// The total amount of rooms available to book.
	uint public totalRooms;
	// The Ether amount in wei that each room will cost.
	uint public costPerRoom;

	// Checks if room number is booked
	mapping(uint => bool) public isRoomBooked;

	// Room number to time of checkout
	mapping(uint => uint) public checkoutDate;

	receive() external payable {}

	fallback() external payable {}

	event RoomBooked(uint roomNum, uint totalNights, uint checkoutDate);

	constructor(uint _totalRooms, uint _costPerRoom) payable {
		totalRooms = _totalRooms;
		costPerRoom = _costPerRoom;
	}

	function estimateCost(uint _totalNights) public view returns (uint) {
		return _totalNights * costPerRoom;
	}

	function bookRoom(uint _roomNum, uint _totalNights) external payable {
		require(_roomNum < totalRooms, "Room number does not exist.");
		require(!isRoomBooked[_roomNum], "Room is already booked.");
		require(
			msg.value == estimateCost(_totalNights),
			"Incorrect amount of Ether sent for booking."
		);
		isRoomBooked[_roomNum] = true;
		uint _checkoutDate = block.timestamp + (_totalNights * 1 days);
		checkoutDate[_roomNum] = _checkoutDate;
		emit RoomBooked(_roomNum, _totalNights, _checkoutDate);
	}

	function unbookRoom(uint _roomNum) external onlyOwner {
		require(_roomNum < totalRooms, "Room number does not exist.");
		// Make sure time has passed
	}

	function withdraw() external onlyOwner {
		bool success = payable(owner()).send(address(this).balance);
		require(success, "Ether withdraw failed.");
	}
}
