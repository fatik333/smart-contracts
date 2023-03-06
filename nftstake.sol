// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./nft.sol";
import "./ASHtoken.sol";
import "./Ownable.sol";

contract NFTStaking is Ownable {
    // The NFT that can be staked
    ERC721Token public nft;

    // The ASHToken token used for rewards
    ASHToken public rewardToken;

    // The minimum stake time
    uint256 public minStakeTime;

    // The mapping from NFT token IDs to their stakes
    mapping(uint256 => Stake) public stakes;

    // The stake struct
    struct Stake {
        uint256 amount;     // The number of NFTs staked
        uint256 startTime;  // The time when the stake was made
        uint256 endTime;    // The time when the stake can be withdrawn
        uint256 reward;     // The total reward earned so far
    }

    // The events emitted by the contract
    event Staked(address indexed staker, uint256 indexed tokenId, uint256 amount, uint256 reward);
    event Unstaked(address indexed staker, uint256 indexed tokenId, uint256 amount, uint256 reward);

    constructor(ERC721Token _nft, ASHToken _rewardToken, uint256 _minStakeTime) {
        nft = _nft;
        rewardToken = _rewardToken;
        minStakeTime = _minStakeTime;
    }

    // Stake NFTs and start earning rewards
    function stake(uint256 tokenId, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(nft.ownerOf(tokenId) == msg.sender, "You don't own the NFT");

        // Check if the stake already exists
        Stake storage stakeData = stakes[tokenId];
        require(stakeData.amount == 0, "Stake already exists");

        // Transfer the NFT to the contract
        nft.transferFrom(msg.sender, address(this), tokenId);

        // Record the stake data
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + minStakeTime;
        stakeData.amount = amount;
        stakeData.startTime = startTime;
        stakeData.endTime = endTime;

        // Emit the stake event
        emit Staked(msg.sender, tokenId, amount, 0);
    }

    // Unstake NFTs and claim rewards
    function unstake(uint256 tokenId) external {
        Stake storage stakeData = stakes[tokenId];
        require(stakeData.amount > 0, "Stake does not exist");
        require(stakeData.endTime <= block.timestamp, "Stake time not over");

        // Calculate the reward and transfer it to the staker
        uint256 reward = calculateReward(stakeData.amount, stakeData.startTime, stakeData.endTime);
        require(reward > 0, "Reward must be greater than zero");
        rewardToken.transfer(msg.sender, reward);

        // Transfer the NFT back to the staker
        nft.transferFrom(address(this), msg.sender, tokenId);

        // Delete the stake data
        delete stakes[tokenId];

        // Emit the unstake event
        emit Unstaked(msg.sender, tokenId, stakeData.amount, reward);
    }

function calculateReward(uint256 amount, uint256 startTime, uint256 endTime) private view returns (uint256) {
    // Calculate the stake duration
    uint256 duration = endTime - startTime;
    require(duration >= minStakeTime, "Stake duration too short");

    // Calculate the reward based on the duration and the amount staked
    uint256 reward = duration * amount;
    return reward;
}

// Owner-only function to withdraw the ASHToken token from the contract
function withdrawRewardToken(uint256 amount) external onlyOwner {
    rewardToken.transfer(owner(), amount);
}

// Owner-only function to change the minimum stake time
function setMinStakeTime(uint256 _minStakeTime) external onlyOwner {
    minStakeTime = _minStakeTime;
}
}
