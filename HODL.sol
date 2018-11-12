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
	    uint8 playersCurrentSize;
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

		// Assign the size of each team. 
		teamSize = size;

		// Add teams to mapping. 
		teams[1] = Team(0);
		teams[2] = Team(0);

	}

	function deposit(uint8 teamNumber) public payable {
		// User must pick either 1 or 2 for the team number.
		require(teamNumber == 1 || teamNumber == 2);
		// The user must also submit a value that is greater than 0 
		require(msg.value > 0);
		require(matchIsFinished == false);

		// Make sure that the team the user is trying to enter is not filled. 
		require(teams[teamNumber].playersCurrentSize < teamSize);

		if (teams[teamNumber].players[msg.sender].userDeposit.releaseTime == 0) {
			uint256 releaseTime = now + RELEASE_TIME;
			teams[teamNumber].players[msg.sender].userDeposit = Deposit(msg.value, releaseTime);

			// Update the size of the team.
			teams[teamNumber].playersCurrentSize = teams[teamNumber].playersCurrentSize + 1;
		} else {
			// We could add the amount they want to add. 
		}
	}

	function withdraw(uint8 teamNumber) public {
		require(teamNumber == 1 || teamNumber == 2);
		require(teams[teamNumber].players[msg.sender].userDeposit.value > 0);
        require(teams[teamNumber].players[msg.sender].userDeposit.releaseTime < now);
        
        msg.sender.transfer(teams[teamNumber].players[msg.sender].userDeposit.value);
        
        teams[teamNumber].players[msg.sender].userDeposit.value = 0;
        teams[teamNumber].players[msg.sender].userDeposit.releaseTime = 0;
	}
}