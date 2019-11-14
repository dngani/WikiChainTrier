pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./WikiChainArticle.sol";
import "./WikiChainUtilities.sol";

contract WikiChain{
    
   	event contractAlreadyExist(string, uint, uint, string);
	event contractAdded(uint,address, string, uint, uint);
	event requestFunction(uint, string);
	event callContractData(address, uint, uint, string);
	event newDeposit( address _from, uint _value, uint _timestamp);
	
	modifier positiveValue{
	    assert(msg.value > 0);
	    _;
	}
	
    // The register: save in location "storage" per default
    mapping (string => WikiChainUtilities.Address2Id []) private URL2Addresses ;
    uint private counter = 0;
    
    // The constructor
    constructor() public payable { }
    
    /* 
    * As a Factory, this method will generate new instances of the contract WikiChainArticle with the given datas.
    */
    function generateContracts4Articles( WikiChainUtilities.Article [] memory datas) public returns (uint) {
       
       // Minimun one entry should be available. throw a exception if the input array is empty.
        require (datas.length > 0, "The datafeed is empty. Please fill it out!");
        
        WikiChainArticle tmp;
        WikiChainUtilities.Address2Id memory a2p;
        
        uint len = uint(datas.length);
        
	    for(uint i=0; i<len; i++){
	        
	        // We can verified if the data entry is correct ...
	        
	        // We control if a contract with the given url, pageid and revid already exist. And don create a new contract if it is the case.
	        if( lookup(datas[i].url, datas[i].pageid, datas[i].revid)) {
	           emit contractAlreadyExist(datas[i].url, datas[i].pageid, datas[i].revid, "The key-value ( <url> -> <pageid,revid> ) already exist.");
	           continue;
	        }
	        
	        //A new contract is generated for every tuple.
	        tmp = (new WikiChainArticle).value(30000000)(address(this));
	        tmp.setDatas(datas[i]);
	  	        
	        // Save the new value in the register URL2Addresses
    	    a2p.contractaddress = address(tmp);
    	  	a2p.revid = datas[i].revid;
    	  	a2p.pageid = datas[i].pageid;
    	    
    	   // The new contract for the article must already exist at this point 
    	   //assert(a2p.contractaddress != address(0)); 
    	   
    	   // Even if the url already exist as key, the new infos will be save a the array mapping this url.
    	   URL2Addresses[datas[i].url].push(a2p);
    	   counter++;
    	   emit contractAdded(counter, a2p.contractaddress, datas[i].url, datas[i].pageid, datas[i].revid);
	    }
	    return counter;
    }
    
    /*
     * When the user is searching a url (coming from wikipedia),
        1. the url should not be empty
        2. we first lookup in the register "URL2Addresses", if some contracts exist for the given url.
        3. If there is no entry in the register, we give a empty output back.
        4. Otherwise, we would call the different contracts, collect the saved informations and sent it back as return value.
     *
    */
   function request( string memory url) public returns (WikiChainUtilities.ArticleOutput [] memory) {
        
        // lookup in the register if a given url already exist before crawling the blockchain for the corresponding contracts
        require (bytes(url).length > 0, "The url is not correct. The variable is empty for this transaction.");
        
        WikiChainUtilities.ArticleOutput [] memory outputs;
        WikiChainUtilities.Address2Id [] memory results;
        
        if ( URL2Addresses[url].length != 0 ){
	        results = URL2Addresses[url];
	        
	        // read the informations out ofthe contract addresses, we just find
	       outputs = callContracts(results);
	        
	    } else{
	        // There is not entry for the given url.
	        delete outputs;
	    }
	    
	    emit requestFunction(outputs.length, url);
	    return outputs;
      
    }
    
    function callContract(address payable article) public view returns (WikiChainUtilities.ArticleOutput memory){
	    
	    require (article != address(0), "The contract address is not valid. Please give another one.");
	    WikiChainArticle tmp = WikiChainArticle(article);
	    
	    //emit callContractData(article, tmp.pageid(), tmp.revid(), tmp.title());
	   
	   return tmp.toString();
	}
    
     function lookup ( string memory url, uint pageid, uint revid) internal view returns (bool) {
        // lookp in the register if a given url already exist before crawling the blockchain for the corresponding contracts
        WikiChainUtilities.Address2Id [] memory results;
        
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
    
    function callContracts(WikiChainUtilities.Address2Id [] memory results) internal view returns (WikiChainUtilities.ArticleOutput [] memory){
	    
	    require (results.length > 0, "There is no contract to check out.");
	    
	    WikiChainUtilities.ArticleOutput [] memory ops =  new WikiChainUtilities.ArticleOutput [](results.length);
	    for (uint i; i< results.length;i++){
	        WikiChainArticle tmp = WikiChainArticle(results[i].contractaddress);
            ops[i] = tmp.toString() ;
        }
	   return ops;
	}
	
	// If the contract received some ether, it will handel it
	function () external payable positiveValue {
	    require(msg.data.length == 0);
	    emit newDeposit( msg.sender, msg.value, block.timestamp);
	}
	
	function getRegisterCounter() public view returns(uint){
	    return counter;
	}
	
}

