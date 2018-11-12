pragma solidity ^0.4.0;

contract HODL {

	struct Deposit {
		uint256 value;
		uint256 releaseTime;
	}

	struct Player {
		Deposit userDeposit;
	}

	struct Team {
		mapping(address => Player) players;
	}

	mapping(int => Team) teams;

	uint8 public teamSize;
	uint256 public RELEASE_TIME = 1 minutes;

	// This will be set to false once the match is finished. 
	bool matchIsFinished = false;

	function HODL(uint8 size) public {
		// The size of the teams must greater than 0 and less than 4. 
		require(size <= 4 && size > 0);

		// Add teams to mapping. 
		teams[1] = Team();
		teams[2] = Team();

	}

	function deposit(uint8 teamNumber) public payable {
		// User must pick either 1 or 2 for the team number.
		require(teamNumber == 1 || teamNumber == 2);
		// The user must also submit a value that is greater than 0 
		require(msg.value > 0);
		require(matchIsFinished == false);

		if (teams[teamNumber].players[msg.sender].userDeposit.releaseTime == 0) {
			uint256 releaseTime = now + RELEASE_TIME;
			teams[teamNumber].players[msg.sender].userDeposit = Deposit(msg.value, releaseTime);
		} else {

		}
	}

	function withdraw(uint8 teamNumber) public {
		require(teamNumber == 1 || teamNumber == 2)
		require(teams[teamNumber].players[msg.sender].userDeposit.value > 0);
        require(teams[teamNumber].players[msg.sender].userDeposit.releaseTime < now);
        
        msg.sender.transfer(teams[teamNumber].players[msg.sender].userDeposit.value);
        
        teams[teamNumber].players[msg.sender].userDeposit.value = 0;
        teams[teamNumber].players[msg.sender].userDeposit.releaseTime = 0;
	}
}