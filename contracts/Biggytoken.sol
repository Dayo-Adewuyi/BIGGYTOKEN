// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Biggytoken is ERC20, Ownable {
    uint256 constant _initial_supply = 1000;
    address[] internal stakeholders;
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;
    uint256 public tokenPricePerEther;
    mapping(address => uint256) internal stakingStartTime;
    uint256 public tokensPerEth;

    constructor() ERC20("Biggytoken", "BGT") {
        _mint(msg.sender, _initial_supply);
        tokensPerEth = 1000;
    }

    function isStakeholder(address _address)
        public
        view
        returns (bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    function addStakeholder(address _stakeholder) public {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if (!_isStakeholder) stakeholders.push(_stakeholder);
    }

    function removeStakeholder(address _stakeholder) public onlyOwner {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if (_isStakeholder) {
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }

    function stakeOf(address _stakeholder) public view returns (uint256) {
        return stakes[_stakeholder];
    }

    function totalStakes() public view returns (uint256) {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            _totalStakes += stakes[stakeholders[s]];
        }
        return _totalStakes;
    }

    function createStake(uint256 _stake) public {
        _burn(msg.sender, _stake);
        if (stakes[msg.sender] == 0) {
            addStakeholder(msg.sender);
        }
        stakes[msg.sender] += _stake;
        stakingStartTime[msg.sender] = block.timestamp;
    }

    modifier UptoAWeek() {
        require(
            block.timestamp > stakingStartTime[msg.sender] + 7 days,
            "Not upto a week yet"
        );
        _;
    }

    function rewardOf(address _stakeholder) public view returns (uint256) {
        return rewards[_stakeholder];
    }

    function totalRewards() public view returns (uint256) {
        uint256 _totalRewards = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            _totalRewards += rewards[stakeholders[s]];
        }
        return _totalRewards;
    }

    function calculateReward(address _stakeholder)
        public
        view
        returns (uint256)
    {
        return stakes[_stakeholder] / 100;
    }

    function claimRewards() public UptoAWeek {
        uint256 reward = calculateReward(msg.sender);
        rewards[msg.sender] += reward;

        if(block.timestamp > stakingStartTime[msg.sender] +14 days){
            rewards[msg.sender]=0;
        }
    }

    function distributeRewards() public onlyOwner {
        for (uint256 s = 0; s < stakeholders.length; s += 1) {
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] += reward;
        }
    }

    function withdrawReward() public UptoAWeek {
        uint256 reward = rewards[msg.sender];
        uint256 _stake = stakes[msg.sender];
        rewards[msg.sender] = 0;
        stakes[msg.sender] = 0;
        _mint(msg.sender, (reward + _stake));
    }

    function buytoken(address receiver) public payable {
        require(msg.value > 0, "our tokens are 100/eth boss");
        uint256 amount = msg.value * tokensPerEth;
        _mint(receiver, amount);
    }

    function modifyTokenBuyPrice(uint256 _tokenPerEth) public onlyOwner {
        tokensPerEth = _tokenPerEth;
    }
}
