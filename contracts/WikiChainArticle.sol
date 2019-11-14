pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./WikiChainUtilities.sol";

/**
 * 
 * Standard Template for the articles on the blockchain
 * 
**/
contract WikiChainArticle {

	uint public pageid;
	uint public revid;
	string public url;
	string public title;
	string public description;
	string public lastmodified;
	address register;
	
	WikiChainUtilities.ArticleOutput op;

	event newDepositForArticle( address, uint, uint);
	event dataSet(address, string, uint, uint);

	constructor (address reg) public payable {
	     register = reg;
		 if (msg.value > 0){
		 	emit newDepositForArticle( msg.sender, msg.value, block.timestamp);
		 }
	}
	
	function setDatas (WikiChainUtilities.Article memory data) public {

	    pageid = data.pageid;
	    revid = data.revid;
	    url = data.url;
	    title = data.title;
	    description = data.description;
	    lastmodified = data.lastmodified;
	   
 		// Prepare the output. This consume gas. Because of the writing operation on storage
	    op.myaddress = address(this);
	    op.pageid = pageid;
	    op.revid = revid;
	    op.url = url;
	    op.title = title;
	    op.description = description;
	    op.lastmodified = lastmodified;
	    
	    emit dataSet( op.myaddress, op.url, op.pageid, op.revid);
	}
	
	function toString () public view returns (WikiChainUtilities.ArticleOutput memory) {   
	    return op;
	}

	// If the contract received some ether, it will handel it
	function () external payable {
	    require(msg.data.length == 0);
	    emit newDepositForArticle( msg.sender, msg.value, block.timestamp);
	}
	
}

