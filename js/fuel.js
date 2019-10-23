class Dapp {
    constructor(provider) {
        this.abi = [{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_name","type":"string"},{"name":"_msg","type":"string"}],"name":"postMessage","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_delegated","type":"address"}],"name":"setDelegated","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_from","type":"address"},{"indexed":false,"name":"_number","type":"uint256"},{"indexed":false,"name":"_name","type":"string"},{"indexed":false,"name":"_msg","type":"string"}],"name":"PostMessage","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_delegated","type":"address"}],"name":"newDelegated","type":"event"}];
        this.access = provider.eth.contract(this.abi);
        this.contract = this.access.at("0xccad90a8c664899267214f235c4297ca5dcb664a");
    }

    postMessage(from,name,message) {
        return this.contract.postMessage.getData(from,name,message);
    }
}


class GasTransaction {
    constructor(backend, provider, bridge_address) {
        this.endpoint = backend;
        this.web3 = provider;
        this.abi = [{ "constant": true, "inputs": [{"name": "_addr", "type": "address"}], "name": "getNonce", "outputs": [{"name": "", "type": "uint256"}],"payable": false, "stateMutability": "view", "type": "function"}];
        this.access = provider.eth.contract(this.abi);
        this.contract = this.access.at(bridge_address);
    }

    pad(n,size) {
        var s = n.toString(16);
        while (s.length < (size || 2)) { s = "0" + s;}
        return s;
    }

    nonce(callback) {
        let web3 = this.web3;
        this.contract.getNonce(
            web3.eth.accounts[0],
            callback
        );
    }

    post(data, signature, address, callback) {
        let body = {
            'data': data,
            'signature': signature,
            'from': address
        };

        console.log(body);
        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if(this.readyState == XMLHttpRequest.DONE) {
                if (this.status == 201) 
                    callback(null,xhr.response);
                else
                    callback(xhr.response,null);
            }
        }

        xhr.open('POST', this.endpoint, true);
        xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        xhr.send(JSON.stringify(body));
    }

    send_signedTransaction(data, callback) {
        let web3 = this.web3;
        this.nonce((e,r)=>{
            if (!e) {
                let toSign = web3.sha3(data + this.pad(r.toNumber(),64), {encoding:'hex'});
                //web3.personal.sign(toSign, web3.eth.accounts[0],(error, signature)=>{
                web3.eth.sign(web3.eth.accounts[0],toSign,(error, signature)=>{
                    console.log(signature);
                    console.log(error);
                    if (!error) {
                        this.post(data,signature,web3.eth.accounts[0],callback);
                    }
                });
            }
        });
    }
} 