pragma solidity ^0.4.10;

contract HODL {

	struct Deposit {
		uint256 value;
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
	// Do not need anymore. Only for testing. 
	// uint256 public RELEASE_TIME = .5 minutes;

	// This will be set to true once all the teams are filled. 
	bool matchIsLocked = false;

	// This will be set to true once the match is finished. 
	bool matchIsFinished = false;

	uint8 winningTeamIndex;

	// These arrays will hold the addresses of the players in each team. 
	address[] public teamOneAddresses;
	address[] public teamTwoAddresses;

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
			// uint256 releaseTime = now + RELEASE_TIME;

			teams[teamNumber].players[msg.sender].userDeposit = Deposit(msg.value);

			// Set assignedToTeam flag to true. 
			teams[teamNumber].players[msg.sender].assignedToTeam = true;

			// Update the size of the team.
			teams[teamNumber].playersCurrentSize = teams[teamNumber].playersCurrentSize + 1;

			// ADD ADDRESS TO ARRAY
			// Add to teamOneAddresses if teamNumber is 1
			// Add to teamTwoAddresses if teamNumber is 2
			if (teamNumber == 1) {
				teamOneAddresses.push(msg.sender);
			} else {
				teamTwoAddresses.push(msg.sender);
			}

			///////////////////////////////////////////////////////////////////////

			// Check if both teams are filled.
			// If both teams are filled set flag to not allow any other users to join.
			if (teams[1].playersCurrentSize == teamSize && teams[2].playersCurrentSize == teamSize) {
				matchIsLocked = true;
			} 
		}
	}

	/*function initiateWithdrawal() public {
		// Check if matchIsFinished is true.
		// If it is true, then do not continue function and call the revert() function.
		// if it is false, then continue function and calc losses and pay winners and non malicious players. 
		if(matchIsFinished == true){
			revert();
		} else if(matchIsFinished == false){
			uint8 sum = 0;

			// Check what team the player that initiates withdrawal is in.
			// Make the winningTeamIndex equal to the index of the opposite team.
			// call the calculate loss function to calculate how money is going to be summed up to.
			// Should be the sum of the penalties from the losing team and the penalties from the malicious players.
			if(teams[1].players[msg.sender].assignedToTeam == true){
				winningTeamIndex = 2;
				sum = calculateLoss(1);
			}else if(teams[2].players[msg.sender].assignedToTeam == true){
				winningTeamIndex = 1;
				sum = calculateLoss(2);
			}

			// Divide that sum by all the winning players (based on the percentage of how much they invested.)
			// Pay each winner their respective winning amount. 
			payWinner(winningTeamIndex, sum);

			// set the matchIsFinished vairable to true so that functions can no longer be called. 
			matchIsFinished = true;
		}
	}*/

	// This function only with wirh releaseTime in the Deposite structure. 
	/*function withdraw(uint8 teamNumber) public {
		require(teamNumber == 1 || teamNumber == 2);
		require(teams[teamNumber].players[msg.sender].userDeposit.value > 0);
        require(teams[teamNumber].players[msg.sender].userDeposit.releaseTime < now);
        
        msg.sender.transfer(teams[teamNumber].players[msg.sender].userDeposit.value);
        
        teams[teamNumber].players[msg.sender].userDeposit.value = 0;
        teams[teamNumber].players[msg.sender].userDeposit.releaseTime = 0;
	}*/

	//sum of the penalties from the losing team and the penalties from the malicious players.
	function calculateLoss(uint8 teamNumber) public {
		uint8 sum = 0;
		uint8 percentLoss;

		if(teamNumber == 1){
			uint arrayLength = teamOneAddresses.length;
			address[] public tempArray = teamOneAddresses;
		}else{
			uint arrayLength = teamTwoAddresses.length;
			address[] public tempArray = teamTwoAddresses;
		}

		for(uint i=0; i < arrayLength; i++){
			uint8 playerValue = teams[teamNumber].players[tempArray[i]].userDeposit.value;
			if(malicious[tempArray[i]]){
				percentLoss = .40;
			}else{
				percentLoss = .15;
			}

			uint8 percentAmount = playerValue * percentLoss;
			sum += percentAmount;
			uint8 newPlayerValue = playerValue - percentAmount;
			teams[teamNumber].players[tempArray[i]].userDeposit = newPlayerValue;
		}


		return sum;
	}

	// Pay each winner their respective winning amount
	function payWinner(uint8 winningTeam, uint8 winningSum) public{
		if(winningTeam == 1){
			uint arrayLength = teamOneAddresses.length;
			address[] public tempArray = teamOneAddresses;
		}else{
			uint arrayLength = teamTwoAddresses.length;
			address[] public tempArray = teamTwoAddresses;
		}

		unit total = winningSum / arrayLength;

		for(uint i=0; i < arrayLength; i++){
			teams.players[tempArray[i]].transfer(total);
		}

	}
}