window.addEventListener('message', function(event) {
    let choosedId = 0;
    var data = event.data

    if (data.mode == "toggle") {
        $('.list-container').empty()
        for(let i in data.players){
            let player = data.players[i];
            $(".list-container").append('<div class="player-card" id="player-'+player.id+'"><p class="player-name">['+player.id+'] '+player.name+'</p></div>')
        }
        if(choosedId==0) {$(".buttons-container").empty()}
        $(".action-container").hide()
        $(".container").fadeIn()
    } else if (data.mode == "playerUpdate") {
        $('.list-container').empty()
        for(let i in data.players){
            let player = data.players[i];
            $(".list-container").append('<div class="player-card" id="player-'+player.id+'"><p class="player-name">['+player.id+'] '+player.name+'</p></div>')
        }
    } else {
        console.log("Wrong event.")
    }

    $(".player-card").click(function(){
        let id = $(this).attr('id').replace('player-', '')
        if (choosedId == parseInt(id)) { $('.player-card').removeClass('selected') }
        choosedId = parseInt(id)
        let n = $(this).attr('class').replace('player-card-', '')
        $('.player-card').removeClass('selected')
        $(this).addClass('selected')
        if(choosedId != 0) {
            $(".buttons-container").html(`
            <div class="first-section">
                <div class="goto button"><i class="fas fa-walking"></i>Spawn to player</div>
                <div class="bring button"><i class="fas fa-fighter-jet"></i>Bring a player</div>
                <div class="freeze button"><i class="fas fa-magic"></i>Freeze player</div>
            </div>
            <div class="second-section">
                <div class="noclip button"><i class="fab fa-fly"></i>NoClip action</div>
                <div class="slay button"><i class="fas fa-skull-crossbones"></i>Slay a player</div>
                <div class="revive button"><i class="fas fa-ambulance"></i>Revive a player</div>
            </div>
            <div class="third-section">
                <div class="kick button">Kick</div>
                <div class="ban button">Permantly ban</div>
                <input type="text" spellcheck="false" class="reason button" placeholder="Reason">
            </div>
            <div class="four-section">
                <div class="bringall button">Bring all</div>
                <div class="reviveall button">Revive all</div>
                <div class="kickall button">Kick all</div>
            </div>`)
            $(".action-container").fadeIn()
        }

        $(".button").click(function() {
            classString = $(this).attr('class').split(' ')[0];
            if (classString.indexOf("all") > -1) {
                $.post('https://dz-admin/execute-all-action', JSON.stringify({ type: classString }));
                $('.player-card').removeClass('selected')
                return
            }

            if (choosedId == 0) { return }
            let reason = $(".reason").val()
            if (classString == "ban" || classString == "kick") {
                $.post('https://dz-admin/execute-action', JSON.stringify({ type: classString, id: choosedId, reason: reason }));
                return
            }
            $.post('https://dz-admin/execute-action', JSON.stringify({ type: classString, id: choosedId }));
        });
    })

    $(document).keyup(function(e) {
        if(e.keyCode == 27){
            $(".container").fadeOut()
            $.post('https://dz-admin/close');
            choosedId = parseInt(0)
            $('.player-card').removeClass('selected')
        }
    })
})
