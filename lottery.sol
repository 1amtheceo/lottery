// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Lottery {
    address public owner; // Contract owner
    address[] public players; // Array of participants
    uint256 public maxPlayers; // Maximum number of players required to draw a winner
    uint256 public ticketPrice; // Cost of a lottery ticket

    // Events for logging actions
    event PlayerEntered(address indexed player); // Emitted when a player enters the lottery
    event WinnerChosen(address indexed winner, uint256 amount); // Emitted when a winner is selected

    // Contract constructor: sets the maxPlayers and ticketPrice
    constructor(uint256 _maxPlayers, uint256 _ticketPrice) {
        owner = msg.sender; // Set the owner to the contract deployer
        maxPlayers = _maxPlayers; // Define the maximum number of players
        ticketPrice = _ticketPrice; // Set the ticket price
    }

    // Function to enter the lottery
    function enter() external payable {
        require(msg.value == ticketPrice, "Incorrect ticket price"); // Ensure correct payment
        require(players.length < maxPlayers, "Lottery is full"); // Ensure there's room for more players

        players.push(msg.sender); // Add the player to the list
        emit PlayerEntered(msg.sender); // Emit event for player entry

        // If the lottery is full, pick a winner
        if (players.length == maxPlayers) {
            pickWinner();
        }
    }

    // Internal function to pick a winner and transfer the prize
    function pickWinner() internal {
        require(players.length == maxPlayers, "Not enough players"); // Ensure lottery is full

        uint256 randomIndex = getRandomNumber() % players.length; // Generate a random index
        address winner = players[randomIndex]; // Select the winner

        uint256 prize = address(this).balance; // Get the total prize pool
        (bool success, ) = payable(winner).call{value: prize}(""); // Transfer the prize to the winner
        require(success, "Transfer failed"); // Ensure the transfer is successful

        emit WinnerChosen(winner, prize); // Emit event with the winner's details

        delete players; // Reset the lottery for the next round
    }

    // Private function to generate a pseudo-random number (not secure for large sums!)
    function getRandomNumber() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players)));
    }

    // View function to check the contract's balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // View function to get the list of players
    function getPlayers() external view returns (address[] memory) {
        return players;
    }

    // Function to allow the owner to withdraw funds if necessary
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw"); // Ensure only the owner can withdraw
        payable(owner).transfer(address(this).balance); // Transfer the balance to the owner
    }
}
