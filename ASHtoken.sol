// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

//ASH Token    
contract ASHToken {
    mapping(address => uint256) private balances;
    mapping(address => mapping (address => uint256)) private allowed;
    string private name;
    string private symbol;
    uint256 _totalSupply = 50000;
    uint8 private decimals = 18;
    address public owner;

    constructor () {
        owner = msg.sender;
        name = "ASH Token";
        symbol = "ASH";
    }

    event Approval(address indexed _owner,address indexed _spender,uint256 _value);

    event Transfer(address indexed _from,address indexed _to,uint256 _value);

    event BoughtTokens(address indexed to, uint256 value);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount, "Insufficient balance.");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(balances[_from] >= _amount, "Insufficient balance.");
        require(allowed[_from][msg.sender] >= _amount, "Allowance insufficient.");
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }


    function mintSupply(uint256 _amount) public {
    require(owner==msg.sender, "You're not Ownwer.");
    require(_amount > 0, "Amount must be greater than 0.");
    _totalSupply += _amount;
    balances[owner] =  _totalSupply;

}

 function burnSupply(uint256 _amount) public {
    require(owner==msg.sender, "You're not Ownwer.");
    require(_amount > 0, "Amount must be greater than 0.");
    _totalSupply -= _amount;
    balances[owner] =  _totalSupply;
}

function getTokenFromEther(uint _value) public payable returns (uint256) {

    uint256 tokens = _value * 500; // 500 tokens per Ether
    balances[msg.sender] += tokens;
    return tokens;

}

    receive() external payable{
}


function decimal() public view returns(uint80)
{

    return decimals;
}



function withdraw(uint256 _tokens) public {
    require(owner!= msg.sender, "Owner can not withdraw");
    require(balances[msg.sender] >= _tokens, "Insufficient balance");
    address payable sender = payable(msg.sender);
    sender.transfer(_tokens);
    balances[sender] -= _tokens;
}



}


