pragma solidity 0.4.25;

import "./SafeMath.sol";
import "./Admin.sol";

contract ERC20 is AdminRole {

    using SafeMath for uint256;

    string public symbol;
    string public  name;


    mapping (address => uint256) private balances;

    mapping (address => mapping (address => uint256)) private allowed;

    uint256 public decimals;
    uint256 public totalSupply;

    address public consumer;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Consumer(address indexed admin, address indexed addr);

    constructor() public {
        symbol = "GAS";
        name = "CryptoSpaceShip token Gas";
        decimals = 18;
        totalSupply = 10000 * 10**decimals;
        balances[msg.sender] = totalSupply;
        consumer = address(0);
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function setConsumer(address addr) public onlyAdmin {
        require(addr != address(0));

        consumer = addr;
        emit Consumer(msg.sender, addr);
    }

    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        if (msg.sender != consumer)
            allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);

        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
    }

}