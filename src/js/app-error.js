App = {
  web3Provider: null,
  contracts: {},
  pages2parse: {}, // These pages will be parse and prepare for the blockchain
  urlPrefix: "https://en.wikipedia.org/w/api.php", // The used version of wikipedia

  init: async function() {

    // Some basic settings in frontend
    App.basicInit();

    // Try to connect to the blockchain
    //return await App.initWeb3();
  },

  initWeb3: async function() {
    /*
     * Replace me...
     */

    return App.initContract();
  },

  initContract: function() {
    /*
     * Replace me...
     */

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
  },

  /*
  * Retrieving new entries from wikipedia
  */

  retrieveAndSaveLastEntries: async function(event){

    /* stop form from submitting normally */
    event.preventDefault();

    var wikiEntries = $('#lookups-results').empty(); // HTML-Tag for the display of the result
    var tableHead = "<div class='col-xs-12 col-md-12'><table class='table'><thead class='bg-primary'><td>#</td><td>pageid</td><td>title</td><td>timestamp</td><td>recent changes id</td><td>revision id</td><td>old id</td><td>type</td><td>namespace</td><td></td></thead><tbody>", 
        tableTail =" </tbody></table></div>"; // prepare some output wrappers.
    var lookupsResults="", counter=0; // tmp variables for the next output

    var lastRccontinue =0; // If the result is more than 500, we need to mark the next revision we should work with.
    
    var fullurls, descriptions;
    // Access to the given date interval for the query.
    var qStarttime = new Date (queryStartdate.value+" "+queryStarttime.value+"").toISOString(),
        qEndtime = new Date (queryEnddate.value+" "+queryEndtime.value+"").toISOString();

    var params = {
        action: "query",
        list: "recentchanges",
        rcprop: "title|ids|timestamp|flags",
        rclimit: ""+queryLimit.value,
        rctype:""+queryChangeTyp.value,
        rcstart:""+qStarttime,
        rcend:""+qEndtime,
        rcnamespace:""+queryNamespace.value,
        rcdir: "newer",
        format: "json"
    };

    var url = App.urlPrefix + "?origin=*";
    // build the final url with the given parameters.
    Object.keys(params).forEach(function(key){url += "&" + key + "=" + params[key];});
    
    console.log(url);
    // Call the url for real and parse the response.
    fetch(url)
        .then(function(response){return response.json();})
        .then(function(response) {
            if (typeof response.continue !== "undefined"){ // occurs most when qStarttime == qEndtime
              lastRccontinue = response.continue.rccontinue; // doesn't exit if rcstart and rcsend are the same.
            }
            
            var recentchanges = response.query.recentchanges;
            var revids = new Array();
            var pageids = new Array();

            for (var rc in recentchanges) {
                
                revids[counter] = recentchanges[rc].revid;
                pageids[counter] = recentchanges[rc].pageid;
                //descriptions[recentchanges[rc].pageid] = callDescription(recentchanges[rc].oldid)
                counter++;

            }

             for (var rc in recentchanges) {
                             
                // HTML output the main informations pageid, title, revid, change type ...
                lookupsResults+= "<tr><td>"+counter+"</td><td>"+recentchanges[rc].pageid+"</td><td>"+recentchanges[rc].title+"</td><td>"+recentchanges[rc].timestamp+"</td><td>"+
                recentchanges[rc].rcid+"</td><td>"+recentchanges[rc].revid+"</td><td>"+recentchanges[rc].old_revid+"</td><td>"+recentchanges[rc].type+"</td><td>"+recentchanges[rc].ns+"</td><td><button id='item"+recentchanges[rc].revid+"'> Mehr Details</button></td></tr>";
                // placeholder for description and urls
                lookupsResults+= "<tr><td></td><td colspan='9' id='urlitem"+recentchanges[rc].revid+"'></td></tr><tr><td></td><td colspan='9' id='descitem"+recentchanges[rc].revid+"' class='d-none'></td></tr>";
            }

            lookupsResults = "<div class='col-xs-12 col-md-12'>We retrieved "+counter+ " Entries.<br> The last rccontinue is:"+lastRccontinue+"</div>"+tableHead+lookupsResults+tableTail
          
            //console.log(lookupsResults);
            wikiEntries.append(lookupsResults);

           fullurls = App.queryUrls(revids); 
          console.log(fullurls); 
          console.log(fullurls.size); 
          fullurls.then(function(urldatas){

            console.log(urldatas); 
            console.log(urldatas.size);
           
           for (var pg in urldatas.keys()) {
              console.log(pg);
           }
            /*var array = Object.getPrototypeOf(urldatas);

            $.each(urldatas, function(key, value) {
                console.log( "The key is '" + key + "' and the value is '" + value + "'" );
            }); */

          }).catch(function(error){console.log(error);});

        })
        .catch(function(error){console.log(error);}); //End


  }, // End of the retrieve.

  /*
  * call the description of the entries
  */

  callDescription: async function(revid){

    //https://en.wikipedia.org/w/api.php?action=parse&oldid=926169962&prop=text&format=json
   var desc = new Object();

   var params = {
        action: "parse",
        oldid: revid,
        prop: "text",
        format: "json"
    };

    var url = App.urlPrefix + "?origin=*";
    // build the final url with the given parameters.
    Object.keys(params).forEach(function(key){url += "&" + key + "=" + params[key];});
    
    console.log(url);
    // Call the url for real and parse the response.
   

        return desc;
    

  }, // End of the Description call.

  /*
  * Retrieving new entries from wikipedia
  */

  queryUrls: async function(revids){

    //https://en.wikipedia.org/w/api.php?action=query&revids=926169962|926169960&prop=info&inprop=url&format=json
    var urls = new Map();
    var wikiEntry = $('#itemurl'); 

    var ids = ""+revids.shift();
    Object.keys(revids).forEach(function(key){ids += "|" + revids[key];});

   var params = {
        action: "query",
        revids: ids,  //limit 50
        prop: "info",
        inprop: "url",
        format: "json"
    };

    var url = App.urlPrefix + "?origin=*";
    // build the final url with the given parameters.
    Object.keys(params).forEach(function(key){url += "&" + key + "=" + params[key];});
    
    console.log(url);
    // Call the url for real and parse the response.
    fetch(url)
        .then(function(response){return response.json();})
        .then(function(response) {


            /*Object.defineProperty(urls, "set", {
              set : function (target,value) {this.target = value;}
            });

            Object.defineProperty(urls, "get", {
                get : function (target) {urls[target];}
            }); */
            var counter = 0, pid;
            var pages = response.query.pages;
            for (var pg in pages) {

              urls.set('p'+pages[pg].pageid, ''+pages[pg].fullurl);
              //console.log(pages[pg].fullurl);
              counter++;
              pid = 'p'+pages[pg].pageid;

              // OUtput
              wikiEntry = $('#urlitem'+pages[pg].lastrevid); 
              wikiEntry.append(""+pages[pg].fullurl);

            }
          
          //alert(urls[pid]);

        })
        .catch(function(error){console.log(error);}); //End


    return urls;
  }, // End of the url query.


  basicInit: async function(){

     
    // Set a max date
    var dt = new Date();
    var d = dt.toISOString().split("T")[0];
    var t = dt.toLocaleTimeString().split(":");

    queryStartdate.max = d;
    queryStartdate.value = queryStartdate.max;
    queryEnddate.max = d;
    queryEnddate.value = queryEnddate.max;
    
    //queryStarttime.max = t[0]+":"+t[1];
    queryStarttime.value = t[0]+":"+t[1];
    //queryEndtime.max = t[0]+":"+t[1];
    queryEndtime.value = t[0]+":"+t[1];
  },

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
