App = {
  web3Provider: null,
  contracts: {},
  pages2parse: {}, // These pages will be parse and prepare for the blockchain
  url: "https://en.wikipedia.org/w/api.php", // The used version of wikipedia

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

  retrieveLastEntries: async function(event){

    /* stop form from submitting normally */
    event.preventDefault();

    var wikiEntries = $('#lookups-results').empty(); // HTML-Tag for the display of the result
    var tableHead = "<div class='col-xs-12 col-md-12'><table class='table'><thead class='bg-primary'><td>#</td><td>pageid</td><td>title</td><td>timestamp</td><td>recent changes id</td><td>revision id</td><td>old id</td><td>type</td><td>namespace</td></thead><tbody>", 
        tableTail =" </tbody></table></div>"; // prepare some output wrappers.
    var lookupsResults="", counter=0; // tmp variables for the next output

    var lastRccontinue =0; // If the result is more than 500, we need to mark the next revision we should work with.
    
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

    App.url = App.url + "?origin=*";
    // build the final url with the given parameters.
    Object.keys(params).forEach(function(key){App.url += "&" + key + "=" + params[key];});
    
    console.log(App.url);
    // Call the url for real and parse the response.
    fetch(App.url)
        .then(function(response){return response.json();})
        .then(function(response) {
            //lastRccontinue = response.continue.rccontinue;
            var recentchanges = response.query.recentchanges;
            for (var rc in recentchanges) {
                counter++;

                // Collect the revid and pageid for the next step
                //pages2parse
                // HTML output
                lookupsResults+= "<tr><td>"+counter+"</td><td>"+recentchanges[rc].pageid+"</td><td>"+recentchanges[rc].title+"</td><td>"+recentchanges[rc].timestamp+"</td><td>"+
                recentchanges[rc].rcid+"</td><td>"+recentchanges[rc].revid+"</td><td>"+recentchanges[rc].old_revid+"</td><td>"+recentchanges[rc].type+"</td><td>"+recentchanges[rc].ns+"</td><tr>";
            }

            lookupsResults = "<div class='col-xs-12 col-md-12'>We retrieved "+counter+ " Entries.<br> The last rccontinue is:"+lastRccontinue+"</div>"+tableHead+lookupsResults+tableTail;
          
            //console.log(lookupsResults);
            wikiEntries.append(lookupsResults);
        })
        .catch(function(error){console.log(error);}); //End


  }, // End of the retrieve.

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
