function refreshList() {
    var query = $('#query').text();
    url = '/sampler/refresh?keyword=' + query;
    $.ajax({
        type: 'POST',
        url:  url,
        datatype: 'xml',
        success: function(responseText,status) {
            $('#videoCarousel div.item').remove();
            $('#selectorCarousel div.item').remove();
            var $videoInner = $('#videoCarousel > div.carousel-inner');
            var $selectorInner = $('#selectorCarousel > div.carousel-inner');
            var $xml = $(responseText);
            var $movie = $xml.find('movie');
            
            var selector_number = 0;
            var item_number = 0;
            var $selectorItem = null;
            var $selectorRow;
            jQuery.each($movie,function(total_number) {
                var $movie = $(this);
                var $videoItem;
                if (total_number == 0) {
                  $videoItem = $('<div>').attr({'class':'item active','name':total_number})
                  $videoInner.append($videoItem);
                } else {
                  $videoItem = $('<div>').attr({'class':'item','name':total_number})
                  $videoInner.append($videoItem);   
                }
                var $video = $('<a class="player" href="http://' + $movie.find("movie_url").text() + '"></a>');
                $videoItem.append($video);
                $tagsDiv = $('<div class="tags"></div>');
                $videoItem.append($tagsDiv);
                $tags = $movie.find('tag')
                jQuery.each($tags,function() {
                    $tagsDiv.append('<a href="/sampler/search?keyword='+$(this).text()+'">'+$(this).text()+'</a>');
                });
                $descLink = $('<div class="desc"><a href="http://www.dmm.co.jp/litevideo/-/detail/=/cid=' + $movie.find("dmm_id").text() + '/quotto-003">この動画の詳細</a></div>');
                $videoItem.append($descLink);
                if(item_number == 0 ) {
                    if(selector_number == 0) {
                        $selectorItem = $('<div class="selector item active">');
                        $selectorRow = $('<div class="selector_row">');
                        $selectorItem.append($selectorRow);                        
                    } else {
                        $selectorItem = $('<div class="selector item">');
                        $selectorRow = $('<div class="selector_row">');
                        $selectorItem.append($selectorRow);
                    }
                }
                $selectorItemDiv = $('<div class="selector_item">').attr('name',total_number);
                $img = $('<img>').attr({
                    'alt':$movie.find('title').text(),
                    'src':$movie.find('thumbnail').text(),
                    'data-target':'#videoCarousel',
                    'data-slide-to':total_number,
                    'data-toggle':'tooltip',
                    'data-original-title':$movie.find('title').text(),
                    'rel':'thumbnail'
                });
                $selectorItemDiv.append($img);
                $selectorRow.append($selectorItemDiv);
                item_number += 1;
                if(item_number == 10) {
                    $selectorInner.append($selectorItem);
                    selector_number += 1;
                    item_number = 0;
                }                
            });
            if(item_number > 0) {
                $selectorInner.append($selectorItem);
            }
            $('img[rel=thumbnail]').tooltip();
            $('img[rel=thumbnail]').tooltip();
            // 初期表示時は最初のサムネイルをマークアップする
            $('div.selector_item:first').css('background','rgba(255,0,0,0.7)');
            // flowplayerを設定
            flowplayer("a.player","http://releases.flowplayer.org/swf/flowplayer-3.2.18.swf",{
                clip: {
                    autoPlay:true,
                    onFinish:function() {
                        $("#videoCarousel").carousel('next');
                    }
                }
            });
        }
    });
}

function selectionQuery() {
    url = '/sampler/keyword_selection';
    $.ajax({
        type: 'GET',
        url: url,
        datatype: 'xml',
        success: function(responseText,status) {
            var $query_counts = $(responseText).find("query-count");
            $('#keywordModal div.modal-body').children().remove();
            jQuery.each($query_counts,function() {
                $query_count = $(this);
                var $queryLink = $('<a></a>');
                var query = $query_count.find('query').text();
                $queryLink.attr('href','/sampler/search?keyword='+query);
                $queryLink.text(query);
                $('#keywordModal div.modal-body').append($queryLink);
            });
        }
    })
}

function carouselNext() {
    $('#videoCarousel').carousel('next');
}

function playMovie(num) {
    flowplayer(parseInt(num)).play();
}

function pauseMovie(num) {
    flowplayer(parseInt(dmm_id)).stop();
}
