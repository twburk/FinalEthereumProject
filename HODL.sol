pragma solidity ^0.4.0;

contract HODL {

	struct Deposit {
		uint256 value;
		uint256 releaseTime;
	}

	struct Player {
		Deposit userDeposit;
		bool assignedToTeam;
	}

	struct Team {
	    uint8 playersCurrentSize;
		mapping(address => Player) players;
	}

	// Mapping will hold both teams. Team 1 and Team 2. 
	mapping(int => Team) teams;

	// This mapping will hold all the malicious players. 
	// Their address will map to true if they are malicious.
	mapping(address => bool) malicious;

	uint8 public teamSize;
	// Time will be varied and updated. 
	uint256 public RELEASE_TIME = .5 minutes;

	// This will be set to true once all the teams are filled. 
	bool matchIsLocked = false;

	// This will be set to true once the match is finished. 
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
		// Make sure that the match is not locked and users can still join. 
		require(matchIsLocked == false);

		// User must pick either 1 or 2 for the team number.
		require(teamNumber == 1 || teamNumber == 2);

		// The user must also submit a value that is greater than 0 
		require(msg.value > 0);

		// Match must still be in session. 
		require(matchIsFinished == false);

		// Make sure that the team the user is trying to enter is not filled. 
		require(teams[teamNumber].playersCurrentSize < teamSize);

		// User cannot be in the other team or in the current team.
		// If the user is in the other team or in the current team,
		// penalize them and label as malicious player. 

		// If the user is already labelled a malivious player
		// revert and do not do anything. 
		if (malicious[msg.sender]) {
			revert();
		} else if (teams[1].players[msg.sender].assignedToTeam || teams[2].players[msg.sender].assignedToTeam) {
			// If the user is already in a team, label the user malicious and revert. 
			malicious[msg.sender] = true;
			revert();
		} else if (teams[teamNumber].players[msg.sender].assignedToTeam == false) {
			// Add the user to the specified team and set their release time. 
			uint256 releaseTime = now + RELEASE_TIME;
			teams[teamNumber].players[msg.sender].userDeposit = Deposit(msg.value, releaseTime);

			// Set assignedToTeam flag to true. 
			teams[teamNumber].players[msg.sender].assignedToTeam = true;

			// Update the size of the team.
			teams[teamNumber].playersCurrentSize = teams[teamNumber].playersCurrentSize + 1;


			///////////////////////////////////////////////////////////////////////


			// Check if both teams are filled.
			// If both teams are filled set flag to not allow any other users to join.
			if (teams[1].playersCurrentSize == teamSize || teams[2].playersCurrentSize == teamSize) {
				matchIsLocked = true;
			} 
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