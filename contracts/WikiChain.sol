pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract WikiChain{
    
    struct Article {
        int pageid;
    	int revid;
    	string url;
    	string title;
    	string description;
    	string lastmodified;
    }
    
     struct Address2Id {
        address contractaddress;
        int revid;
        int pageid;
    }
    
    struct ArticleOutput{
	    address myaddress;
	    int pageid;
	    int revid;
	    string url;
	    string title;
	    string description;
	    string lastmodified;
	}
    
    // The register
    mapping (string => Address2Id []) URL2Addresses;
    
    ArticleOutput [] outputs;
    
    constructor() public{ }
    
    // As a Factory, it will only generate new instance of the contract WikiChainaRticle with the given datas.
    function generateContracts4Articles( Article [] memory datas) public{
       
       require (datas.length > 0, "The datafeed is empty. Please fill it out!");
       
        WikiChainArticle tmp;
        Address2Id memory a2p;
        
        uint len = uint(datas.length);
        
	    for(uint i=0; i<len; i++){
	        
	        // we can control if a contract with the given pageid and revid already exist. And refuse the new contract if it is the case.
	        require ( !lookup(datas[i].url, datas[i].pageid, datas[i].revid), "The pair key-value <pageid,revid> already exist.");
	        //The new contract is generated for every tuple
	        tmp = new WikiChainArticle(datas[i], address(this));
	        
	        // Save the new value in the register URL2Addresses
    	    a2p.contractaddress = address(tmp);
    	  	a2p.revid = datas[i].revid;
    	  	a2p.pageid = datas[i].pageid;
    	    
    	    // Control if the url already exist as key
    	    if (URL2Addresses[datas[i].url].length > 0){
    	        
    	    }
    	    URL2Addresses[datas[i].url].push(a2p);
	    }
    }
    
   function request( string memory url) public returns (ArticleOutput [] memory) {
        // lookup in the register if a given url already exist before crawling the blockchain for the corresponding contracts
        
        require (bytes(url).length > 0, "The url is not correct. The variable is empty for this transaction.");
        
        Address2Id [] memory results;
        
        if ( URL2Addresses[url].length != 0 ){
	        results = URL2Addresses[url];
	        
	        // read the informations out ofthe contract addresses, we just find
	        getInfos(results);
	        
	    } else{
	        // There is not entry for the given url.
	        delete outputs;
	    }
	    
	    return outputs;
      
    }
    
     function lookup ( string memory url, int pageid, int revid) public view returns (bool) {
        // lookp in the register if a given url already exist before crawling the blockchain for the corresponding contracts
        
        Address2Id [] memory results;
        
        if ( URL2Addresses[url].length > 0 ){
	        results = URL2Addresses[url];
	        
	        // Search for the given pair <pageid,revid>
	         for (uint i; i< results.length;i++){
	            if( results[i].pageid == pageid && results[i].revid == revid ){
	                return true;
	            }
	         }
	    } 
	    return false;
    }
    
    function getInfos(Address2Id [] memory results) public { //returns (address,int, int, string memory, string memory, string memory, string memory){
	    
	    require (results.length > 0, "There is no contract to check out.");
	    
	    delete outputs;
	    //ArticleOutput [] storage ops = outputs;
	    for (uint i; i< results.length;i++){
	        WikiChainArticle tmp = WikiChainArticle(results[i].contractaddress);
            // Read the infos out of contracts addresses
            //tmp = WikiChainArticle(results[i].contractaddress);
            
            ArticleOutput memory ops = tmp.toString();
            outputs.push(ops);
           //ops.push( tmp.toString()) ;
           
        }
        // outputs.push(ops);
	   //return tmp.toString();
	}
	
}

/**
 * 
 * Standard Template for the articles on the blockchain
 * 
**/
contract WikiChainArticle {

	int pageid;
	int revid;
	string url;
	string title;
	string description;
	string lastmodified;
	address register;
	
	WikiChain.ArticleOutput op;
	
	constructor (WikiChain.Article memory data, address reg) public {
	    pageid = data.pageid;
	    revid = data.revid;
	    url = data.url;
	    title = data.title;
	    description = data.description;
	    lastmodified = data.lastmodified;
	    register = reg;
	}
	
	/*function toString () public view returns (address, int, int, string memory, string memory, string memory, string memory) {
	    return (address(this), pageid, revid, url, title, description, lastmodified);
	}*/
	
	function toString () public returns (WikiChain.ArticleOutput memory) {
	    op.myaddress = address(this);
	    op.pageid = pageid;
	    op.revid = revid;
	    op.url = url;
	    op.title = title;
	    op.description = description;
	    op.lastmodified = lastmodified;
	    
	    return op;
	}
	
}