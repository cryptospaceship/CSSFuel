pragma solidity 0.4.25;

import "./AddressUtils.sol";
import "./ERC20Interface.sol";
import "./Admin.sol";

contract Bridge is AdminRole {

    using AddressUtils for address;

    /**
     * Contrato de la dapp
     */
    address dapp;

    /**
     * Nonce de cada direccion
     */
    mapping (address => uint256) nonce;

    /**
     * Interfaz al contrato de los tokens
     */
    ERC20Interface gasToken;


    /**
     * Permite setear de donde se van a sacar los tokens
     */
    function setGas(address addr) external onlyAdmin {
        require(addr.isContract());
        gasToken = ERC20Interface(addr);
    }

    /**
     * Permite setear el contrato dapp
     */
    function setDapp(address addr) external onlyAdmin {
        require(addr.isContract());
        dapp = addr;
    }

    /**
     * Trae el nonce de una determinada direccion
     */
    function getNonce(address addr) external view returns (uint256) {
        return nonce[addr];
    }

    /**
     * builds a prefixed hash to mimic the behavior of eth_sign.
     */
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }


    function dispatch(address from, uint gaslimit, bytes signature, bytes data) external {
        uint256 n = nonce[from];
        bytes32 message = prefixed(keccak256(abi.encodePacked(data,n)));
        bytes32 bfrom = bytes32(from);
        bytes memory msgdata = data;

        require(
            recover(message,signature) == from,
            "Invalid source address"
        );

        require(
            gasToken.balanceOf(from) >= gaslimit,
            "Insufficient founds to pay the TX"
        );

        assembly {
            mstore(add(msgdata,36),bfrom)
        }

        dapp.exec(msgdata);

        gasToken.transferFrom(from,msg.sender,gaslimit);
    }

    function recover(bytes32 _hash, bytes _signed) internal pure returns(address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            r: = mload(add(_signed,32))
            s: = mload(add(_signed,64))
            v: = and(mload(add(_signed,65)) ,255)
        }
        return ecrecover(_hash,v,r,s);
    } 

}