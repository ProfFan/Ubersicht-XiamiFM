# Execute the shell command.
command: "osascript XiamiRadio.widget/GetXiami.applescript"


# Set the refresh frequency (milliseconds).
refreshFrequency: 1000

# Render the output.
render: (output) -> """
  <table id='xiamiradio'></table>
"""

# Update the rendered output.
update: (output, domEl) -> 
  dom = $(domEl)
  
  data = JSON.parse output
  html = ""
  
  if data.artist == "missing value"
    data.title = "Not Playing"
  if data.artist == ""
    data.title = "Nothing"
  if data.data != "missing value"
    now_playing = JSON.parse data.data
    data.title = now_playing.songName
    data.artist = now_playing.artist
    data.image = now_playing.cover_url
  
  html += "<td class='service'>" 

  html += "  <p class='caption'>"+"Now Playing"+"</p>" 
  html += "  <p class='caption'><img src='"+data.image+"'></img></p>" 
  html += "  <p class='primaryInfo' id='song-title'><span>"+data.title+"</span></p>" 
  html += "  <p class='secondaryInfo'>"+data.artist+"</p>"
  html += "</td>"
  
  # Set output.
  $(xiamiradio).html(html)

afterRender: (domEl) ->
  $(domEl).on 'click', '#song-title', => @run "osascript XiamiRadio.widget/NextSong.applescript"

style: """
  margin:0
  padding:0px
  left:60px
  top: 200px
  background:rgba(#FFF, .50)
  border:1px solid rgba(#000, .25)
  border-radius:10px
      
  .service
    text-align:center
    padding-left:20px
    padding-right:20px
    
  .icon
    height:32px
    width:32px
    
  .primaryInfo, .secondaryInfo, .caption
    font-family: Helvetica Neue
    font-weight: 200
    padding:0px
    margin:2px
    
  .primaryInfo
    font-size:20pt
    font-weight: 200
    color: rgba(#000,0.75)
    
  .caption
    font-size:10pt
    font-weight:bold
    color: rgba(#000,0.75)
    
  .secondaryInfo
    font-size:15pt
    color: rgba(#000, 0.5)
  
  img
    margin: 4px
    padding: 0px
    border:3px solid rgba(#000, .25)
    border-radius:10px
  
"""
