/* liveMap.lua -*-lua-*-
"THE BEER-WARE LICENSE" (Revision 42):
<tuomas.louhelainen@gmail.com> wrote this file.  As long as you retain
this notice you can do whatever you want with this stuff. If we meet
some day, and you think this stuff is worth it, you can buy me a beer
in return.  Tuomas Louhelainen */


    //MAP SETTINGS
     var map = L.map('map', {
       maxZoom: 18,
       minZoom: 11,
       crs: L.CRS.Simple
     }).setView([-0.045, 0.06], 14);

     var southWest = map.unproject([0, 25600], map.getMaxZoom());
     var northEast = map.unproject([28160, 0], map.getMaxZoom());
     map.setMaxBounds(new L.LatLngBounds(southWest, northEast));

     L.tileLayer('tiles/{z}/map_{x}_{y}.webp', {
       attribution: 'Map data &copy; Bethesda Softworks',
     }).addTo(map);

     //player icon
     var playerIcon = L.icon({
       iconUrl: 'assets/img/compass.png',
       iconSize:     [24, 24], // size of the icon
       iconAnchor:   [12, 12], // point of the icon which will correspond to marker's location
       popupAnchor:  [0, -20] // point from which the popup should open relative to the iconAnchor
     });

     //inside icon
     var insideIcon = L.icon({
       iconUrl: 'assets/img/door.png',
       iconSize:     [16, 16], // size of the icon
       iconAnchor:   [8, 8], // point of the icon which will correspond to marker's location
       popupAnchor:  [0, -20] // point from which the popup should open relative to the iconAnchor
     });

    //change this for quicker or slower update
    var updater = setInterval(checkForUpdates, 500);
    var markers = {};
    var playerListDiv = document.getElementById("playerList");



     function checkForUpdates() {
       loadJSON("assets/json/LiveMap.json?nocache="+(new Date()).getTime(), function(response) {
         var players = JSON.parse(response);
         updateMarkers(players);
         updatePlayerList(players);
       });
     }

     function updateMarkers(players) {
      var markersToDelete = Object.assign({}, markers);
      //key is player name in this case
       for(var key in players)
         {
          if(!players.hasOwnProperty(key)) continue;

          var player = players[key];

           var markerObject = [];
           //check if we have marker for this index
           if(key in markers)
            {
                markerObject = markers[key];
                if(player.isOutside)
                {
                  markerObject.marker.setLatLng(map.unproject(convertCoord([player.x,player.y]),map.getMaxZoom()));
                  markerObject.marker.setRotationAngle(player.rot);
                  markerObject.marker.setIcon(playerIcon);
                }
                else
                {
                  markerObject.marker.setIcon(insideIcon);
                  markerObject.marker.setRotationAngle(0);
                }
                delete markersToDelete[key];
             }
           //if not then create new and add that
           else
             {
               var tempMarker = L.marker(map.unproject(convertCoord([player.x,player.y]),map.getMaxZoom()), {icon: playerIcon}).addTo(map);
               markerObject.marker = tempMarker;
               markerObject.marker.setRotationAngle(player.rot);
               markerObject.marker.bindTooltip(key,{className: 'tooltip', direction:'right', permanent:true});
               markers[key] = markerObject;
             }
         }

         //loop through markers that we need to remove
         for(var key in markersToDelete)
         {
            //remove the marker
            map.removeLayer(markersToDelete[key].marker);
            //remove the object from marker-list
            delete markers[key];
         }

     };

     function updatePlayerList(players) {
        var playerCount = 0;
        for(var key in players)
        {
          playerCount++;
        }
        if(playerCount>0)
        {
          playerListDiv.setAttribute("style","height:"+(60+(25*playerCount))+"px");
          playerListDiv.innerHTML = '<h3>'+playerCount+' players online</h3>';
          for(var key in players)
          {
            var playerString = key;
            if(!players[key].isOutside)
              playerString+= " - "+players[key].cell.substring(0,16);
            playerListDiv.innerHTML += '<h4><a onClick="playerNameClicked(\''+key+'\')"; style="cursor: pointer; cursor: hand">'+playerString+'</h4>';
          }
        }
        else
        {
          playerListDiv.setAttribute("style","height:60px");
          playerListDiv.innerHTML = '<h3>No players online</h3>';
        }
     };

    function playerNameClicked(key) {
      console.log(key+" pressed");
      var marker = markers[key].marker;
      var latLngs = [ marker.getLatLng() ];
      var markerBounds = L.latLngBounds(latLngs);
      map.fitBounds(markerBounds);
    };




    function loadJSON(file, callback) {
      var xobj = new XMLHttpRequest();
      xobj.overrideMimeType("application/json");
      xobj.open('GET', file, true);
      xobj.onreadystatechange = function () {
       if (xobj.readyState == 4 && xobj.status == "200") {
         // Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
         callback(xobj.responseText);
       }
      };
      xobj.send(null);
    }

    var coordinateMultiplier = 16.0;

    function convertCoord(coord)
    {
      coord[0] = coord[0]/coordinateMultiplier+15358;
      coord[1] = coord[1]/-coordinateMultiplier+15356;
      return coord;
    }

    function reverseCoord(coord)
    {
      coord[0] = coord[0]*coordinateMultiplier-15358;
      coord[1] = coord[1]*-coordinateMultiplier-15356;
      return coord;
    }
