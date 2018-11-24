pragma solidity 0.4.25;

contract ERC20Interface {
    function balanceOf(address owner) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}