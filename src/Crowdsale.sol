pragma solidity ^0.4.16;


contract Owned {
    address public owner;

    function Owned()  public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner  public {
        owner = newOwner;
    }
}


interface token {
    function transfer(address receiver, uint256 amount);
    function balanceOf(address receiver) constant returns (uint256 balance);
}


contract Crowdsale is Owned {

    token public tokenReward;
    address public beneficiary;
    uint public tokenRewardOfEachEther;
    uint256 public tokenBalance;

    event FundTransfer(
        address indexed recipient,
        uint256 indexed amount,
        uint256 tokenReward
    );

    function Crowdsale (
        address addressOfTokenUsedAsReward,
        uint tokenOfEachEther
    ) {
        tokenReward = token(addressOfTokenUsedAsReward);
        tokenRewardOfEachEther = tokenOfEachEther * 10 ** 4;
        beneficiary = msg.sender;
    }

    function setTokenReward(uint tokenOfEachEther) onlyOwner public {
        tokenRewardOfEachEther = tokenOfEachEther * 10 ** 4;
    }

    function transferBeneficiary(address newBeneficiary) onlyOwner public {
        beneficiary = newBeneficiary;
    }

    function getTokenReward() public view returns (uint) {
        return tokenRewardOfEachEther;
    }

    function getTokenBalance() public view returns (uint) {
        return tokenBalance;
    }

    function refreshTokenBalance() public {
        tokenBalance = tokenReward.balanceOf(address(this));
    }

    function withdrawEther(uint256 amount) public {
        beneficiary.transfer(amount);
    }

    function withdrawToken(uint256 amount) public {
        tokenReward.transfer(address(beneficiary), amount);
    }

    function () payable {
        uint256 amount = msg.value;

        if (msg.value > 0) {
            uint256 reward = uint256(amount * tokenRewardOfEachEther / 1 ether);

            require(tokenBalance > reward);

            if (tokenBalance > reward) {
                tokenReward.transfer(msg.sender, reward);
                beneficiary.transfer(amount);

                tokenBalance -= reward;

                FundTransfer(msg.sender, amount, reward);
            } else {
                revert();
            }
        }
    }
    
}

