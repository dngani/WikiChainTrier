pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

interface WikiUtilities {
    struct Article {
       int pageid;
    	int revid;
    	string url;
    	string titel;
    	string description;
    	string lastmodified;
    }
    
     struct Address2Id {
        address contractaddress;
        int revid;
    }
    
}

contract WikiChainFactory {
    
    address register;

	function generateArticles (WikiUtilities.Article [] memory datas) public {
	    uint len = uint(datas.length);
	    for(uint i=0; i<len; i++){
	        new WikiChainArticle(datas[i], address(register));
	    }
	}
	
	function setRegister(address reg) public {
	    register = reg;
	}
	
}

contract WikiChainRegister {
    
    // The register
    mapping (string => WikiUtilities.Address2Id []) url2address;
 
    int counter;
    address factory;

	constructor (address fac) public {
	    factory = fac;
	    updateFactory();
	}
	
	function addEntry (string memory url,address article, int revid) public returns (bool) {
	    
	    WikiUtilities.Address2Id memory a2p ;
	    //contracts.push(article);
	    a2p.contractaddress = article;
	    a2p.revid= revid;
	    
	    url2address[url].push(a2p);
	    
	    counter = counter +1;
	    
	    return true;
	}
	
	//function lookup (string url ) public return address {
	    //require( ....exists, "Person does not exist.");
	//}
	
	function updateFactory() public {
	    WikiChainFactory fac = WikiChainFactory(factory);
	    fac.setRegister(address(this));
	}

}

contract WikiChainArticle {

	int pageid;
	int revid;
	string url;
	string titel;
	string description;
	string lastmodified;
	address register;
	
	constructor (WikiUtilities.Article memory data, address reg) public {
	    pageid = data.pageid;
	    revid = data.revid;
	    url = data.url;
	    titel = data.titel;
	    description = data.description;
	    lastmodified = data.lastmodified;
	    register = reg;
	    
	    save2register();
	}
	
	function getInfos () public view returns (int, int, string memory, string memory, string memory, string memory) {
	    
	    return (pageid, revid, url, titel, description, lastmodified);
	}
	
	function save2register () private {
	    
	    // ... Call the register contract from the address reg and save this contract address in the private array.
	    WikiChainRegister reg_contract = WikiChainRegister(register);
	    reg_contract.addEntry(url, address(this), revid);
	}

}

contract WikiChainEngine{
  
    WikiChainFactory factory;
    WikiChainRegister register;
    
    constructor(address fac, address reg) public{
        factory = WikiChainFactory(fac);
        register = WikiChainRegister(reg);
    }
    
    function saveArticles( WikiUtilities.Article [] memory datas) public{
        // send the infos to WikiChain Factory for the execution
        
        factory.generateArticles(datas);
    }
    
    // function request(){
        // lookp in the register if a given url already exist before crawling the blockchain for the corresponding contracts
    //}
    
}


