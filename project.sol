// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract QuizReward {

    // Define state variables
    address public owner;
    uint256 public rewardAmount; // Reward amount in Wei for completing a quiz

    struct User {
        uint256 totalQuizzesCompleted;
        uint256 totalRewards;
        bool isRegistered;
    }

    mapping(address => User) public users;

    event UserRegistered(address user);
    event QuizCompleted(address user, uint256 rewardAmount);
    event RewardClaimed(address user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this");
        _;
    }

    modifier isRegisteredUser() {
        require(users[msg.sender].isRegistered, "User must be registered");
        _;
    }

    constructor(uint256 _rewardAmount) {
        require(_rewardAmount > 0, "Reward amount must be greater than zero");
        owner = msg.sender;
        rewardAmount = _rewardAmount;
    }

    // Register a new user
    function registerUser() external {
        require(!users[msg.sender].isRegistered, "User is already registered");

        users[msg.sender] = User({
            totalQuizzesCompleted: 0,
            totalRewards: 0,
            isRegistered: true
        });

        emit UserRegistered(msg.sender);
    }

    // Complete a quiz and earn a reward
    function completeQuiz() external isRegisteredUser {
        // Update the total quizzes completed
        users[msg.sender].totalQuizzesCompleted += 1;

        // Calculate the reward and update the total rewards
        users[msg.sender].totalRewards += rewardAmount;

        // Emit event for quiz completion
        emit QuizCompleted(msg.sender, rewardAmount);
    }

    // Claim accumulated rewards
    function claimRewards() external isRegisteredUser {
        uint256 rewardToClaim = users[msg.sender].totalRewards;
        require(rewardToClaim > 0, "No rewards to claim");

        // Reset the user's reward balance after claiming
        users[msg.sender].totalRewards = 0;

        // Transfer the rewards to the user
        payable(msg.sender).transfer(rewardToClaim);

        // Emit event for reward claim
        emit RewardClaimed(msg.sender, rewardToClaim);
    }

    // Withdraw contract balance (only for owner)
    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient contract balance");
        payable(owner).transfer(amount);
    }

    // Fund the contract to pay rewards (only for owner)
    function fundContract() external payable onlyOwner {
        require(msg.value > 0, "Must send Ether to fund contract");
    }

    // Get user information (quizzes completed and rewards)
    function getUserInfo(address user) external view returns (uint256 quizzesCompleted, uint256 totalRewards) {
        return (users[user].totalQuizzesCompleted, users[user].totalRewards);
    }

    // Get the contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
