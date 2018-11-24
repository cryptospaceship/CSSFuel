pragma solidity 0.4.25;


library AddressUtils {
    
    function isContract(address addr) 
        internal 
        view 
        returns (bool) 
    {
        uint256 size;
        assembly { 
            size := extcodesize(addr) 
        }
        return size > 0;
    }
    
    function exec(address addr, bytes data) 
        internal 
        returns (bool) 
    {
        uint datasize = data.length;
        uint ret;
        
        assembly {
            ret := call(
                gas,
                addr,
                0,
                add(data,32),
                datasize,
                0,
                0
            )
        }
        return (ret == uint(1));
    }
}