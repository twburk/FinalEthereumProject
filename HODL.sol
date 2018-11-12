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
		// Will hold all the players.
		mapping(address => Player) players;
	}

	struct Match {
		uint8 maxPlayersPerTeam;
		
		// For now only two teams per match. 
		//uint8 private maxTeamPerGame = 2;

		Team teamOne;
		Team teamTwo;
	}

	// Mapping of name to match.
	mapping(string => Match) matches;

	// matches will hold all the active matches.
	uint256 public RELEASE_TIME = 1 minutes;


	function HODL(string matchName, uint8 teamNumber) public  {
		// If match name exists, add uesr to the match.
		// If match name does not exist, create a new match with the name
		// and assign the user to the team desired. 

		// teamNumber should be 1 or 2. 
		require(teamNumber == 1 || teamNumber == 2);
		// Length of match name should be greater than 0. 
		require(bytes(matchName).length != 0);
	}
}