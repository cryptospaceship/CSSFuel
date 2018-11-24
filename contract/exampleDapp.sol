pragma solidity 0.4.24;


import "./AddressUtils.sol";

contract Delegated {

    address delegated;
    using AddressUtils for address;

    event newDelegated(address indexed _delegated);

    function setDelegated (address _delegated) external {
        require(_delegated.isContract());
        delegated = _delegated;
        emit newDelegated(_delegated);
    }


    function sender(address _from) internal view returns(address) {
        if (_from == address(0)) {
            if (!address(msg.sender).isContract())
                return msg.sender;
            else
                return address(0);
        } else {
            if (msg.sender == delegated)
                return _from;
            else
                return address(0);
        }
    }
}


contract ExampleDapp is Delegated {

    uint256 n; 

    event PostMessage(address _from, uint256 _number, string _name, string _msg);

    constructor() public {
        n = 0;
    }

    function postMessage(address _from, string _name, string _msg) external {
        address msg_sender = sender(_from);
        require(msg_sender != address(0));

        PostMessage(msg_sender, n, _name, _msg);
        n = n + 1;
    }

}

